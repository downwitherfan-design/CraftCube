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
	_test_geometry_properties()
	_test_save_hardening()
	_test_completion_idempotency()
	_test_level_advancement()
	_test_content_id_consistency()
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

func _test_geometry_properties() -> void:
	print("[geometry properties]")
	# A move is a permutation: applying it preserves the multiset of facelet colours.
	for n in [2, 3, 4]:
		var c := CubeState.new(n)
		var before := _colour_histogram(c)
		c.apply_move(MoveTable.face_move("R", true))
		_eq("permutation preserves colour multiset (n=%d)" % n, _histogram_str(_colour_histogram(c)), _histogram_str(before))
	# Every face turn is order 4, regardless of size or direction.
	for n in [2, 3, 4]:
		for face in MoveTable.ALL_FACES:
			for cw in [true, false]:
				var c := CubeState.new(n)
				var m := MoveTable.face_move(face, cw)
				for i in range(4):
					c.apply_move(m)
				_eq("order-4 turn %s%s (n=%d)" % [face, "cw" if cw else "ccw", n], c.fingerprint(), _solved_fp(n))
	# Inverse is exact: move then inverse restores the prior fingerprint.
	for n in [2, 3, 4]:
		var c := CubeState.new(n)
		c.apply_move(MoveTable.face_move("F", true))
		c.apply_move(MoveTable.face_move("R", false))
		var before := c.fingerprint()
		var m := MoveTable.face_move("U", false)
		c.apply_move(m)
		c.apply_move(MoveTable.inverse(m))
		_eq("inverse restores state (n=%d)" % n, c.fingerprint(), before)
	# Determinism: same move sequence => identical fingerprint.
	var a := CubeState.new(3)
	var b := CubeState.new(3)
	for m in [MoveTable.face_move("R", true), MoveTable.face_move("U", false), MoveTable.face_move("F", true)]:
		a.apply_move(m)
		b.apply_move(m)
	_eq("deterministic move sequence", a.fingerprint(), b.fingerprint())
	# Clone is independent (mutating the clone must not affect the original).
	var o := CubeState.new(3)
	o.apply_move(MoveTable.face_move("L", true))
	var cl := o.clone()
	var fp := o.fingerprint()
	cl.apply_move(MoveTable.face_move("U", true))
	_eq("clone independent of source", o.fingerprint(), fp)

func _test_save_hardening() -> void:
	print("[save hardening]")
	var path := "user://craftcube_hardening_save.json"
	SaveManager.delete_at_path(path)
	_check("missing save loads fresh state", SaveManager.load_from_path(path).solved_levels.is_empty())
	var g := GameState.new()
	g.mark_solved("level.01.awaken")
	g.grant_equipment("equipment.rootweave_gauntlet")
	g.add_discovery("discovery.01.first_pulse")
	g.current_level_index = 1
	_check("atomic save writes", SaveManager.save_to_path(g, path))
	_check("no leftover temp file after save", not FileAccess.file_exists(path + ".tmp"))
	var r := SaveManager.load_from_path(path)
	_check("round trip solved", r.is_solved("level.01.awaken"))
	_check("round trip equipment", r.owns("equipment.rootweave_gauntlet"))
	# Malformed JSON is quarantined and must NOT load as completed progress.
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string("{ this is not json ")
	f.close()
	var bad := SaveManager.load_from_path(path)
	_check("malformed save loads fresh state", not bad.is_solved("level.01.awaken"))
	_check("malformed save quarantined to .corrupt", FileAccess.file_exists(path + ".corrupt"))
	# Wrong-typed fields must not corrupt (string where an array is expected).
	SaveManager.delete_at_path(path)
	var f2 := FileAccess.open(path, FileAccess.WRITE)
	f2.store_string('{"save_version":1,"solved_levels":"x","current_level_index":-5,"loadout":["a","b","c","d","e","f"]}')
	f2.close()
	var coerced := SaveManager.load_from_path(path)
	_check("wrong-typed list coerced to empty", coerced.solved_levels.is_empty())
	_check("negative index clamped to 0", coerced.current_level_index == 0)
	_check("over-cap loadout truncated", coerced.loadout.size() <= GameState.MAX_SLOTS)
	SaveManager.delete_at_path(path)

func _test_completion_idempotency() -> void:
	print("[completion idempotency]")
	var saved := "user://craftcube_save.json"
	var had := FileAccess.file_exists(saved)
	var backup := FileAccess.get_file_as_string(saved) if had else ""
	var gs := GameState.new()
	SaveManager.save_to_path(gs, saved)
	var ctrl := GameController.new()
	ctrl.levels = LevelCatalog.chapter_one()
	ctrl.game_state = SaveManager.load_from_path(saved)
	# Level 2 (seed_bed) carries a reward AND a discovery, so all effects are exercised.
	ctrl.current_index = 1
	ctrl.engine.setup(ctrl.levels[1])
	ctrl.world_view = WorldView.new()
	ctrl.world_view.build()
	for i in range(ctrl.engine._scramble_moves.size() - 1, -1, -1):
		ctrl.engine.apply_move(MoveTable.inverse(ctrl.engine._scramble_moves[i]))
	_check("reverse-replay solves level 2", ctrl.engine.is_solved())
	var reactions := []
	var rewards := []
	var discos := []
	ctrl.world_reacted.connect(func(h, t): reactions.append(h))
	ctrl.reward_granted.connect(func(rid, e): rewards.append(rid))
	ctrl.discovery_found.connect(func(d): discos.append(d))
	_check("first confirm_solve returns true", ctrl.confirm_solve())
	var lit_first := ctrl.world_view.lit_count()
	_check("second confirm_solve is a no-op true", ctrl.confirm_solve())
	_check("world reaction fired exactly once", reactions.size() == 1)
	_check("reward fired exactly once", rewards.size() == 1)
	_check("discovery fired exactly once", discos.size() == 1)
	_eq("no duplicate world marker lit", ctrl.world_view.lit_count(), lit_first)
	ctrl.world_view.free()
	ctrl.free()
	if had:
		var w := FileAccess.open(saved, FileAccess.WRITE)
		w.store_string(backup)
		w.close()
	else:
		SaveManager.delete_at_path(saved)

func _test_level_advancement() -> void:
	print("[level advancement]")
	var gs := GameState.new()
	var levels := LevelCatalog.chapter_one()
	_eq("first unsolved with empty progress", gs.first_unsolved_index(levels), 0)
	gs.mark_solved("level.01.awaken")
	_eq("first unsolved after level 1", gs.first_unsolved_index(levels), 1)
	gs.mark_solved("level.01.seed_bed")
	gs.mark_solved("level.01.hollow_stone")
	_eq("first unsolved when all solved", gs.first_unsolved_index(levels), -1)

func _test_content_id_consistency() -> void:
	print("[content id consistency]")
	for l in LevelCatalog.chapter_one():
		var lid := str(l["level_id"])
		var hook := str(l.get("world_hook", ""))
		var rid := str(l.get("reward_id", ""))
		var did := str(l.get("discovery_id", ""))
		_check("%s world hook resolves" % lid, hook != "" and StoryContent.reaction_for(hook) != "")
		_check("%s reward resolves" % lid, rid != "" and not StoryContent.reward_for(rid).is_empty())
		# A discovery_id, when present, must resolve to a real discovery (catches the
		# 'referenced but undefined' gap). Empty string is allowed (no discovery).
		_check("%s discovery resolves or is empty" % lid,
				did == "" or not StoryContent.discovery_for(did).is_empty())
	# The one reward that grants equipment must resolve to real equipment.
	_check("nox_meets grants resolvable equipment",
			StoryContent.equipment_id_for("reward.01.nox_meets") != ""
			and not StoryContent.equipment_for("reward.01.nox_meets").is_empty())

func _colour_histogram(c: CubeState) -> Dictionary:
	var h := {}
	for v in c.colours:
		h[v] = int(h.get(v, 0)) + 1
	return h

func _histogram_str(h: Dictionary) -> String:
	var keys := h.keys()
	keys.sort()
	var parts := PackedStringArray()
	for k in keys:
		parts.append("%s:%d" % [str(k), h[k]])
	return ",".join(parts)
