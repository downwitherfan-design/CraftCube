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

var engine := PuzzleEngine.new()
var game_state := GameState.new()
var levels: Array = []
var current_index := 0

var cube_view: CubeView
var world_view: WorldView

# When an animated turn ends the truth layer is advanced; this holds the in-flight move.
var _pending_move: Dictionary = {}

func _ready() -> void:
	levels = LevelCatalog.chapter_one()
	cube_view = get_node_or_null("CubeView")
	world_view = get_node_or_null("WorldView")
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
	load_level(resume)

func load_level(index: int) -> void:
	current_index = clampi(index, 0, levels.size() - 1)
	var lvl: Dictionary = levels[current_index]
	engine.setup(lvl)
	if cube_view:
		cube_view.build(engine.state)
	if world_view:
		world_view.sync_lit(game_state.solved_levels.size())
	level_loaded.emit(lvl)

func restart_level() -> void:
	if is_animating():
		return
	engine.reset()
	_pending_move = {}
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
	if applied and cube_view:
		cube_view.refresh(engine.state)
		move_applied.emit()
	return applied

func _on_move_animated(move: Dictionary) -> void:
	engine.apply_move(move)
	_pending_move = {}
	if cube_view:
		cube_view.refresh(engine.state)
	move_applied.emit()

func is_animating() -> bool:
	return cube_view != null and cube_view.is_animating()

func undo() -> bool:
	if is_animating():
		return false
	var ok := engine.undo()
	if ok and cube_view:
		cube_view.refresh(engine.state)
	return ok

func objective_progress() -> Dictionary:
	return engine.objective_progress()

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
	if not engine.is_solved():
		return false
	var lvl: Dictionary = levels[current_index]
	var level_id := str(lvl["level_id"])
	if game_state.is_solved(level_id):
		return true  # already completed; no duplicate effects, no re-save
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
		solved.emit(lvl, reward)
	else:
		solved.emit(lvl, {})

	# Optional, non-blocking discovery check (chapter-level), resolved by ID.
	var disc_id := str(lvl.get("discovery_id", ""))
	if disc_id != "":
		var disc := StoryContent.discovery_for(disc_id)
		if not disc.is_empty() and game_state.add_discovery(disc_id):
			discovery_found.emit(disc)

	game_state.current_level_index = current_index
	SaveManager.save_to_path(game_state)
	return true

## Advance to the nearest unsolved later level (never skips an unsolved level) and
## persist the new position. Returns false when every later level is solved.
func next_level() -> bool:
	var target := -1
	for i in range(current_index + 1, levels.size()):
		if not game_state.is_solved(str(levels[i]["level_id"])):
			target = i
			break
	if target < 0:
		return false
	load_level(target)
	game_state.current_level_index = target
	SaveManager.save_to_path(game_state)
	level_advanced.emit(target)
	return true
