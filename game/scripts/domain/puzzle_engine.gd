class_name PuzzleEngine
extends RefCounted

## Deterministic puzzle rules over CubeState: level loading, legal moves, scramble
## generation, solve predicate, and verified solvability. Pure domain; no scenes.

var state: CubeState
var level: Dictionary = {}
var _legal_faces: Array = []
var _move_log: Array = []
var _scramble_moves: Array = []

func setup(level_def: Dictionary) -> void:
	level = level_def
	var topo: String = str(level_def.get("topology_id", "topology.cube.2"))
	state = CubeState.new(_topology_size(topo))
	_legal_faces = _unlocked_faces(level_def)
	_move_log = []
	var seed_value: int = int(level_def.get("scramble", {}).get("seed", 0))
	var depth: int = int(level_def.get("scramble", {}).get("depth_hint", 0))
	_scramble_moves = generate_scramble(seed_value, depth)
	for m in _scramble_moves:
		state.apply_move(m)

func _topology_size(topo: String) -> int:
	match topo:
		"topology.cube.2": return 2
		"topology.cube.3": return 3
		"topology.cube.4": return 4
	return 3

## A level's level_rules restrict *legality*, never truth. rule.axis_lock removes
## the faces whose axis is locked (that axis cannot be twisted in this level).
func _unlocked_faces(level_def: Dictionary) -> Array:
	var locked_axes := []
	for rule in level_def.get("level_rules", []):
		if str(rule.get("rule_id", "")) == "rule.axis_lock":
			for a in rule.get("params", {}).get("axes", []):
				locked_axes.append(_axis_index(str(a)))
	var faces := []
	for f in MoveTable.ALL_FACES:
		if not locked_axes.has(MoveTable.AXIS_OF[f]):
			faces.append(f)
	return faces

func _axis_index(letter: String) -> int:
	match letter:
		"X": return 0
		"Y": return 1
		"Z": return 2
	return -1

## All legal moves as concrete (axis, layer, cw) primitives.
func legal_moves() -> Array:
	var out := []
	for f in _legal_faces:
		for cw in [true, false]:
			var m := MoveTable.face_move(f, cw)
			out.append({"face": f, "axis": m["axis"],
				"layer": MoveTable.resolve_layer(state.n, f, -1), "cw": cw})
	return out

func is_legal(move: Dictionary) -> bool:
	if not _legal_faces.has(str(move.get("face", ""))):
		return false
	return true

func apply_move(move: Dictionary) -> bool:
	if not is_legal(move):
		return false
	state.apply_move(move)
	_move_log.append(move)
	return true

func undo() -> bool:
	if _move_log.is_empty():
		return false
	var m: Dictionary = _move_log.pop_back()
	state.apply_move(MoveTable.inverse(m))
	return true

func move_count() -> int:
	return _move_log.size()

func reset() -> void:
	state.reset()
	for m in _scramble_moves:
		state.apply_move(m)
	_move_log = []

## Objective: objective.align {faces:[...]} => all listed faces solid.
func is_solved() -> bool:
	var obj: Dictionary = level.get("objective", {})
	var family: String = str(obj.get("family", ""))
	var params: Dictionary = obj.get("params", {})
	match family:
		"objective.align":
			return state.is_aligned(_face_indices(params.get("faces", [])))
	return false

## How many of the objective's required faces are currently solid, so the UI can show
## progress instead of only a binary solved flag.
func objective_progress() -> Dictionary:
	var obj: Dictionary = level.get("objective", {})
	if str(obj.get("family", "")) != "objective.align":
		return {"aligned": 0, "total": 0}
	var faces := _face_indices(obj.get("params", {}).get("faces", []))
	var aligned := 0
	for idx in faces:
		if state.is_face_solid(int(idx)):
			aligned += 1
	return {"aligned": aligned, "total": faces.size()}

func _face_indices(letters: Array) -> Array:
	var out := []
	for l in letters:
		var idx := MoveTable.ALL_FACES.find(str(l))
		if idx >= 0:
			out.append(idx)
	return out

## Deterministic scramble: seeded RNG, no move cancels the previous one, and the
## resulting configuration is guaranteed not already solved. Scrambles use only
## legal faces so every level stays reachable under its own rules. Retries by
## advancing the seed until a non-solved configuration is produced (bounded).
func generate_scramble(seed_value: int, depth: int) -> Array:
	var s := seed_value
	for _attempt in range(64):
		var moves := _scramble_with_seed(s, depth)
		if moves.is_empty():
			return []
		var probe := CubeState.new(state.n)
		for m in moves:
			probe.apply_move(m)
		if not _probe_solved(probe):
			return moves
		s += 1
	push_warning("generate_scramble: no non-solved scramble found; returning last attempt")
	return _scramble_with_seed(s, depth)

func _scramble_with_seed(seed_value: int, depth: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var moves := []
	var last_face := ""
	var attempts := 0
	while moves.size() < depth and attempts < depth * 8:
		attempts += 1
		if _legal_faces.is_empty():
			return []
		var f: String = _legal_faces[rng.randi_range(0, _legal_faces.size() - 1)]
		if f == last_face and _legal_faces.size() > 1:
			continue  # avoid a same-face pair that is just a 2-turn
		var cw := rng.randf() < 0.5
		moves.append({"face": f, "axis": MoveTable.AXIS_OF[f],
			"layer": MoveTable.resolve_layer(state.n, f, -1), "cw": cw})
		last_face = f
	return moves

func _probe_solved(probe: CubeState) -> bool:
	var obj: Dictionary = level.get("objective", {})
	if str(obj.get("family", "")) != "objective.align":
		return false
	for idx in _face_indices(obj.get("params", {}).get("faces", [])):
		if not probe.is_face_solid(int(idx)):
			return false
	return true

## A scramble is solvable if replaying every move in reverse restores the solved
## state exactly (deterministic proof, no external solver required).
func verify_scramble_solvable() -> bool:
	var probe := CubeState.new(state.n)
	for m in _scramble_moves:
		probe.apply_move(m)
	for i in range(_scramble_moves.size() - 1, -1, -1):
		probe.apply_move(MoveTable.inverse(_scramble_moves[i]))
	for i in range(probe.colours.size()):
		if probe.colours[i] != i / (probe.n * probe.n):
			return false
	return true
