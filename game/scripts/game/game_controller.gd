class_name GameController
extends Node3D

## Wires the deterministic domain (PuzzleEngine + GameState) to the presentation
## (CubeView + WorldView) and the UI. Gameplay logic lives in the domain; this node
## only translates input into domain calls and domain state into view updates.

signal level_loaded(level: Dictionary)
signal solved(level: Dictionary, reward: Dictionary)
signal discovery_found(discovery: Dictionary)
signal reward_granted(reward_id: String, equipment: Dictionary)
signal world_reacted(hook: String, text: String)

var engine := PuzzleEngine.new()
var game_state := GameState.new()
var levels: Array = []
var current_index := 0

var cube_view: CubeView
var world_view: WorldView

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
	current_index = clampi(game_state.current_level_index, 0, levels.size() - 1)
	load_level(current_index)

func load_level(index: int) -> void:
	current_index = clampi(index, 0, levels.size() - 1)
	var lvl: Dictionary = levels[current_index]
	engine.setup(lvl)
	if cube_view:
		cube_view.build(engine.state)
	level_loaded.emit(lvl)

func restart_level() -> void:
	engine.reset()
	if cube_view:
		cube_view.refresh(engine.state)

func try_move(face: String, cw: bool) -> bool:
	var move := MoveTable.face_move(face, cw)
	var applied := engine.apply_move(move)
	if applied and cube_view:
		cube_view.refresh(engine.state)
	return applied

func undo() -> bool:
	var ok := engine.undo()
	if ok and cube_view:
		cube_view.refresh(engine.state)
	return ok

func legal_faces() -> Array:
	var faces := []
	for m in engine.legal_moves():
		if not faces.has(m["face"]):
			faces.append(m["face"])
	return faces

## Called when the player believes the puzzle is solved: verifies against the real
## solve predicate, then drives world reaction -> reward -> progression -> save.
func confirm_solve() -> bool:
	if not engine.is_solved():
		return false
	var lvl: Dictionary = levels[current_index]
	game_state.mark_solved(str(lvl["level_id"]))
	game_state.set_world_flag(str(lvl.get("world_hook", "")))
	var hook := str(lvl.get("world_hook", ""))
	if world_view:
		world_view.react()
	var reaction := StoryContent.reaction_for(hook)
	world_reacted.emit(hook, reaction)

	var reward_id := str(lvl.get("reward_id", ""))
	var reward := StoryContent.reward_for(reward_id)
	if not reward.is_empty():
		var eq := StoryContent.equipment_for(reward_id)
		if not eq.is_empty():
			game_state.grant_equipment(_equipment_id_for_reward(reward_id))
		reward_granted.emit(reward_id, eq)
		solved.emit(lvl, reward)
	else:
		solved.emit(lvl, {})

	# Optional, non-blocking discovery check (chapter-level).
	var disc_id := str(lvl.get("discovery_id", ""))
	if disc_id == StoryContent.DISCOVERY_FIRST_PULSE["id"]:
		if game_state.add_discovery(disc_id):
			discovery_found.emit(StoryContent.DISCOVERY_FIRST_PULSE)

	game_state.current_level_index = current_index
	SaveManager.save_to_path(game_state)
	return true

func _equipment_id_for_reward(reward_id: String) -> String:
	for k in StoryContent.EQUIPMENT.keys():
		if k == "equipment.rootweave_gauntlet" and reward_id == "reward.01.nox_meets":
			return k
	return ""

func next_level() -> bool:
	if current_index + 1 >= levels.size():
		return false
	load_level(current_index + 1)
	return true
