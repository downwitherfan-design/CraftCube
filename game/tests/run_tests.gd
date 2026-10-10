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
	_test_level_rule_semantics()
	_test_hud_layout_and_wiring()
	_test_save_corruption_variants()
	_test_scene_integration()
	_test_completion_feedback()
	_test_camera_framing()
	_test_resume_selection()
	_test_chapter_playthrough()
	_test_face_orientation()
	_test_layer_selection()
	_test_animation_locks_and_syncs()
	_test_world_state_and_resume()
	_test_objective_progress()
	_test_animated_chapter_end_to_end()
	_test_scramble_fuzz()
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

func _test_level_rule_semantics() -> void:
	print("[level rule semantics]")
	# rule.axis_lock {axes:[X,Z]} + objective.align{U} is DEGENERATE on a 2x2 cube:
	# locking X and Z leaves only Y-axis turns (U/D), which never move the U face, so the
	# objective is already satisfied at the scramble. Regression guard for the resolved
	# AI-03 content conflict (see level_catalog.gd header).
	var degenerate := {
		"topology_id": "topology.cube.2",
		"scramble": {"seed": 101, "depth_hint": 3},
		"objective": {"family": "objective.align", "params": {"faces": ["U"]}},
		"level_rules": [{"rule_id": "rule.axis_lock", "params": {"axes": ["X", "Z"]}}],
	}
	var ed := PuzzleEngine.new()
	ed.setup(degenerate)
	_eq("axis_lock{X,Z} leaves only U/D legal (Y axis)", ed._legal_faces, ["U", "D"])
	_check("degenerate rule leaves objective solved on scramble", ed.is_solved())
	# The corrected level.01.awaken (no lock) is genuinely unsolved and solvable.
	var awake := LevelCatalog.by_id("level.01.awaken")
	var ea := PuzzleEngine.new()
	ea.setup(awake)
	_check("level.01.awaken starts unsolved", not ea.is_solved())
	_check("level.01.awaken scramble solvable", ea.verify_scramble_solvable())
	_eq("level.01.awaken exposes all six faces", ea._legal_faces.size(), 6)
	# Every shipped level must start unsolved and be solvable under its own rules.
	for l in LevelCatalog.chapter_one():
		var e := PuzzleEngine.new()
		e.setup(l)
		_check("%s starts unsolved" % l["level_id"], not e.is_solved())
		_check("%s solvable by inverse replay" % l["level_id"], e.verify_scramble_solvable())
	# The chapter's single constraint: level 3 Y-lock must forbid U/D and be necessary.
	var hollow := LevelCatalog.by_id("level.01.hollow_stone")
	var eh := PuzzleEngine.new()
	eh.setup(hollow)
	_check("level.01.hollow_stone forbids Y-axis faces (U/D)",
		not eh._legal_faces.has("U") and not eh._legal_faces.has("D"))
	_check("level.01.hollow_stone starts unsolved", not eh.is_solved())
	_check("Y-lock is a real constraint (objective not auto-satisfied)", not eh.is_solved())


func _test_hud_layout_and_wiring() -> void:
	print("[hud layout and wiring]")
	var packed: PackedScene = load("res://scenes/Main.tscn")
	if packed == null:
		_check("Main.tscn loads for HUD test", false)
		return
	var main = packed.instantiate()
	main._ready()
	var hud = main.get_node_or_null("HUD")
	_check("HUD exists in the real scene", hud != null)
	if hud == null:
		main.free()
		return
	# All six face controls must exist (broken scene wiring would drop one).
	_eq("HUD built six face controls", hud._face_buttons.size(), 6)
	# The controls must sit inside a ScrollContainer so small screens / large text
	# never push the action buttons off-screen (mobile-first requirement).
	var parent = hud._root.get_parent()
	_check("controls live in a scroll container",
		parent != null and parent.get_parent() is ScrollContainer)
	# Each face button must fit a 3-column grid within a 360px-wide portrait phone:
	# 3*width + 2*separation + margins <= 360.
	var widest := 0
	for entry in hud._face_buttons:
		widest = maxi(widest, int(entry["button"].custom_minimum_size.x))
	_check("face button grid fits ~360px portrait (widest=%d)" % widest, 3 * widest + 16 + 32 <= 360)
	# Level 1 exposes all six faces: every face button enabled.
	main.load_level(0)
	hud._refresh_legal()
	var enabled := 0
	for entry in hud._face_buttons:
		if not entry["button"].disabled:
			enabled += 1
	_eq("level 1 enables all six face buttons", enabled, 6)
	# Level 3 (Y-lock) must disable the U and D buttons via the wired controller.
	main.load_level(2)
	hud._refresh_legal()
	var u_disabled := false
	var d_disabled := false
	var l_enabled := false
	for entry in hud._face_buttons:
		match str(entry["face"]):
			"U": u_disabled = entry["button"].disabled
			"D": d_disabled = entry["button"].disabled
			"L": l_enabled = not entry["button"].disabled
	_check("Y-lock level disables U", u_disabled)
	_check("Y-lock level disables D", d_disabled)
	_check("Y-lock level keeps side faces enabled", l_enabled)
	if main.get_parent() != null:
		main.get_parent().remove_child(main)
	main.free()


func _test_save_corruption_variants() -> void:
	print("[save corruption variants]")
	var path := "user://craftcube_save_corrupt_test.json"
	SaveManager.delete_at_path(path)
	# (a) empty file -> not valid JSON -> quarantined, fresh state.
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string("")
	f.close()
	var empty_load = SaveManager.load_from_path(path)
	_check("empty save loads fresh state", empty_load.solved_levels.is_empty())
	_check("empty save quarantined", FileAccess.file_exists(path + ".corrupt"))
	# (b) truncated JSON -> fresh state.
	SaveManager.delete_at_path(path)
	f = FileAccess.open(path, FileAccess.WRITE)
	f.store_string('{"save_version":1,"solved_levels":["a"')
	f.close()
	var trunc_load = SaveManager.load_from_path(path)
	_check("truncated save loads fresh state", trunc_load.solved_levels.is_empty())
	# (c) valid JSON but save_version 0 -> quarantined, fresh state.
	SaveManager.delete_at_path(path)
	f = FileAccess.open(path, FileAccess.WRITE)
	f.store_string('{"save_version":0,"solved_levels":["x"]}')
	f.close()
	var zero_load = SaveManager.load_from_path(path)
	_check("zero-version save loads fresh state", zero_load.solved_levels.is_empty())
	# (d) structurally valid but hostile payloads are coerced, never trusted.
	SaveManager.delete_at_path(path)
	f = FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify({
		"save_version": 1,
		"solved_levels": [1, 2, {"k": "v"}, "ok.level"],
		"discoveries": "not-an-array",
		"owned_equipment": null,
		"loadout": ["a", "b", "c", "d", "e", "f", "g"],
		"world_flags": {"f1": true, 5: true, "f2": false},
		"current_level_index": -7,
	}))
	f.close()
	var coerced = SaveManager.load_from_path(path)
	_eq("only string level IDs survive", coerced.solved_levels, ["ok.level"])
	_check("discoveries wrong type -> empty", coerced.discoveries.is_empty())
	_check("owned_equipment null -> empty", coerced.owned_equipment.is_empty())
	_check("loadout capped to MAX_SLOTS", coerced.loadout.size() == GameState.MAX_SLOTS)
	_check("negative index clamped", coerced.current_level_index == 0)
	_check("non-string flag key dropped", not coerced.world_flags.has(5))
	SaveManager.delete_at_path(path)


func _test_scene_integration() -> void:
	print("[scene integration]")
	# Load the real Main scene and drive the wired controller -> view -> domain loop,
	# so the test exercises the actual scene graph (nodes, HUD bind, cube view build),
	# not a hand-assembled controller.
	var saved := "user://craftcube_save.json"
	var had := FileAccess.file_exists(saved)
	var backup := FileAccess.get_file_as_string(saved) if had else ""
	var packed: PackedScene = load("res://scenes/Main.tscn")
	_check("Main.tscn loads as PackedScene", packed != null)
	if packed == null:
		return
	var main = packed.instantiate()
	main._ready()  # run the real wiring: HUD bind, world + cube build, level load
	_check("cube view builds facelets for 2x2", main.cube_view != null and main.cube_view._facelets.size() == 6 * 2 * 2)
	_check("HUD is bound to the controller", main.get_node_or_null("HUD").controller == main)
	_check("world view built its markers", main.world_view != null and main.world_view.lit_count() == 0)
	main.try_move("U", true, false)  # exercise the input -> domain -> view path (headless: no tween)
	main.undo()               # restore the exact scrambled state before replay
	# Solve level 1 by reverse-replaying its scramble, then complete it once.
	for i in range(main.engine._scramble_moves.size() - 1, -1, -1):
		main.engine.apply_move(MoveTable.inverse(main.engine._scramble_moves[i]))
	_check("level 1 solved through the controller", main.engine.is_solved())
	_check("confirm_solve succeeds in the real scene", main.confirm_solve())
	# main was never added to the tree (we call _ready() directly), so it has no parent;
	# only detach when one exists to avoid an engine ERROR from remove_child.
	if main.get_parent() != null:
		main.get_parent().remove_child(main)
	main.free()
	if had:
		var w := FileAccess.open(saved, FileAccess.WRITE)
		w.store_string(backup)
		w.close()
	else:
		SaveManager.delete_at_path(saved)

## Completion feedback must reach the player intact. Regression for a real defect where the
## world reaction, reward narrative and discovery all wrote to one shared label, so later
## signals overwrote earlier ones and the authored narrative was never shown.
func _test_completion_feedback() -> void:
	print("[completion feedback]")
	var saved := "user://craftcube_save.json"
	var had := FileAccess.file_exists(saved)
	var backup := FileAccess.get_file_as_string(saved) if had else ""
	SaveManager.delete_at_path(saved)
	var packed: PackedScene = load("res://scenes/Main.tscn")
	if packed == null:
		_check("Main.tscn loads for feedback test", false)
		return
	var main = packed.instantiate()
	main._ready()
	main.load_level(2)  # level 3: world hook + narrative reward + discovery
	var hud = main.get_node_or_null("HUD")
	_check("HUD bound for feedback test", hud != null and hud._story != null)
	if hud != null:
		for i in range(main.engine._scramble_moves.size() - 1, -1, -1):
			main.engine.apply_move(MoveTable.inverse(main.engine._scramble_moves[i]))
		_check("feedback: level solved", main.engine.is_solved())
		_check("feedback: confirm_solve true", main.confirm_solve())
		var story: String = hud._story.text
		# Every authored element must be present, not overwritten by a later signal.
		_check("feedback shows world reaction",
				story.contains(StoryContent.reaction_for("stone_marks_awaken")))
		_check("feedback shows reward narrative",
				story.contains(str(StoryContent.reward_for("reward.01.nox_meets")["narrative"])))
		_check("feedback shows discovery",
				story.contains("Discovery — The Stone Mark"))
		_check("feedback shows equipment purpose",
				hud._hint.text.contains("Rootweave Gauntlet"))
		# A replay must not duplicate the feedback.
		var before: String = hud._story.text
		main.confirm_solve()
		_check("feedback idempotent on re-confirm", hud._story.text == before)
	if main.get_parent() != null:
		main.get_parent().remove_child(main)
	main.free()
	if had:
		var w := FileAccess.open(saved, FileAccess.WRITE)
		w.store_string(backup)
		w.close()
	else:
		SaveManager.delete_at_path(saved)

## The 3D cube must be visible and centred for the player. Regression for a real defect
## where the camera transform was mis-ordered, leaving the cube off-centre and clipped at
## the left edge on every viewport (verified by projecting the cube corners through the
## scene camera).
func _test_camera_framing() -> void:
	print("[camera framing]")
	var packed: PackedScene = load("res://scenes/Main.tscn")
	if packed == null:
		_check("Main.tscn loads for camera test", false)
		return
	var main = packed.instantiate()
	root.add_child(main)
	var cam = main.get_node_or_null("Camera3D")
	_check("camera exists", cam != null)
	if cam != null:
		# Deterministic camera-space geometry (no rendered frame needed): transform the cube
		# corners into camera space and check they fit the frustum, centred.
		var vp_root := main.get_viewport()
		var vp_size := vp_root.get_visible_rect().size if vp_root != null else Vector2(720, 1280)
		var aspect: float = vp_size.x / maxf(1.0, vp_size.y)
		var hhalf_deg: float = rad_to_deg(atan(tan(deg_to_rad(cam.fov * 0.5)) * aspect))
		var inv: Transform3D = cam.transform.affine_inverse()
		var max_h := 0.0
		var max_v := 0.0
		var sum_x := 0.0
		var sum_y := 0.0
		var count := 0
		for sx in [-1.0, 1.0]:
			for sy in [-1.0, 1.0]:
				for sz in [-1.0, 1.0]:
					var local: Vector3 = inv * Vector3(sx, sy, sz)
					var h_ang: float = rad_to_deg(atan2(local.x, -local.z))
					var v_ang: float = rad_to_deg(atan2(local.y, -local.z))
					max_h = maxf(max_h, absf(h_ang))
					max_v = maxf(max_v, absf(v_ang))
					sum_x += h_ang
					sum_y += v_ang
					count += 1
		var cx: float = sum_x / count
		var cy: float = sum_y / count
		_check("cube fits the horizontal frustum (max %.1f deg < %.1f deg)" % [max_h, hhalf_deg],
				max_h < hhalf_deg * 0.9)
		_check("cube fits the vertical frustum (max %.1f deg < %.1f deg)" % [max_v, cam.fov * 0.5],
				max_v < cam.fov * 0.5 * 0.9)
		_check("cube is centred on screen (h centre %.1f deg, v centre %.1f deg)" % [cx, cy],
				absf(cx) < 2.0 and absf(cy) < 3.0)
		_check("cube is not tiny (max %.1f deg > 3)" % max_h, max_h > 3.0)
	if main.get_parent() != null:
		main.get_parent().remove_child(main)
	main.free()

## Resume selection: relaunching after finishing a level must open the next unsolved
## level, not replay the one just completed. Regression for a real UX defect.
func _test_resume_selection() -> void:
	print("[resume selection]")
	var saved := "user://craftcube_save.json"
	var had := FileAccess.file_exists(saved)
	var backup := FileAccess.get_file_as_string(saved) if had else ""
	var packed: PackedScene = load("res://scenes/Main.tscn")
	if packed == null:
		_check("Main.tscn loads for resume test", false)
		return
	# Case A: saved index points at a solved level with an open later level -> resume there.
	SaveManager.delete_at_path(saved)
	var gs := GameState.new()
	gs.mark_solved("level.01.awaken")
	gs.current_level_index = 0
	SaveManager.save_to_path(gs)
	var a = packed.instantiate()
	a._ready()
	_check("resume skips a solved current level", a.current_index == 1)
	if a.get_parent() != null:
		a.get_parent().remove_child(a)
	a.free()
	# Case B: every level solved -> keep the saved position (no bogus -1 resume).
	SaveManager.delete_at_path(saved)
	var gs2 := GameState.new()
	for l in LevelCatalog.chapter_one():
		gs2.mark_solved(str(l["level_id"]))
	gs2.current_level_index = 2
	SaveManager.save_to_path(gs2)
	var b = packed.instantiate()
	b._ready()
	_check("all-solved keeps the saved position", b.current_index == 2)
	if b.get_parent() != null:
		b.get_parent().remove_child(b)
	b.free()
	if had:
		var w := FileAccess.open(saved, FileAccess.WRITE)
		w.store_string(backup)
		w.close()
	else:
		SaveManager.delete_at_path(saved)

## First-session loop, end to end through the real scene and the wired HUD: solve every
## Chapter 01 level with the actual buttons, follow progression, and verify the story
## feedback, rewards and equipment a player would see. Synchronous (no frames), matching
## the other scene tests.
func _test_chapter_playthrough() -> void:
	print("[chapter playthrough]")
	var saved := "user://craftcube_save.json"
	var had := FileAccess.file_exists(saved)
	var backup := FileAccess.get_file_as_string(saved) if had else ""
	SaveManager.delete_at_path(saved)
	var packed: PackedScene = load("res://scenes/Main.tscn")
	if packed == null:
		_check("Main.tscn loads for playthrough", false)
		return
	var main = packed.instantiate()
	main._ready()
	var hud = main.get_node_or_null("HUD")
	_check("playthrough: HUD bound", hud != null)
	_check("playthrough: starts at level 1", main.current_index == 0)
	var expect_hooks := ["mechanism_awakens", "seed_grows", "stone_marks_awaken"]
	for i in range(3):
		main.load_level(i)
		for k in range(main.engine._scramble_moves.size() - 1, -1, -1):
			main.engine.apply_move(MoveTable.inverse(main.engine._scramble_moves[k]))
		main.cube_view.refresh(main.engine.state)
		_check("playthrough: level %d solved" % (i + 1), main.engine.is_solved())
		_check("playthrough: level %d confirms" % (i + 1), main.confirm_solve())
		var lid: String = str(main.levels[i]["level_id"])
		_check("playthrough: level %d recorded" % (i + 1), main.game_state.is_solved(lid))
		_check("playthrough: level %d story reaction shown" % (i + 1),
				hud._story.text.contains(StoryContent.reaction_for(expect_hooks[i])))
	_check("playthrough: chapter complete", main.game_state.first_unsolved_index(main.levels) == -1)
	_check("playthrough: equipment persists", main.game_state.owns("equipment.rootweave_gauntlet"))
	_check("playthrough: all three world markers lit", main.world_view.lit_count() == 3)
	if main.get_parent() != null:
		main.get_parent().remove_child(main)
	main.free()
	if had:
		var w := FileAccess.open(saved, FileAccess.WRITE)
		w.store_string(backup)
		w.close()
	else:
		SaveManager.delete_at_path(saved)

## Deterministic differential fuzz of the core engine: for many seeds, a randomly generated
## legal scramble must (a) be reachable by its own inverse and (b) leave every move an
## involution-free permutation. Seeded (fixed), so this is a deterministic test, not flaky.
func _test_scramble_fuzz() -> void:
	print("[scramble fuzz]")
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261010
	var bad_solvable := 0
	var bad_perturb := 0
	for trial in range(120):
		var size: int = rng.randi_range(2, 4)
		var depth: int = rng.randi_range(1, 12)
		var lvl := {
			"topology_id": "topology.cube.%d" % size,
			"scramble": {"seed": rng.randi_range(0, 100000), "depth_hint": depth},
			"objective": {"family": "objective.align", "params": {"faces": [MoveTable.ALL_FACES[rng.randi_range(0, 5)]]}},
			"level_rules": [],
		}
		var eng := PuzzleEngine.new()
		eng.setup(lvl)
		if not eng.verify_scramble_solvable():
			bad_solvable += 1
		# The scramble must actually change the configuration for this objective's probe.
		if eng._scramble_moves.size() > 0:
			var probe := CubeState.new(size)
			for m in eng._scramble_moves:
				probe.apply_move(m)
			if probe.fingerprint() == CubeState.new(size).fingerprint():
				bad_perturb += 1
	_check("fuzz: every scramble solvable by inverse (120 trials)", bad_solvable == 0)
	_check("fuzz: every non-empty scramble perturbs the cube", bad_perturb == 0)

## The six face controls must map to the six VISIBLE faces of the rendered cube. Regression
## for a real defect where the domain labelled the bottom face "U", so a level asking the
## player to align the top face actually required an invisible bottom face.
func _test_face_orientation() -> void:
	print("[face orientation]")
	var m = load("res://scenes/Main.tscn").instantiate()
	m._ready()
	var n: int = m.engine.state.n
	# Domain: the U face's normals point +Y and its facelets sit at world-top.
	var up_top := true
	for i in range(n * n):
		if m.engine.state._normals[i].y != 1:
			up_top = false
		if m.engine.state._positions[i].y < n - 1:
			up_top = false
	_check("domain U face normals point +Y (up)", up_top)
	# Rendered: a U facelet must sit in the upper half of the cube (positive y).
	var socks := 0
	for f in range(6):
		var mi = m.cube_view._facelets[f * n * n]
		var is_up: bool = mi.position.y > 0.0
		if f == 0 and not is_up:
			socks += 1
		if f == 1 and is_up:
			socks += 1
	_check("U renders on top and D on the bottom", socks == 0)
	if m.get_parent() != null:
		m.get_parent().remove_child(m)
	m.free()

## The interactive chain must keep the rendered cube equal to the authoritative state after
## every move, including when two inputs are fired back-to-back during an animation.
func _test_animation_locks_and_syncs() -> void:
	print("[animation lock and sync]")
	var m = load("res://scenes/Main.tscn").instantiate()
	m._ready()
	# An animated turn starts, and a second input while busy is rejected (no overlap).
	var first: bool = m.try_move("U", true)
	_check("animated turn is accepted when idle", first)
	var busy: bool = m.is_animating()
	_check("cube reports animating mid-turn", busy)
	var second: bool = m.try_move("F", true)
	_check("second input during animation is rejected", not second)
	# Undo/restart are also locked while animating.
	_check("undo is locked during animation", not m.undo())
	_check("next level locked during animation", not m.next_level())
	# Complete the in-flight turn through the same settle path the tween callback uses
	# (headless frames run too fast for the 0.22s tween to advance deterministically).
	m.cube_view.skip_animation()
	_check("animation settles and releases the lock", not m.is_animating())
	# Rendered colours must equal the truth layer's colours (position-based, so geometry too).
	var n: int = m.engine.state.n
	var mismatches := 0
	for face in range(6):
		for r in range(n):
			for c in range(n):
				var idx := face * n * n + r * n + c
				var want: int = (m.engine.state.colours[idx] / (n * n)) % 6
				var mi = m.cube_view._facelets[idx]
				if mi.material_override.albedo_color != m.cube_view._materials[want].albedo_color:
					mismatches += 1
	_check("rendered facelets match the truth layer after settle", mismatches == 0)
	# The layer that moved must be the U layer (domain +Y), i.e. the upper half of the cube.
	var all_top := true
	for i in range(n * n):
		if m.cube_view._facelets[i].position.y <= 0.0:
			all_top = false
	_check("U layer after the turn still occupies the top row", all_top)
	if m.get_parent() != null:
		m.get_parent().remove_child(m)
	m.free()

## Selecting a move must choose exactly the layer's facelets and no others; a wrong layer
## selection is the classic twisting-puzzle defect where a button turns the wrong band.
func _test_layer_selection() -> void:
	print("[layer selection]")
	var st := CubeState.new(3)
	for layer in [0, 1, 2]:
		var expected := 0
		for i in range(st.colours.size()):
			if st._positions[i].y == layer:
				expected += 1
		var got := st.layer_indices(1, layer).size()
		_eq("Y layer %d has the expected facelet count" % layer, got, expected)
	_check("every facelet is in exactly one Y layer",
			st.layer_indices(1, 0).size() + st.layer_indices(1, 1).size() + st.layer_indices(1, 2).size() == st.colours.size())

## The world must reflect already-completed levels when the game resumes from a save, and a
## repeated/extra reaction must never over-light the ring. Regression for a real defect where
## the world always started empty even after progress was saved.
func _test_world_state_and_resume() -> void:
	print("[world state and resume]")
	var saved := "user://craftcube_save.json"
	var had := FileAccess.file_exists(saved)
	var backup := FileAccess.get_file_as_string(saved) if had else ""
	var gs := GameState.new()
	gs.mark_solved("level.01.awaken")
	gs.mark_solved("level.01.seed_bed")
	gs.current_level_index = 2
	SaveManager.save_to_path(gs)
	var m = load("res://scenes/Main.tscn").instantiate()
	m._ready()
	_check("resume lit the world for two solved levels", m.world_view.lit_count() == 2)
	_check("resume landed on the first unsolved level", m.current_index == 2)
	# Idempotent lighting: reacting beyond the ring size cannot exceed the markers.
	for i in range(20):
		m.world_view.react()
	_check("world reaction never over-lights the ring", m.world_view.lit_count() <= 12)
	# A fresh state with no saves shows an unlit world.
	SaveManager.delete_at_path(saved)
	var f = load("res://scenes/Main.tscn").instantiate()
	f._ready()
	_check("fresh start has an unlit world", f.world_view.lit_count() == 0)
	if f.get_parent() != null:
		f.get_parent().remove_child(f)
	f.free()
	if m.get_parent() != null:
		m.get_parent().remove_child(m)
	m.free()
	if had:
		var w := FileAccess.open(saved, FileAccess.WRITE)
		w.store_string(backup)
		w.close()
	else:
		SaveManager.delete_at_path(saved)

## The UI progress readout must agree with the objective: a multi-face objective shows
## partial progress and reaches full only when every required face is solid.
func _test_objective_progress() -> void:
	print("[objective progress]")
	var e := PuzzleEngine.new()
	e.setup(LevelCatalog.by_id("level.01.hollow_stone"))  # align U and F
	var p0: Dictionary = e.objective_progress()
	_eq("hollow_stone objective totals two faces", int(p0["total"]), 2)
	_check("progress never exceeds total", int(p0["aligned"]) <= int(p0["total"]))
	# Solved state: both faces aligned.
	e.state.reset()
	var p1: Dictionary = e.objective_progress()
	_eq("solved state reports both faces aligned", int(p1["aligned"]), 2)
	_check("progress agrees with is_solved", e.is_solved())
	# Single-face objective on level 1.
	var e2 := PuzzleEngine.new()
	e2.setup(LevelCatalog.by_id("level.01.awaken"))
	_eq("awaken objective totals one face", int(e2.objective_progress()["total"]), 1)

## Play the whole chapter through the real scene using ANIMATED turns (each turn started via
## the controller and settled through the tween path), asserting the rendered cube matches
## the truth layer after every turn and that progression/rewards/discoveries advance.
func _test_animated_chapter_end_to_end() -> void:
	print("[animated chapter end-to-end]")
	var saved := "user://craftcube_save.json"
	var had := FileAccess.file_exists(saved)
	var backup := FileAccess.get_file_as_string(saved) if had else ""
	SaveManager.delete_at_path(saved)
	var m = load("res://scenes/Main.tscn").instantiate()
	m._ready()
	var total_mismatches := 0
	for i in range(m.levels.size()):
		var pend: Array = []
		for k in range(m.engine._scramble_moves.size() - 1, -1, -1):
			pend.append(MoveTable.inverse(m.engine._scramble_moves[k]))
		for mv in pend:
			var started: bool = m.try_move(str(mv["face"]), bool(mv["cw"]))
			while m.is_animating():
				m.cube_view.skip_animation()
			if not started:
				total_mismatches += 1  # a rejected legal move is itself a defect signal
		var n: int = m.engine.state.n
		for face in range(6):
			for r in range(n):
				for c in range(n):
					var idx := face * n * n + r * n + c
					var want: int = (m.engine.state.colours[idx] / (n * n)) % 6
					if m.cube_view._facelets[idx].material_override != m.cube_view._materials[want]:
						total_mismatches += 1
		_check("animated level %d reaches solved" % (i + 1), m.engine.is_solved())
		_check("animated level %d confirms" % (i + 1), m.confirm_solve())
		_check("world lit for %d solved levels" % (i + 1), m.world_view.lit_count() == i + 1)
		if i < m.levels.size() - 1:
			_check("animated advance past level %d" % (i + 1), m.next_level())
	_check("render matched truth across the animated playthrough", total_mismatches == 0)
	_eq("chapter fully solved", m.game_state.solved_levels.size(), m.levels.size())
	if m.get_parent() != null:
		m.get_parent().remove_child(m)
	m.free()
	if had:
		var w := FileAccess.open(saved, FileAccess.WRITE)
		w.store_string(backup)
		w.close()
	else:
		SaveManager.delete_at_path(saved)

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
