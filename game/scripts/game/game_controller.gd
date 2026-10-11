class_name GameController
extends Node3D

## Wires the deterministic domain (PuzzleEngine + GameState) to the presentation
## (CubeView + WorldView) and the UI. Gameplay logic lives in the domain; this node
## only translates input into domain calls and domain state into view updates.

signal level_loaded(level: Dictionary)
signal solved(level: Dictionary, reward: Dictionary)
signal level_advanced(index: int)
signal discovery_found(discovery: Dictionary)
signal reward_granted(reward_id: String, equipment: Dictionary)
signal world_reacted(hook: String, text: String)
signal move_applied()
## Fires on every successful completion (first time AND replays) with the derived result, so
## the results screen is driven by real state rather than cosmetic variables.
signal result_ready(result: Dictionary)
## Player asked to return to the application menu (HUD "Menu" button). The app shell owns
## navigation, so the controller only announces the request.
signal menu_requested()

## When true, a platform back/close request quits the tree (standalone gameplay). When the
## app shell is present it sets this false so back navigation stays with the app.
var exit_quits := true

var engine := PuzzleEngine.new()
var game_state := GameState.new()
var levels: Array = []
var current_index := 0

## The most recent completion result and the stored best record it produced. Cleared when a
## new level is loaded so a stale panel can never be shown for a different level.
var last_result: Dictionary = {}
var last_record: Dictionary = {}
## Guided steps used since the current level was entered (recorded for feedback, never a
## penalty: using the guide still earns the same stars).
var _hint_uses := 0

var cube_view: CubeView
var world_view: WorldView
var camera: OrbitCamera

## Save file used by save_progress(); tests override it so they never touch the real save.
var save_path := SaveManager.DEFAULT_PATH

# When an animated turn ends the truth layer is advanced; this holds the in-flight move.
var _pending_move: Dictionary = {}

# Milestone A: the cached guided route (list of concrete moves) and its cursor. Rebuilt on
# demand; invalidated whenever the player's trajectory changes (move, undo, restart, level).
var _guide_route: Array = []
var _guide_cursor: int = 0
var _guide_following := false

func _ready() -> void:
	levels = LevelCatalog.chapter_one()
	cube_view = get_node_or_null("CubeView")
	world_view = get_node_or_null("WorldView")
	camera = get_node_or_null("Camera3D")
	if camera:
		camera.reset_view()
	if world_view:
		world_view.build()
	var hud := get_node_or_null("HUD")
	if hud and hud.has_method("bind"):
		hud.bind(self)
	game_state = SaveManager.load_from_path()
	# Resume at the saved position when valid. If that position is already solved, resume at
	# the first unsolved level so the player continues instead of replaying; if every level is
	# solved, keep the saved position. Clamping keeps a stale/older save from pointing past
	# the chapter.
	var resume := clampi(game_state.current_level_index, 0, levels.size() - 1)
	if game_state.is_solved(str(levels[resume]["level_id"])):
		var first_open := game_state.first_unsolved_index(levels)
		if first_open >= 0:
			resume = first_open
	# Never resume onto a locked level: a stale or edited save that points past the unlocked
	# frontier falls back to the furthest level the progression actually allows.
	if not game_state.is_level_unlocked(levels, resume):
		resume = game_state.highest_unlocked_index(levels)
	load_level(resume, true)

## Load a level by index. Returns false (and changes nothing) when the level is not yet
## unlocked, so a direct controller call cannot skip an unsolved prerequisite level. Pass
## `force=true` only for explicit replay of an already-solved level.
func load_level(index: int, force: bool = false) -> bool:
	if index < 0 or index >= levels.size():
		return false
	if not force and not game_state.is_level_unlocked(levels, index):
		return false
	current_index = index
	var lvl: Dictionary = levels[current_index]
	engine.setup(lvl)
	last_result = {}
	last_record = {}
	_hint_uses = 0
	invalidate_guide()
	if cube_view:
		cube_view.build(engine.state)
	if world_view:
		world_view.sync_lit(game_state.solved_levels.size())
	level_loaded.emit(lvl)
	return true

## True when `index` may be entered right now (first level, or predecessor solved).
func is_level_unlocked(index: int) -> bool:
	return game_state.is_level_unlocked(levels, index)

func restart_level() -> void:
	if is_animating():
		return
	engine.reset()
	_pending_move = {}
	invalidate_guide()
	if cube_view:
		cube_view.refresh(engine.state)

## Apply a face turn. Idle -> the move is validated, the layer animates, and the truth
## layer advances exactly when the animation settles. Busy -> the input is ignored, so two
## turns can never overlap and corrupt the logical state. `animated=false` (tests/headless)
## applies immediately with no tween.
func try_move(face: String, cw: bool, animated: bool = true) -> bool:
	var move := MoveTable.face_move(face, cw)
	if cube_view and animated and cube_view.has_method("animate_move"):
		if cube_view.is_animating():
			return false
		if not engine.is_legal(move):
			return false
		if not cube_view.animate_move(move, engine.state, _on_move_animated.bind(move)):
			return false
		_pending_move = move
		return true
	var applied := engine.apply_move(move)
	if applied:
		_on_player_action()
		if cube_view:
			cube_view.refresh(engine.state)
		move_applied.emit()
	return applied

func _on_move_animated(move: Dictionary) -> void:
	engine.apply_move(move)
	_on_player_action()
	_pending_move = {}
	if cube_view:
		cube_view.refresh(engine.state)
	move_applied.emit()

func is_animating() -> bool:
	return cube_view != null and cube_view.is_animating()

## Flush current progress to disk. Safe to call any time (idempotent). Used on exit so a
## session interrupted by the Android back gesture or a window close never loses progress.
## `save_path` is overridable so tests can isolate the real save file.
func save_progress() -> bool:
	return SaveManager.save_to_path(game_state, save_path)

## Handle the OS close/back request: persist progress, then quit. On Android the back
## gesture arrives as NOTIFICATION_WM_GO_BACK_REQUEST; on desktop a window close as
## NOTIFICATION_WM_CLOSE_REQUEST. Both must be safe when progress is already saved.
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if engine != null and game_state != null:
			save_progress()
		if exit_quits and is_inside_tree():
			get_tree().quit()

## Announce that the player wants to leave gameplay for the application menu. Persists first
## so leaving can never lose progress.
func request_menu() -> void:
	save_progress()
	menu_requested.emit()

## Discard all progression and start Chapter One from level 1. Used only by the app shell's
## confirmed "New Game". Resets in-memory state and reloads the first level.
func start_new_game() -> void:
	game_state = GameState.new()
	current_index = 0
	last_result = {}
	last_record = {}
	_hint_uses = 0
	load_level(0, true)
	save_progress()

func undo() -> bool:
	if is_animating():
		return false
	var ok := engine.undo()
	if ok:
		_on_player_action()
		if cube_view:
			cube_view.refresh(engine.state)
	return ok

# --- Milestone A: guided solving -------------------------------------------------------

## Discard the cached guide. Called whenever the player's trajectory changes for a reason
## other than following the guide itself (independent move, undo, restart, level change).
func invalidate_guide() -> void:
	_guide_route = []
	_guide_cursor = 0
	_guide_following = false

## A player action that is not part of following the guide invalidates it, so stale advice
## can never be shown after the cube state it was computed for has changed.
func _on_player_action() -> void:
	if _guide_following:
		return
	invalidate_guide()

## Build the cached guided route if needed. Returns the full route (never null).
func ensure_guide() -> Array:
	if _guide_route.is_empty() and not engine.is_solved():
		_guide_route = PuzzleSolver.route_to_solved(engine)
		_guide_cursor = 0
	return _guide_route

## The next executable guided move, or {} when the cube is already solved. Recomputes the
## route if the cursor has run past the cached one.
func guide_next_move() -> Dictionary:
	if engine.is_solved():
		return {}
	ensure_guide()
	if _guide_cursor >= _guide_route.size():
		_guide_route = PuzzleSolver.route_to_solved(engine)
		_guide_cursor = 0
	if _guide_cursor >= _guide_route.size():
		return {}
	return _guide_route[_guide_cursor]

## Player-facing summary of the current guide for the HUD.
func guide_status() -> Dictionary:
	if engine.is_solved():
		return {"available": false, "solved": true, "remaining": 0, "text": "Already solved — no guidance needed."}
	var route := ensure_guide()
	var remaining: int = maxi(0, route.size() - _guide_cursor)
	var nm := guide_next_move()
	var text := "Guided route ready (%d step(s)). It reliably returns the cube to solved — it is not an optimal solver." % route.size()
	if not nm.is_empty():
		text = "Next guided step: turn the %s %s (reliable route, %d step(s) left)." % [
			_face_word(str(nm["face"])), "clockwise" if bool(nm["cw"]) else "counter-clockwise", remaining]
	return {"available": not nm.is_empty(), "solved": false, "remaining": remaining, "text": text,
		"face": str(nm.get("face", "")), "cw": bool(nm.get("cw", true)), "total": route.size()}

## Execute the next guided step through the same real engine/animation path as an ordinary
## turn. Returns false (and does nothing) when there is no valid guided move.
func guided_move(animated: bool = true) -> bool:
	if is_animating():
		return false
	var m := guide_next_move()
	if m.is_empty() or not engine.is_legal(m):
		invalidate_guide()
		m = guide_next_move()
		if m.is_empty() or not engine.is_legal(m):
			return false
	if cube_view and animated and cube_view.has_method("animate_move"):
		_guide_following = true
		if not cube_view.animate_move(m, engine.state, _on_guided_settled.bind(m)):
			_guide_following = false
			return false
		_pending_move = m
		_hint_uses += 1
		return true
	_guide_following = true
	var applied := engine.apply_move(m)
	_guide_following = false
	if applied:
		_guide_cursor += 1
		_hint_uses += 1
		if cube_view:
			cube_view.refresh(engine.state)
		move_applied.emit()
	return applied

func _on_guided_settled(m: Dictionary) -> void:
	engine.apply_move(m)
	# The cached route stays valid: we have executed its prefix, so advance the cursor
	# rather than recomputing (recomputing here would oscillate the suggestion).
	_guide_cursor += 1
	_guide_following = false
	_pending_move = {}
	if cube_view:
		cube_view.refresh(engine.state)
	move_applied.emit()

func _face_word(face: String) -> String:
	match face:
		"U": return "top"
		"D": return "bottom"
		"F": return "front"
		"B": return "back"
		"L": return "left"
		"R": return "right"
	return face

func objective_progress() -> Dictionary:
	return engine.objective_progress()

## Per-face readiness for the HUD (U,D,L,R,F,B), so partial mastery is visible.
func face_readiness() -> Array:
	return engine.face_readiness()

## The level currently loaded, for presentation-layer readouts (title, objective faces, par).
func current_level() -> Dictionary:
	if current_index >= 0 and current_index < levels.size():
		return levels[current_index]
	return {}

func legal_faces() -> Array:
	var faces := []
	for m in engine.legal_moves():
		if not faces.has(m["face"]):
			faces.append(m["face"])
	return faces

## Called when the player believes the puzzle is solved: verifies against the real
## solve predicate, then drives world reaction -> reward -> progression -> save.
## Idempotent: a repeated call for an already-solved level MUST NOT fire the world
## reaction, reward, or discovery again (duplicate-completion guard).
func confirm_solve() -> bool:
	if is_animating():
		return false
	if not engine.is_solved():
		return false
	var lvl: Dictionary = levels[current_index]
	var level_id := str(lvl["level_id"])
	var par := int(lvl.get("par_moves", 0))
	var moves := engine.move_count()
	var stars := GameState.stars_for(moves, par)
	var first_time := not game_state.is_solved(level_id)
	# Record the attempt (best-result policy). This is safe on replays: a weaker result never
	# overwrites a stronger record. Attempt/hint stats accumulate for feedback only.
	var rec := game_state.record_attempt(level_id, moves, stars, _hint_uses)
	last_record = rec["record"]
	last_result = {
		"level_id": level_id,
		"title": str(lvl.get("title", "")),
		"ordinal": int(lvl.get("ordinal", 0)),
		"moves": moves,
		"par": par,
		"stars": stars,
		"best_stars": int(rec["record"].get("best_stars", stars)),
		"best_moves": int(rec["record"].get("best_moves", moves)),
		"is_best": bool(rec["is_best"]),
		"improved": bool(rec["improved"]),
		"first_time": first_time,
		"hints": _hint_uses,
		"campaign_complete": false,
		"next_index": -1,
	}
	_hint_uses = 0

	# One-time effects (world reaction, reward, discovery) fire only on the first completion,
	# so revisiting a level or its results screen never duplicates them.
	if first_time:
		game_state.mark_solved(level_id)
		var hook := str(lvl.get("world_hook", ""))
		game_state.set_world_flag(hook)
		if world_view:
			world_view.react()
		if cube_view:
			cube_view.flash_solved(engine.state)
		world_reacted.emit(hook, StoryContent.reaction_for(hook))

		var reward_id := str(lvl.get("reward_id", ""))
		var reward := StoryContent.reward_for(reward_id)
		if not reward.is_empty():
			var equipment_id := StoryContent.equipment_id_for(reward_id)
			if equipment_id != "":
				game_state.grant_equipment(equipment_id)
			reward_granted.emit(reward_id, StoryContent.equipment_for(reward_id))
			last_result["reward_id"] = reward_id
			last_result["reward_narrative"] = str(reward.get("narrative", ""))
			solved.emit(lvl, reward)
		else:
			solved.emit(lvl, {})

		# Optional, non-blocking discovery check (chapter-level), resolved by ID.
		var disc_id := str(lvl.get("discovery_id", ""))
		if disc_id != "":
			var disc := StoryContent.discovery_for(disc_id)
			if not disc.is_empty() and game_state.add_discovery(disc_id):
				last_result["discovery_id"] = disc_id
				last_result["discovery_name"] = str(disc.get("name", ""))
				discovery_found.emit(disc)

	# The next actionable level (first unsolved later level), or -1 when the chapter is done.
	var next_index := -1
	for i in range(current_index + 1, levels.size()):
		if not game_state.is_solved(str(levels[i]["level_id"])):
			next_index = i
			break
	last_result["next_index"] = next_index
	last_result["campaign_complete"] = game_state.campaign_complete(levels)

	game_state.current_level_index = current_index
	save_progress()
	result_ready.emit(last_result)
	return true

## The most recent completion result ({} before any completion). Used by the results screen.
func last_result_data() -> Dictionary:
	return last_result

## Best stored record for a level index ({} when never completed).
func best_record_for(index: int) -> Dictionary:
	if index < 0 or index >= levels.size():
		return {}
	return game_state.best_for(str(levels[index]["level_id"]))

## Guided steps used since the current level was entered.
func hint_uses() -> int:
	return _hint_uses

## Advance to the nearest unsolved later level (never skips an unsolved level) and
## persist the new position. Returns false when every later level is solved.
func next_level() -> bool:
	if is_animating():
		return false
	var target := -1
	for i in range(current_index + 1, levels.size()):
		if not game_state.is_solved(str(levels[i]["level_id"])):
			target = i
			break
	if target < 0:
		return false
	if not load_level(target):
		return false
	game_state.current_level_index = target
	save_progress()
	level_advanced.emit(target)
	return true
