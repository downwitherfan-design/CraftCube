extends SceneTree

## Headless test runner for the CraftCube Godot vertical slice.
## Run:  godot --headless --path game --script res://tests/run_tests.gd
## Exit code 0 = all pass, 1 = at least one failure. No external test framework.

var _passed := 0
var _failed := 0
var _failures: Array = []

func _check(name: String, cond: bool) -> void:
	if cond:
		_passed += 1
	else:
		_failed += 1
		_failures.append(name)
		print("  FAIL: ", name)

func _eq(name: String, a, b) -> void:
	_check("%s (got %s, want %s)" % [name, str(a), str(b)], a == b)

func _initialize() -> void:
	print("== CraftCube domain tests ==")
	_test_geometry()
	_test_moves()
	_test_scramble()
	_test_legal_moves()
	_test_objectives()
	_test_game_state()
	_test_save_load()
	_test_level_catalog()
	_test_end_to_end_solve()
	print("== Summary: %d passed, %d failed ==" % [_passed, _failed])
	for f in _failures:
		print("  - ", f)
	quit(0 if _failed == 0 else 1)

func _solved_fp(n: int) -> String:
	return CubeState.new(n).fingerprint()

func _test_geometry() -> void:
	print("[geometry]")
	var c := CubeState.new(2)
	_check("solved 2x2 face U solid", c.is_face_solid(CubeState.Face.U))
	_check("solved 2x2 all faces solid", c.is_aligned([0, 1, 2, 3, 4, 5]))
	# four quarter turns of one face return to the solved state
	var d := CubeState.new(2)
	var perm := d.turn_permutation(1, 0, true)
	for i in range(4):
		d.apply_permutation(perm)
	_eq("4x quarter-turn is identity (2x2)", d.fingerprint(), _solved_fp(2))
	# a single turn changes the configuration
	var e := CubeState.new(2)
	e.apply_move(MoveTable.face_move("U", true))
	_check("one turn changes state (2x2)", e.fingerprint() != _solved_fp(2))
	# odd size also holds
	var f := CubeState.new(3)
	var p3 := f.turn_permutation(0, 2, false)
	for i in range(4):
		f.apply_permutation(p3)
	_eq("4x quarter-turn is identity (3x3)", f.fingerprint(), _solved_fp(3))

func _test_moves() -> void:
	print("[moves]")
	var c := CubeState.new(3)
	var m := MoveTable.face_move("F", true)
	c.apply_move(m)
	c.apply_move(MoveTable.inverse(m))
	_eq("move then inverse returns to solved", c.fingerprint(), _solved_fp(3))
	# each face has a well-defined axis
	for face in MoveTable.ALL_FACES:
		_check("axis defined for %s" % face, MoveTable.AXIS_OF.has(face))

func _test_scramble() -> void:
	print("[scramble]")
	var lvl := LevelCatalog.by_id("level.01.awaken")
	var e1 := PuzzleEngine.new()
	e1.setup(lvl)
	var e2 := PuzzleEngine.new()
	e2.setup(lvl)
	_eq("same seed => same scramble", e1.state.fingerprint(), e2.state.fingerprint())
	_check("scrambled level is not already solved", not e1.is_solved())
	_check("scramble is solvable (reverse replay)", e1.verify_scramble_solvable())
	# a different seed gives a different configuration
	var lvl2 := lvl.duplicate(true)
	lvl2["scramble"] = {"seed": 999, "depth_hint": 6}
	var e3 := PuzzleEngine.new()
	e3.setup(lvl2)
	_check("different seed => different scramble", e3.state.fingerprint() != e1.state.fingerprint())
	# depth is respected
	_eq("scramble depth respected", e1._scramble_moves.size(), int(lvl["scramble"]["depth_hint"]))

func _test_legal_moves() -> void:
	print("[legal moves]")
	var lvl := LevelCatalog.by_id("level.01.hollow_stone")  # locks the Y axis
	var e := PuzzleEngine.new()
	e.setup(lvl)
	var faces := []
	for mv in e.legal_moves():
		faces.append(mv["face"])
	_check("locked-axis faces are not legal (Y: U/D)",
		not faces.has("U") and not faces.has("D"))
	_check("unlocked-axis faces are legal (X/Z: L/R/F/B)",
		faces.has("L") and faces.has("R") and faces.has("F") and faces.has("B"))
	_check("illegal move is rejected", not e.apply_move(MoveTable.face_move("U", true)))
	_check("legal move is accepted", e.apply_move(MoveTable.face_move("L", true)))

func _test_objectives() -> void:
	print("[objectives]")
	var solved := CubeState.new(2)
	_check("align single face true when solid", solved.is_aligned([0]))
	_check("align empty list false", not solved.is_aligned([]))
	# A side turn (F) disturbs the U face; a U turn alone would not (it only rotates U).
	var c := CubeState.new(2)
	c.apply_move(MoveTable.face_move("F", true))
	_check("align false after a side turn disturbs U", not c.is_aligned([0]))

func _test_game_state() -> void:
	print("[game state]")
	var g := GameState.new()
	g.mark_solved("level.01.awaken")
	_check("solved recorded", g.is_solved("level.01.awaken"))
	_check("discovery added once", g.add_discovery("d1") and not g.add_discovery("d1"))
	_check("equipment granted", g.grant_equipment("equipment.x"))
	_check("equipment auto-equipped within slots", g.is_equipped("equipment.x"))
	# loadout cap (PD-002: <= 4 slots)
	for i in range(6):
		g.grant_equipment("equipment.%d" % i)
	_check("loadout respects MAX_SLOTS", g.loadout.size() <= GameState.MAX_SLOTS)

func _test_save_load() -> void:
	print("[save/load]")
	var path := "user://craftcube_test_save.json"
	var g := GameState.new()
	g.mark_solved("level.01.awaken")
	g.add_discovery("discovery.01.first_pulse")
	g.set_world_flag("mechanism_awakens")
	g.current_level_index = 2
	_check("save writes", SaveManager.save_to_path(g, path))
	var r := SaveManager.load_from_path(path)
	_check("load solved", r.is_solved("level.01.awaken"))
	_check("load discovery", r.discoveries.has("discovery.01.first_pulse"))
	_check("load world flag", r.world_flags.get("mechanism_awakens", false))
	_eq("load current index", r.current_level_index, 2)
	# newer save version is rejected safely
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string('{"save_version": 9999, "solved_levels": ["x"]}')
	f.close()
	var rej := SaveManager.load_from_path(path)
	_check("future save version rejected (fresh state)", not rej.is_solved("x"))
	SaveManager.delete_at_path(path)

func _test_level_catalog() -> void:
	print("[level catalog]")
	var levels := LevelCatalog.chapter_one()
	_eq("chapter 01 has 3 levels", levels.size(), 3)
	for l in levels:
		_check("level %s has objective.align" % l["level_id"],
			str(l["objective"]["family"]) == "objective.align")
		_check("level %s has a world hook" % l["level_id"], str(l.get("world_hook", "")) != "")
	_eq("by_id finds awaken", str(LevelCatalog.by_id("level.01.awaken").get("ordinal", -1)), "1")

func _test_end_to_end_solve() -> void:
	print("[end-to-end solve]")
	for level_id in ["level.01.awaken", "level.01.seed_bed", "level.01.hollow_stone"]:
		var lvl := LevelCatalog.by_id(level_id)
		var e := PuzzleEngine.new()
		e.setup(lvl)
		_check("%s starts unsolved" % level_id, not e.is_solved())
		# solve through legal moves only: replay the scramble in reverse
		var ok := true
		for i in range(e._scramble_moves.size() - 1, -1, -1):
			var inv := MoveTable.inverse(e._scramble_moves[i])
			if not e.apply_move(inv):
				ok = false
				break
		_check("%s solvable via legal moves" % level_id, ok)
		_check("%s is solved after reverse replay" % level_id, e.is_solved())
