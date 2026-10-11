extends SceneTree

## Headless test runner for the CraftCube Godot vertical slice.
## Run:  godot --headless --path game --script res://tests/run_tests.gd
## Exit code 0 = all pass, 1 = at least one failure. No external test framework.

var _passed := 0
var _failed := 0
var _failures: Array = []

## The default player save. The suite is isolated from it: the file is set aside before any
## test runs and restored afterwards, so a developer's (or a previous run's) progress can
## never make the results depend on ambient state.
const DEFAULT_SAVE := "user://craftcube_save.json"
var _ambient_had := false
var _ambient_backup := ""

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
	_ambient_had = FileAccess.file_exists(DEFAULT_SAVE)
	if _ambient_had:
		_ambient_backup = FileAccess.get_file_as_string(DEFAULT_SAVE)
	SaveManager.delete_at_path(DEFAULT_SAVE)
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
	_test_orbit_camera()
	_test_resume_selection()
	_test_chapter_playthrough()
	_test_face_orientation()
	_test_layer_selection()
	_test_animation_locks_and_syncs()
	_test_world_state_and_resume()
	_test_world_progression_landmarks()
	_test_objective_progress()
	_test_face_readiness()
	_test_hud_readiness_line()
	_test_equipment_capability()
	_test_hud_resonance_line()
	_test_settings_persistence()
	_test_hud_big_text_persistence()
	_test_progress_flush_on_exit()
	_test_reduced_motion_persistence()
	_test_version_single_source_of_truth()
	_test_hud_version_label()
	_test_animated_chapter_end_to_end()
	_test_guided_solver_domain()
	_test_guided_solver_controller()
	_test_hud_status_text()
	_test_scramble_fuzz()
	# EPIC 0.3 additions
	_test_chapter_campaign_levels()
	_test_3x3_rendered_sync()
	_test_mastery_ratings()
	_test_best_result_persistence()
	_test_save_v1_migration()
	_test_campaign_unlock_rules()
	_test_app_shell_navigation()
	_test_app_campaign_flow()
	_test_journal_visibility()
	_test_nox_interaction()
	_test_world_sigil()
	# EPIC 0.4 additions
	_test_interaction_arbiter()
	_test_hud_compact_and_completion()
	# EPIC 0.4 Milestone D additions
	_test_world_choices()
	_test_save_v2_to_v3_migration()
	_test_equipment_use_loop()
	# EPIC 0.4 Milestone E additions (gameplay audio)
	_test_audio_director_cues()
	_test_audio_event_wiring()
	_test_audio_settings_persistence()
	# EPIC 0.4 Milestone F additions (world item loop)
	_test_world_cache_item_loop()
	_test_veiled_mark_item_use()
	_test_item_loop_persistence()
	_restore_ambient_save()
	print("== Summary: %d passed, %d failed ==" % [_passed, _failed])
	for f in _failures:
		print("  - ", f)
	quit(0 if _failed == 0 else 1)

## Put the player's save back exactly as it was before the run.
func _restore_ambient_save() -> void:
	if _ambient_had:
		var w := FileAccess.open(DEFAULT_SAVE, FileAccess.WRITE)
		w.store_string(_ambient_backup)
		w.close()
	else:
		SaveManager.delete_at_path(DEFAULT_SAVE)

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
	_eq("chapter 01 has 6 levels", levels.size(), 6)
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
	for l in levels:
		gs.mark_solved(str(l["level_id"]))
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
	# Unlock it through real progression (solve levels 1 and 2) so the gate is satisfied.
	main.game_state.mark_solved("level.01.awaken")
	main.game_state.mark_solved("level.01.seed_bed")
	_check("level 3 loads once its prerequisites are solved", main.load_level(2))
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
	# Deterministic: this test asserts a freshly-built world starts unlit, so it must not
	# depend on whatever save happens to be on disk. Remove it and restore afterwards.
	SaveManager.delete_at_path(saved)
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
	# Unlock level 3 through real progression, then load it (world hook + reward + discovery).
	main.game_state.mark_solved("level.01.awaken")
	main.game_state.mark_solved("level.01.seed_bed")
	_check("feedback: level 3 loads after prerequisites", main.load_level(2))
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
	main._ready()  # camera transform is computed at runtime by OrbitCamera._ready
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

## Milestone B: the interactive camera must genuinely change the rendered transform, respect
## its bounds, reset to a readable default, and never be driven by a HUD button tap.
func _test_orbit_camera() -> void:
	print("[orbit camera]")
	var m = load("res://scenes/Main.tscn").instantiate()
	root.add_child(m)
	m._ready()
	var cam = m.get_node_or_null("Camera3D")
	_check("orbit camera is wired into the scene", cam != null)
	if cam == null:
		m.free()
		return
	_check("camera starts at default distance", absf(cam.get_distance() - 7.3) < 0.01)
	var default_pos: Vector3 = cam.transform.origin
	var default_basis: Basis = cam.transform.basis
	cam.orbit(0.5, 0.0)
	for _i in range(40):
		cam._process(0.05)
	_check("horizontal orbit changes the camera position", cam.transform.origin.distance_to(default_pos) > 0.2)
	_check("horizontal orbit changes the camera orientation", not cam.transform.basis.is_equal_approx(default_basis))
	var to_target: Vector3 = (Vector3.ZERO - cam.transform.origin).normalized()
	_check("camera still looks at the cube centre", to_target.dot(cam.transform.basis.z) < -0.99)
	var before_zoom: float = cam.get_distance()
	cam.zoom(-1.5)
	for _i in range(40):
		cam._process(0.05)
	_check("zoom-in changes viewing distance", cam.get_distance() < before_zoom - 0.5)
	cam.zoom(-100.0)
	for _i in range(80):
		cam._process(0.05)
	_check("zoom cannot go below the minimum distance", cam.get_distance() >= 4.2 - 0.001)
	cam.zoom(100.0)
	for _i in range(80):
		cam._process(0.05)
	_check("zoom cannot exceed the maximum distance", cam.get_distance() <= 12.0 + 0.001)
	cam.orbit(0.0, 100.0)
	for _i in range(60):
		cam._process(0.05)
	_check("pitch is clamped at the top", cam.get_pitch() <= 1.35 + 0.001)
	cam.orbit(0.0, -100.0)
	for _i in range(60):
		cam._process(0.05)
	_check("pitch is clamped at the bottom", cam.get_pitch() >= 0.12 - 0.001)
	for _i in range(200):
		cam.orbit(0.3, 0.2)
	for _i in range(40):
		cam._process(0.05)
	_check("repeated orbit keeps the yaw finite", is_finite(cam.get_yaw()))
	_check("repeated orbit keeps the pitch within bounds", cam.get_pitch() >= 0.12 - 0.001 and cam.get_pitch() <= 1.35 + 0.001)
	cam.reset_view()
	_check("reset restores the default distance", absf(cam.get_distance() - 7.3) < 0.01)
	_check("reset restores the default orientation", cam.transform.basis.is_equal_approx(default_basis))
	var hud = m.get_node_or_null("HUD")
	_check("HUD exists", hud != null)
	if hud != null:
		var face_btn: Button = hud._face_buttons[0]["button"]
		_check("face buttons consume input (no camera drag through them)", face_btn.mouse_filter == Control.MOUSE_FILTER_STOP)
		_check("status label lets drags through to the camera", hud._status.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	# All raw input now goes through the single InteractionRouter (AI-04 arbitration).
	var router = m.get_node_or_null("InteractionRouter")
	_check("interaction router is wired into the scene", router != null)
	router._unhandled_input(press)
	router._unhandled_input(release)
	for _i in range(10):
		cam._process(0.05)
	_check("a tap with no drag does not move the camera", absf(cam.get_yaw() - 0.62) < 0.001)
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.pressed = true
	router._unhandled_input(wheel)
	for _i in range(20):
		cam._process(0.05)
	_check("mouse wheel zooms the camera", cam.get_distance() < 7.3)
	if m.get_parent() != null:
		m.get_parent().remove_child(m)
	m.free()

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
	for i in range(main.levels.size()):
		_check("playthrough: level %d is unlocked at this point" % (i + 1), main.load_level(i))
		for k in range(main.engine._scramble_moves.size() - 1, -1, -1):
			main.engine.apply_move(MoveTable.inverse(main.engine._scramble_moves[k]))
		main.cube_view.refresh(main.engine.state)
		_check("playthrough: level %d solved" % (i + 1), main.engine.is_solved())
		_check("playthrough: level %d confirms" % (i + 1), main.confirm_solve())
		var lid: String = str(main.levels[i]["level_id"])
		_check("playthrough: level %d recorded" % (i + 1), main.game_state.is_solved(lid))
		var hook := str(main.levels[i].get("world_hook", ""))
		_check("playthrough: level %d story reaction shown" % (i + 1),
				hud._story.text.contains(StoryContent.reaction_for(hook)))
	_check("playthrough: chapter complete", main.game_state.first_unsolved_index(main.levels) == -1)
	_check("playthrough: equipment persists", main.game_state.owns("equipment.rootweave_gauntlet"))
	_check("playthrough: all six world markers lit", main.world_view.lit_count() == 6)
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

## Milestone C: the world must respond distinctly per level and remember progress, so the
## environment conveys progression rather than only a tally of solved levels.
func _test_world_progression_landmarks() -> void:
	print("[world progression landmarks]")
	var saved := "user://craftcube_save.json"
	var had := FileAccess.file_exists(saved)
	var backup := FileAccess.get_file_as_string(saved) if had else ""
	SaveManager.delete_at_path(saved)
	var m = load("res://scenes/Main.tscn").instantiate()
	m._ready()
	var w = m.world_view
	_check("world builds six ward stones", w._wards.size() == 6)
	_check("world builds exactly one companion", w._nox != null)
	_check("fresh world hides the companion", not w.nox_visible())
	_check("companion is a multi-part figure, not a single sphere", w.nox_part_count() >= 6)
	# Play the chapter through the real controller path and watch the wards reveal in order.
	for i in range(m.levels.size()):
		m.load_level(i)
		var guard := 0
		while not m.engine.is_solved() and guard < 40:
			if not m.guided_move():
				break
			while m.is_animating():
				m.cube_view.skip_animation()
			guard += 1
		m.confirm_solve()
		_eq("ward %d awakened after level %d" % [i + 1, i + 1], w.wards_lit(), i + 1)
		_eq("world tally matches solved levels after level %d" % (i + 1), w.lit_count(), i + 1)
		# The companion awakens at the chapter's third level (the `nox_meets` beat) and stays.
		if i + 1 >= WorldView.NOX_AWAKEN_LEVELS:
			_check("companion visible from level %d onward" % (i + 1), w.nox_visible())
		else:
			_check("companion still hidden before level %d" % WorldView.NOX_AWAKEN_LEVELS, not w.nox_visible())
		if i < m.levels.size() - 1:
			m.next_level()
	_check("companion still present at chapter completion", w.nox_visible())
	# Resuming from a full save restores all wards and the companion without replaying.
	var gs := GameState.new()
	for lvl in m.levels:
		gs.mark_solved(str(lvl["level_id"]))
	SaveManager.save_to_path(gs)
	var r = load("res://scenes/Main.tscn").instantiate()
	r._ready()
	_eq("resume restores all ward stones", r.world_view.wards_lit(), 6)
	_check("resume restores the companion", r.world_view.nox_visible())
	# A partial save reveals exactly the matching prefix of wards, not all of them.
	SaveManager.delete_at_path(saved)
	var gs2 := GameState.new()
	gs2.mark_solved("level.01.awaken")
	SaveManager.save_to_path(gs2)
	var p = load("res://scenes/Main.tscn").instantiate()
	p._ready()
	_eq("one solved level reveals exactly one ward", p.world_view.wards_lit(), 1)
	_check("one solved level still hides the companion", not p.world_view.nox_visible())
	# A save with exactly the awakening threshold reveals the companion.
	SaveManager.delete_at_path(saved)
	var gs3 := GameState.new()
	for i in range(WorldView.NOX_AWAKEN_LEVELS):
		gs3.mark_solved(str(m.levels[i]["level_id"]))
	SaveManager.save_to_path(gs3)
	var q = load("res://scenes/Main.tscn").instantiate()
	q._ready()
	_check("threshold save reveals the companion", q.world_view.nox_visible())
	for node in [p, q, r, m]:
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	if had:
		var fh := FileAccess.open(saved, FileAccess.WRITE)
		fh.store_string(backup)
		fh.close()
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

## Milestone D: per-face readiness must reflect the real configuration for every face, not
## only the objective's faces, and must agree with the solved predicate.
func _test_face_readiness() -> void:
	print("[face readiness]")
	var e := PuzzleEngine.new()
	e.setup(LevelCatalog.by_id("level.01.hollow_stone"))
	var r0: Array = e.face_readiness()
	_eq("readiness reports all six faces", r0.size(), 6)
	_eq("readiness is ordered U,D,L,R,F,B",
		[str(r0[0]["face"]), str(r0[1]["face"]), str(r0[2]["face"]), str(r0[3]["face"]), str(r0[4]["face"]), str(r0[5]["face"])],
		["U", "D", "L", "R", "F", "B"])
	for entry in r0:
		_check("distinct is within 1..n*n for %s" % entry["face"],
			int(entry["distinct"]) >= 1 and int(entry["distinct"]) <= e.state.n * e.state.n)
		_check("solid flag matches distinct==1 for %s" % entry["face"],
			bool(entry["solid"]) == (int(entry["distinct"]) == 1))
	# A scrambled level must show at least one face short of solid, and a solved level all solid.
	e.state.reset()
	for m in e._scramble_moves:
		e.state.apply_move(m)
	var scrambled_any_unsolid := false
	for entry in e.face_readiness():
		if not bool(entry["solid"]):
			scrambled_any_unsolid = true
	_check("scrambled cube shows at least one unsolid face", scrambled_any_unsolid)
	e.state.reset()
	var r1: Array = e.face_readiness()
	for entry in r1:
		_check("%s face is solid when solved" % entry["face"], bool(entry["solid"]))
	_check("all faces solid implies is_solved", e.is_solved())
	# A single legal turn must perturb some face (readiness is not trivially constant).
	e.state.reset()
	e.apply_move(MoveTable.face_move("F", true))
	var perturbed := false
	for entry in e.face_readiness():
		if not bool(entry["solid"]):
			perturbed = true
	_check("one turn leaves some face unsolid", perturbed)

## Milestone D: the HUD readiness line must name every face, mark the objective faces, and
## track the cube's real state (solid vs. several shades).
func _test_hud_readiness_line() -> void:
	print("[hud readiness line]")
	var m = load("res://scenes/Main.tscn").instantiate()
	m._ready()
	var hud = m.get_node("HUD")
	m.load_level(0)  # awaken: objective is U only
	var text: String = hud._readiness.text
	for word in ["top", "bottom", "left", "right", "front", "back"]:
		_check("readiness names the %s face" % word, text.find(word) >= 0)
	_check("readiness marks the required face", text.find("top*") >= 0)
	var needs_top_only := text.find("bottom*") < 0 and text.find("front*") < 0
	_check("readiness does not mark non-required faces as required", needs_top_only)
	if m.get_parent() != null:
		m.get_parent().remove_child(m)
	m.free()

## Milestone E: the Rootweave Gauntlet's declared capability must actually surface, keyed off
## the effect slot (not the equipment id), and only when the item is equipped.
func _test_equipment_capability() -> void:
	print("[equipment capability]")
	var g := GameState.new()
	_check("no resonance before the gauntlet", not g.has_capability("resonance"))
	g.grant_equipment("equipment.rootweave_gauntlet")
	_check("granted gauntlet auto-equips into loadout", g.is_equipped("equipment.rootweave_gauntlet"))
	_check("equipped gauntlet provides resonance", g.has_capability("resonance"))
	_check("unknown capability is absent", not g.has_capability("not_a_slot"))
	g.unequip("equipment.rootweave_gauntlet")
	_check("unequipping removes the capability", not g.has_capability("resonance"))
	# Slot is derived from the effect id, independent of the equipment id.
	_eq("effect slot parses the effect id", StoryContent.effect_slot("perceive.resonance"), "resonance")

## Milestone E: the HUD resonance line is invisible without the capability and, once the
## gauntlet is equipped, names the face that is one turn from settling (distinct==2).
func _test_hud_resonance_line() -> void:
	print("[hud resonance line]")
	var m = load("res://scenes/Main.tscn").instantiate()
	m._ready()
	var hud = m.get_node("HUD")
	m.load_level(2)  # Hollow Stone: cube.2, align U+F
	hud._refresh_resonance()
	_check("no resonance line before the gauntlet", hud._resonance.text == "")
	m.game_state.grant_equipment("equipment.rootweave_gauntlet")
	# Force a face to exactly two shades (one turn from settling) deterministically: a
	# quarter turn of F leaves F with 2 colours and keeps the cube unsolved.
	m.engine.state.reset()
	m.engine.apply_move(MoveTable.face_move("F", true))
	hud._refresh_resonance()
	_check("resonance line appears with the gauntlet", hud._resonance.text.begins_with("Resonance:"))
	_check("resonance names the near-settled face in player terms",
		hud._resonance.text.contains("front") or hud._resonance.text.contains("top"))
	if m.get_parent() != null:
		m.get_parent().remove_child(m)
	m.free()

## Milestone F: settings persist separately from progression and load defensively.
func _test_settings_persistence() -> void:
	print("[settings persistence]")
	var p := "user://t_settings.json"
	SaveManager.delete_settings(p)
	_check("no settings file loads as empty", SaveManager.load_settings(p).is_empty())
	_check("settings save succeeds", SaveManager.save_settings({"big_text": true}, p))
	var loaded: Dictionary = SaveManager.load_settings(p)
	_check("saved setting round-trips", bool(loaded.get("big_text", false)))
	# A malformed file must not crash and must fall back to empty (defaults).
	var f := FileAccess.open(p, FileAccess.WRITE)
	f.store_string("{not json")
	f.close()
	var bad: Dictionary = SaveManager.load_settings(p)
	_check("malformed settings fall back to empty", bad.is_empty())
	SaveManager.delete_settings(p)
	_check("delete_settings removes the file", not FileAccess.file_exists(p))

## Milestone F: the large-text accessibility choice survives a restart (new HUD instance
## reads it back from the settings file).
func _test_hud_big_text_persistence() -> void:
	print("[hud big-text persistence]")
	var p := "user://t_hud_settings.json"
	SaveManager.delete_settings(p)
	SaveManager.delete_settings()  # ensure the default file cannot leak into this test
	var m = load("res://scenes/Main.tscn").instantiate()
	m._ready()
	var hud = m.get_node("HUD")
	hud.settings_path = p
	hud._apply_saved_settings()
	_check("big text is off by default", not hud._big_text)
	hud._on_big_text()
	_check("toggling big text turns it on", hud._big_text)
	_check("big text was persisted", bool(SaveManager.load_settings(p).get("big_text", false)))
	if m.get_parent() != null:
		m.get_parent().remove_child(m)
	m.free()
	# A fresh instance must restore the choice.
	var m2 = load("res://scenes/Main.tscn").instantiate()
	m2._ready()
	var hud2 = m2.get_node("HUD")
	hud2.settings_path = p
	hud2._apply_saved_settings()
	_check("a fresh HUD restores the persisted big-text choice", hud2._big_text)
	if m2.get_parent() != null:
		m2.get_parent().remove_child(m2)
	m2.free()
	SaveManager.delete_settings(p)

## Milestone G: progress is flushed to disk on exit (Android back / window close), so an
## interrupted session never loses progress. Verified via save_progress into an isolated file
## and by asserting the controller actually calls it on a back request (without quitting the
## running test tree).
func _test_progress_flush_on_exit() -> void:
	print("[progress flush on exit]")
	var p := "user://t_exit_save.json"
	SaveManager.delete_at_path(p)
	var m = load("res://scenes/Main.tscn").instantiate()
	m._ready()
	m.save_path = p
	# Solve level 1 through the real path, then flush as the OS would on exit.
	m.cube_view.skip_animation()
	for i in range(m.engine._scramble_moves.size() - 1, -1, -1):
		m.engine.apply_move(MoveTable.inverse(m.engine._scramble_moves[i]))
	_check("level 1 is solved before exit flush", m.engine.is_solved())
	m.confirm_solve()
	SaveManager.delete_at_path(p)  # prove the flush, not the in-play save, wrote the file
	_check("flush reports success", m.save_progress())
	var reloaded := SaveManager.load_from_path(p)
	_check("flushed progress survives reload", reloaded.is_solved("level.01.awaken"))
	# The back/close notification must itself flush. This instance is not inside the tree, so
	# the handler persists and skips the quit — proving the write without ending the test run.
	SaveManager.delete_at_path(p)
	m._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	_check("back request flushed progress without a prior save", FileAccess.file_exists(p))
	var reloaded2 := SaveManager.load_from_path(p)
	_check("back-request flush survives reload", reloaded2.is_solved("level.01.awaken"))
	if m.get_parent() != null:
		m.get_parent().remove_child(m)
	m.free()
	SaveManager.delete_at_path(p)

## Milestone H: reduced motion is a persisted accessibility choice that reaches the cube view.
func _test_reduced_motion_persistence() -> void:
	print("[reduced motion persistence]")
	var p := "user://t_rm_settings.json"
	SaveManager.delete_settings(p)
	SaveManager.delete_settings()
	var m = load("res://scenes/Main.tscn").instantiate()
	m._ready()
	var hud = m.get_node("HUD")
	hud.settings_path = p
	hud._apply_saved_settings()
	_check("reduced motion is off by default", not hud._reduced_motion)
	_check("cube view starts with motion enabled", not m.cube_view.reduced_motion)
	hud._on_reduced_motion()
	_check("toggling reduced motion turns it on", hud._reduced_motion)
	_check("reduced motion reaches the cube view", m.cube_view.reduced_motion)
	_check("reduced motion was persisted", bool(SaveManager.load_settings(p).get("reduced_motion", false)))
	# A turn under reduced motion must still go through the real animated lifecycle and advance
	# the logic exactly once when it settles.
	m.load_level(0)
	var before: int = m.engine.move_count()
	_check("reduced-motion animated turn starts", m.try_move("U", true, true))
	_check("reduced-motion turn is in flight", m.is_animating())
	m.cube_view.skip_animation()
	_check("reduced-motion turn advanced the logic once", m.engine.move_count() == before + 1)
	_check("reduced-motion turn is no longer in flight", not m.is_animating())
	if m.get_parent() != null:
		m.get_parent().remove_child(m)
	m.free()
	var m2 = load("res://scenes/Main.tscn").instantiate()
	m2._ready()
	var hud2 = m2.get_node("HUD")
	hud2.settings_path = p
	hud2._apply_saved_settings()
	_check("a fresh HUD restores reduced motion", hud2._reduced_motion)
	_check("restored reduced motion reaches the fresh cube view", m2.cube_view.reduced_motion)
	if m2.get_parent() != null:
		m2.get_parent().remove_child(m2)
	m2.free()
	SaveManager.delete_settings(p)

## Versioned-APK release policy: the application version has ONE source of truth
## (res://app_version.json). These tests fail loudly if the export preset, the version
## reader, or the HUD drift away from it.
func _test_version_single_source_of_truth() -> void:
	print("[version single source of truth]")
	var meta := Version._read()
	_check("app_version.json is readable", not meta.is_empty())
	var ver := Version.app_version()
	var code := Version.version_code()
	_check("app_version is MAJOR.MINOR.PATCH", ver.split(".").size() == 3)
	_check("version_code is a positive integer", code > 0)
	_check("Version.tag prefixes with v", Version.tag() == "v" + ver)

	# The export preset (the value Godot stamps into the APK) must equal the source of truth.
	var f := FileAccess.open("res://export_presets.cfg", FileAccess.READ)
	_check("export_presets.cfg is readable", f != null)
	var preset_name := ""
	var preset_code := ""
	var preset_pkg := ""
	if f != null:
		for line in f.get_as_text().split("\n"):
			var s := line.strip_edges()
			if s.begins_with("version/name="):
				preset_name = s.split("=", true, 1)[1].strip_edges().trim_prefix('"').trim_suffix('"')
			elif s.begins_with("version/code="):
				preset_code = s.split("=", true, 1)[1].strip_edges()
			elif s.begins_with("package/unique_name="):
				preset_pkg = s.split("=", true, 1)[1].strip_edges().trim_prefix('"').trim_suffix('"')
	_eq("export version/name equals app_version", preset_name, ver)
	_eq("export version/code equals version_code", preset_code, str(code))
	_eq("export package equals android.package", preset_pkg, str(meta.get("android", {}).get("package", "")))

	# The released ledger must keep version_code strictly increasing and never reuse a version.
	var released: Array = meta.get("released", [])
	var monotonic := true
	var reused := false
	for rec in released:
		if int(rec.get("version_code", 0)) >= code:
			monotonic = false
		if str(rec.get("version", "")) == ver:
			reused = true
	_check("version_code is greater than every released version_code", monotonic)
	_check("app_version is not already in the released ledger", not reused)

## The HUD shows the version read from the single source of truth.
func _test_hud_version_label() -> void:
	print("[hud version label]")
	var m = load("res://scenes/Main.tscn").instantiate()
	m._ready()
	var hud = m.get_node("HUD")
	_check("hud has a version label", hud._version != null)
	_check("hud version label names the app and version", str(hud._version.text).contains(Version.app_version()))
	_check("hud version label matches the shared display string", str(hud._version.text) == "CraftCube " + Version.display())
	if m.get_parent() != null:
		m.get_parent().remove_child(m)
	m.free()

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

## Milestone A validator: the guided route must actually return the cube to the fully
## solved configuration for every Chapter 01 level, from the scramble and after arbitrary
## player deviation, and must never propose an illegal turn.
func _test_guided_solver_domain() -> void:
	print("[guided solver domain]")
	for lvl in LevelCatalog.chapter_one():
		var e := PuzzleEngine.new()
		e.setup(lvl)
		var n: int = e.state.n
		var route := PuzzleSolver.route_to_solved(e)
		_check("%s route is non-empty on scramble" % lvl["level_id"], route.size() > 0)
		var legal_all := true
		for mv in route:
			if not e.is_legal(mv):
				legal_all = false
		_check("%s route only proposes legal turns" % lvl["level_id"], legal_all)
		for mv in route:
			e.apply_move(mv)
		_eq("%s route reaches fully solved fingerprint" % lvl["level_id"], e.state.fingerprint(), _solved_fp(n))
		_check("%s route satisfies the objective predicate" % lvl["level_id"], e.is_solved())
	# After arbitrary player deviation, the recomputed route still solves the cube.
	var e2 := PuzzleEngine.new()
	e2.setup(LevelCatalog.by_id("level.01.hollow_stone"))  # Y-locked: only side faces legal
	e2.apply_move(MoveTable.face_move("L", true))
	e2.apply_move(MoveTable.face_move("F", false))
	e2.apply_move(MoveTable.face_move("R", true))
	var route2 := PuzzleSolver.route_to_solved(e2)
	_check("deviation route is non-empty", route2.size() > 0)
	var dev_legal := true
	for mv in route2:
		if not e2.is_legal(mv):
			dev_legal = false
	_check("deviation route legal under Y-lock", dev_legal)
	for mv in route2:
		e2.apply_move(mv)
	_eq("deviation route reaches solved", e2.state.fingerprint(), _solved_fp(e2.state.n))
	# A player move that already walks back along the route must not be undone (no loop).
	var e3 := PuzzleEngine.new()
	e3.setup(LevelCatalog.by_id("level.01.awaken"))
	var first := PuzzleSolver.route_to_solved(e3)
	e3.apply_move(first[0])
	var second := PuzzleSolver.route_to_solved(e3)
	_check("executing a guided step strictly shortens the route", second.size() == first.size() - 1)
	_check("reduced route does not immediately undo the step just taken",
		second.size() > 0 and not PuzzleSolver._cancels(first[0], second[0]))
	for mv in second:
		e3.apply_move(mv)
	_eq("advanced route still reaches solved", e3.state.fingerprint(), _solved_fp(e3.state.n))

## Milestone A must work end-to-end through the real controller + animated turn path.
func _test_guided_solver_controller() -> void:
	print("[guided solver controller]")
	var saved := "user://craftcube_save.json"
	var had := FileAccess.file_exists(saved)
	var backup := FileAccess.get_file_as_string(saved) if had else ""
	SaveManager.delete_at_path(saved)
	var m = load("res://scenes/Main.tscn").instantiate()
	m._ready()
	for i in range(m.levels.size()):
		m.load_level(i)
		var st: Dictionary = m.guide_status()
		_check("level %d hint is available" % (i + 1), bool(st.get("available", false)))
		_check("level %d hint step is legal" % (i + 1), m.engine.is_legal(m.guide_next_move()))
		var steps := 0
		while not m.engine.is_solved() and steps < 40:
			var before: int = m.engine.move_count()
			if not m.guided_move():
				break
			while m.is_animating():
				m.cube_view.skip_animation()
			if m.engine.move_count() != before + 1:
				break
			steps += 1
		_check("level %d solves by following the guide" % (i + 1), m.engine.is_solved())
		_check("level %d guide finishes within a sane step count" % (i + 1), steps < 40)
		_check("level %d guide reports solved" % (i + 1), bool(m.guide_status().get("solved", false)))
		_check("level %d confirm_solve accepts the guided result" % (i + 1), m.confirm_solve())
		if i < m.levels.size() - 1:
			m.next_level()
	# After independent moves the cached route is invalidated; the next hint still solves.
	m.load_level(0)
	m.try_move("R", true)
	while m.is_animating():
		m.cube_view.skip_animation()
	m.try_move("F", false)
	while m.is_animating():
		m.cube_view.skip_animation()
	_check("controller rebuilds a route after independent moves", m.ensure_guide().size() > 0)
	var guard := 0
	while not m.engine.is_solved() and guard < 40:
		if not m.guided_move():
			break
		while m.is_animating():
			m.cube_view.skip_animation()
		guard += 1
	_check("controller guide still reaches solved after deviation", m.engine.is_solved())
	if m.get_parent() != null:
		m.get_parent().remove_child(m)
	m.free()
	if had:
		var w := FileAccess.open(saved, FileAccess.WRITE)
		w.store_string(backup)
		w.close()
	else:
		SaveManager.delete_at_path(saved)


## progress toward it, and show the level par so "good" play is legible without a manual.
func _test_hud_status_text() -> void:
	print("[hud status text]")
	var m = load("res://scenes/Main.tscn").instantiate()
	m._ready()
	var hud = m.get_node_or_null("HUD")
	m.load_level(0)  # Awaken: align top, par 3
	hud._refresh_status()
	_check("status names the top face for a U objective", hud._status.text.contains("top"))
	_check("status shows progress fraction", hud._status.text.contains("/1 aligned"))
	_check("status shows par", hud._status.text.contains("par 3"))
	# Unlock level 3 (Hollow Stone: align top+front) through real progression, then load it.
	m.game_state.mark_solved("level.01.awaken")
	m.game_state.mark_solved("level.01.seed_bed")
	m.load_level(2)
	hud._refresh_status()
	_check("status names both required faces", hud._status.text.contains("top") and hud._status.text.contains("front"))
	_check("status shows /2 for a two-face objective", hud._status.text.contains("/2 aligned"))
	if m.get_parent() != null:
		m.get_parent().remove_child(m)
	m.free()

# =======================================================================================
# EPIC 0.3 — campaign, mastery, migration, application flow
# =======================================================================================

## The three prototype levels (4–6) must be genuinely playable: unique stable IDs, a recorded
## seed, unsolved at the start, reachable under their own legal move set, not trivially solved,
## a par that matches the scramble depth, and correct placement in the six-level chapter.
func _test_chapter_campaign_levels() -> void:
	print("[chapter campaign levels]")
	var levels := LevelCatalog.chapter_one()
	_eq("chapter has six levels", levels.size(), 6)
	var ids := {}
	for i in range(levels.size()):
		var lvl: Dictionary = levels[i]
		var lid := str(lvl["level_id"])
		_check("%s id is unique" % lid, not ids.has(lid))
		ids[lid] = true
		_eq("%s ordinal matches position" % lid, int(lvl.get("ordinal", -1)), i + 1)
		_check("%s has a recorded scramble seed" % lid, int(lvl.get("scramble", {}).get("seed", -1)) >= 0)
		var e := PuzzleEngine.new()
		e.setup(lvl)
		_check("%s starts unsolved" % lid, not e.is_solved())
		_check("%s scramble is solvable by inverse replay" % lid, e.verify_scramble_solvable())
		_check("%s scramble actually perturbs the cube" % lid, e._scramble_moves.size() > 0)
		_eq("%s par matches the scramble depth" % lid, int(lvl.get("par_moves", -1)), e._scramble_moves.size())
		# The objective must be reachable through the level's own legal move set: follow the
		# guided route (which is derived from the engine's own history) to completion.
		var route := PuzzleSolver.route_to_solved(e)
		var legal_all := true
		for mv in route:
			if not e.is_legal(mv):
				legal_all = false
		_check("%s guided route only uses legal moves" % lid, legal_all)
		for mv in route:
			e.apply_move(mv)
		_check("%s objective reachable via legal moves" % lid, e.is_solved())
	# The 3x3 topology must actually be exposed (not silently coerced to 2x2).
	var l4 := LevelCatalog.by_id("level.01.deeper_resonance")
	var e4 := PuzzleEngine.new()
	e4.setup(l4)
	_eq("level 4 uses the 3x3 topology", e4.state.n, 3)
	# Constrained levels must genuinely restrict the legal set and remain solvable.
	var l5 := LevelCatalog.by_id("level.01.constrained_paths")
	var e5 := PuzzleEngine.new()
	e5.setup(l5)
	_check("level 5 seals the left/right faces", not e5._legal_faces.has("L") and not e5._legal_faces.has("R"))
	_check("level 5 still exposes front/back/top/bottom", e5._legal_faces.has("F") and e5._legal_faces.has("B") and e5._legal_faces.has("U") and e5._legal_faces.has("D"))
	_check("level 5 objective is not auto-satisfied", not e5.is_solved())
	var l6 := LevelCatalog.by_id("level.01.closing_trial")
	var e6 := PuzzleEngine.new()
	e6.setup(l6)
	_check("level 6 seals the front/back faces", not e6._legal_faces.has("F") and not e6._legal_faces.has("B"))
	_check("level 6 objective is not auto-satisfied", not e6.is_solved())

## The newly exposed 3x3 topology must render and animate without logical/rendered divergence.
## Load level 4, build the real view, perform an animated turn through the real input path,
## and verify the facelet count and rendered colours match the truth layer exactly.
func _test_3x3_rendered_sync() -> void:
	print("[3x3 rendered sync]")
	var m = load("res://scenes/Main.tscn").instantiate()
	m._ready()
	m.game_state.mark_solved("level.01.awaken")
	m.game_state.mark_solved("level.01.seed_bed")
	m.game_state.mark_solved("level.01.hollow_stone")
	_check("3x3 level 4 loads through the gate", m.load_level(3))
	_eq("engine reports the 3x3 topology", m.engine.state.n, 3)
	_eq("view builds one facelet per cube facelet", m.cube_view._facelets.size(), 6 * 3 * 3)
	# An animated turn through the real controller path, settled deterministically.
	var ok: bool = m.try_move("U", true)
	_check("3x3 animated turn is accepted", ok)
	m.cube_view.skip_animation()
	_check("3x3 animation settles and releases the lock", not m.is_animating())
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
	_check("3x3 rendered facelets match the truth layer after a turn", mismatches == 0)
	if m.get_parent() != null:
		m.get_parent().remove_child(m)
	m.free()

## The deterministic rating rule: 3 stars at/below par, 2 within 150%, else 1. Integer only.
func _test_mastery_ratings() -> void:
	print("[mastery ratings]")
	_eq("at par is three stars", GameState.stars_for(10, 10), 3)
	_eq("below par is three stars", GameState.stars_for(8, 10), 3)
	_eq("one over par is two stars", GameState.stars_for(11, 10), 2)
	_eq("exactly 150% of par is two stars", GameState.stars_for(15, 10), 2)
	_eq("just past 150% is one star", GameState.stars_for(16, 10), 1)
	# Odd par: floor(1.5*par) is the two-star ceiling, computed with integer arithmetic.
	_eq("floor(1.5*7)=10 is two stars", GameState.stars_for(10, 7), 2)
	_eq("11 moves on par 7 is one star", GameState.stars_for(11, 7), 1)
	_eq("par 0 is a free completion (three stars)", GameState.stars_for(99, 0), 3)

## Best-result policy: a better replay improves the record, a worse replay never overwrites it.
func _test_best_result_persistence() -> void:
	print("[best result persistence]")
	var path := "user://t_best_save.json"
	SaveManager.delete_at_path(path)
	var g := GameState.new()
	var r1 := g.record_attempt("level.01.awaken", 12, GameState.stars_for(12, 3), 0)
	_check("first attempt is a best", bool(r1["is_best"]))
	_eq("first best moves stored", g.best_moves("level.01.awaken"), 12)
	_eq("first best stars stored", g.best_stars("level.01.awaken"), 1)
	# A worse replay must not change the record.
	var r2 := g.record_attempt("level.01.awaken", 30, GameState.stars_for(30, 3), 2)
	_check("worse replay is not a best", not bool(r2["is_best"]))
	_eq("worse replay keeps best moves", g.best_moves("level.01.awaken"), 12)
	_eq("worse replay keeps best stars", g.best_stars("level.01.awaken"), 1)
	_eq("attempts accumulate", int(g.best_for("level.01.awaken").get("attempts", 0)), 2)
	_eq("hints accumulate", int(g.best_for("level.01.awaken").get("hints", 0)), 2)
	# A better replay improves it.
	var r3 := g.record_attempt("level.01.awaken", 3, GameState.stars_for(3, 3), 0)
	_check("better replay is a best", bool(r3["is_best"]))
	_check("better replay reports improvement", bool(r3["improved"]))
	_eq("best moves improved", g.best_moves("level.01.awaken"), 3)
	_eq("best stars improved", g.best_stars("level.01.awaken"), 3)
	# Persistence across a save/reload.
	SaveManager.save_to_path(g, path)
	var r := SaveManager.load_from_path(path)
	_eq("best moves survive reload", r.best_moves("level.01.awaken"), 3)
	_eq("best stars survive reload", r.best_stars("level.01.awaken"), 3)
	_eq("attempt count survives reload", int(r.best_for("level.01.awaken").get("attempts", 0)), 3)
	# Ties on stars are broken by fewer moves, but never by more.
	g.record_attempt("level.01.awaken", 2, 3, 0)
	_eq("fewer moves at equal stars improves", g.best_moves("level.01.awaken"), 2)
	g.record_attempt("level.01.awaken", 9, 3, 0)
	_eq("more moves at equal stars does not regress", g.best_moves("level.01.awaken"), 2)
	SaveManager.delete_at_path(path)

## A version-1 save (no level_records) must load with every field preserved and no records,
## then be upgraded to version 2 on the next write. Nothing legitimate is reset.
func _test_save_v1_migration() -> void:
	print("[save v1 migration]")
	var path := "user://t_migrate_save.json"
	SaveManager.delete_at_path(path)
	var v1 := {
		"save_version": 1,
		"solved_levels": ["level.01.awaken", "level.01.seed_bed"],
		"discoveries": ["discovery.01.first_pulse"],
		"owned_equipment": ["equipment.rootweave_gauntlet"],
		"loadout": ["equipment.rootweave_gauntlet"],
		"world_flags": {"mechanism_awakens": true, "seed_grows": true},
		"current_level_index": 2,
	}
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(v1))
	f.close()
	var g := SaveManager.load_from_path(path)
	_check("v1 solved levels preserved", g.is_solved("level.01.awaken") and g.is_solved("level.01.seed_bed"))
	_eq("v1 discoveries preserved", g.discoveries, ["discovery.01.first_pulse"])
	_check("v1 equipment preserved", g.owns("equipment.rootweave_gauntlet"))
	_check("v1 loadout preserved", g.is_equipped("equipment.rootweave_gauntlet"))
	_check("v1 world flags preserved", g.world_flags.has("mechanism_awakens") and g.world_flags.has("seed_grows"))
	_eq("v1 campaign position preserved", g.current_level_index, 2)
	_check("v1 save has no mastery records (empty table)", g.level_records.is_empty())
	# The next write must upgrade the schema to the current version and still carry the v1 data.
	SaveManager.save_to_path(g, path)
	var reread := SaveManager.load_from_path(path)
	_check("upgraded save is the current schema version", int(reread.to_dict().get("save_version", 0)) == GameState.SAVE_VERSION)
	_check("upgrade keeps solved levels", reread.is_solved("level.01.seed_bed"))
	_check("upgrade keeps discoveries", reread.discoveries.has("discovery.01.first_pulse"))
	# A malformed level_records table is coerced to empty, never trusted.
	var v2bad := {
		"save_version": 2, "solved_levels": [], "level_records": {
			"ok": {"best_moves": 5, "best_stars": 3, "attempts": 1, "hints": 0},
			"bad_stars": {"best_moves": 5, "best_stars": 9},
			"bad_type": "nope",
		},
	}
	f = FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(v2bad))
	f.close()
	var gb := SaveManager.load_from_path(path)
	_eq("valid record kept", gb.best_stars("ok"), 3)
	_check("out-of-range stars record dropped", gb.best_for("bad_stars").is_empty())
	_check("wrong-typed record dropped", gb.best_for("bad_type").is_empty())
	SaveManager.delete_at_path(path)

## Sequential unlock rule: level 1 always open; each later level needs its predecessor solved.
func _test_campaign_unlock_rules() -> void:
	print("[campaign unlock rules]")
	var levels := LevelCatalog.chapter_one()
	var g := GameState.new()
	_check("level 1 is unlocked with no progress", g.is_level_unlocked(levels, 0))
	_check("level 2 is locked with no progress", not g.is_level_unlocked(levels, 1))
	_check("highest unlocked with no progress is level 1", g.highest_unlocked_index(levels) == 0)
	g.mark_solved("level.01.awaken")
	_check("solving level 1 unlocks level 2", g.is_level_unlocked(levels, 1))
	_check("level 3 still locked", not g.is_level_unlocked(levels, 2))
	# Solving out of order does not open a gap: level 3 needs level 2 specifically.
	g.mark_solved("level.01.hollow_stone")
	_check("level 3 stays locked without level 2", not g.is_level_unlocked(levels, 2))
	g.mark_solved("level.01.seed_bed")
	_check("level 3 unlocks once level 2 is solved", g.is_level_unlocked(levels, 2))
	_check("campaign is not complete yet", not g.campaign_complete(levels))
	for l in levels:
		g.mark_solved(str(l["level_id"]))
	_check("campaign completes when all levels solved", g.campaign_complete(levels))
	_check("highest unlocked reaches the last level", g.highest_unlocked_index(levels) == levels.size() - 1)
	_check("out-of-range index is not unlocked", not g.is_level_unlocked(levels, 99))

## The application shell must boot into a working flow and route into the real gameplay scene
## through real application state (not static mockups).
func _test_app_shell_navigation() -> void:
	print("[app shell navigation]")
	var saved := "user://craftcube_save.json"
	var had := FileAccess.file_exists(saved)
	var backup := FileAccess.get_file_as_string(saved) if had else ""
	SaveManager.delete_at_path(saved)
	var packed: PackedScene = load("res://scenes/App.tscn")
	_check("App.tscn loads as PackedScene", packed != null)
	if packed == null:
		return
	var app = _mount_app(packed)
	_check("app boots into the title screen", app.current_screen() == "title")
	_check("app mounts exactly one gameplay controller", app.game != null)
	_check("gameplay starts hidden behind the title", not app.game.visible)
	_check("continue is disabled with no progress", app._screens["title_continue"].disabled)
	# New Game with no progress starts immediately and enters the game.
	app._on_new_game_pressed()
	_check("new game enters gameplay", app.current_screen() == "game")
	_check("gameplay is visible in game", app.game.visible)
	_check("new game loaded level 1", app.game.current_index == 0)
	# Menu navigation paths.
	app._open_map()
	_check("chapter map opens", app.current_screen() == "map")
	_check("map builds one card per level", app._screens["map_grid"].get_child_count() == 6)
	app._open_journal()
	_check("journal opens", app.current_screen() == "journal")
	app._open_settings()
	_check("settings opens", app.current_screen() == "settings")
	app._open_title()
	_check("back returns to the title", app.current_screen() == "title")
	_check("continue stays disabled with no solved levels", app._screens["title_continue"].disabled)
	# Solving a level enables Continue (real progress, not just entering gameplay).
	app._play_level(0)
	_check("level 1 solves through the app", _solve_current(app))
	app._open_title()
	_check("continue is enabled after solving a level", not app._screens["title_continue"].disabled)
	# The gameplay HUD offers a menu path that routes back to the app.
	app._play_level(0)
	_check("playing a level shows gameplay", app.current_screen() == "game")
	app.game.request_menu()
	_check("HUD menu request returns to the chapter map", app.current_screen() == "map")
	# Settings have a real effect on the gameplay cube view.
	app._toggle_reduced_motion()
	_check("reduced motion reaches the cube view", app.game.cube_view.reduced_motion)
	app._toggle_reduced_motion()
	_check("reduced motion can be turned back off", not app.game.cube_view.reduced_motion)
	if app.get_parent() != null:
		app.get_parent().remove_child(app)
	app.free()
	if had:
		var w := FileAccess.open(saved, FileAccess.WRITE)
		w.store_string(backup)
		w.close()
	else:
		SaveManager.delete_at_path(saved)

## Drive the full six-level campaign through the application shell's real screens and the real
## gameplay engine, then verify results, mastery, unlock progression and the campaign end state.
func _test_app_campaign_flow() -> void:
	print("[app campaign flow]")
	var saved := "user://craftcube_save.json"
	var had := FileAccess.file_exists(saved)
	var backup := FileAccess.get_file_as_string(saved) if had else ""
	SaveManager.delete_at_path(saved)
	var app = _mount_app(load("res://scenes/App.tscn"))
	app._begin_new_game()
	_check("campaign flow starts at level 1", app.game.current_index == 0)
	var seen_stars := []
	for i in range(app.game.levels.size()):
		var ok: bool = app._play_level(i)
		_check("campaign flow enters level %d" % (i + 1), ok and app.game.current_index == i)
		# Solve through the real animated turn path (guided route), settling each turn.
		var guard := 0
		while not app.game.engine.is_solved() and guard < 60:
			if not app.game.guided_move():
				break
			while app.game.is_animating():
				app.game.cube_view.skip_animation()
			guard += 1
		_check("campaign flow level %d solved" % (i + 1), app.game.engine.is_solved())
		var before_solved: int = app.game.game_state.solved_levels.size()
		_check("campaign flow level %d confirms" % (i + 1), app.game.confirm_solve())
		var r: Dictionary = app.game.last_result_data()
		_check("result carries a title for level %d" % (i + 1), str(r.get("title", "")) != "")
		_check("result carries par for level %d" % (i + 1), int(r.get("par", 0)) > 0)
		_check("result stars are in range for level %d" % (i + 1), int(r.get("stars", 0)) >= 1 and int(r.get("stars", 0)) <= 3)
		seen_stars.append(int(r.get("stars", 0)))
		if i < app.game.levels.size() - 1:
			_check("solving level %d unlocks the next" % (i + 1),
				app.game.game_state.solved_levels.size() == before_solved + 1
				and app.game.is_level_unlocked(i + 1))
	# A locked level must be rejected by the controller even via a direct call.
	SaveManager.delete_at_path(saved)
	var fresh = _mount_app(load("res://scenes/App.tscn"))
	fresh._begin_new_game()
	_check("direct load of a locked level is rejected", not fresh.game.load_level(3))
	_check("direct load does not move the campaign position", fresh.game.current_index == 0)
	_check("locked level 4 cannot be entered from the map", not fresh._play_level(3))
	if fresh.get_parent() != null:
		fresh.get_parent().remove_child(fresh)
	fresh.free()
	# Campaign completion state.
	_check("campaign is complete after six levels", app.game.game_state.campaign_complete(app.game.levels))
	var completed: Dictionary = app.game.last_result_data()
	_check("final result reports campaign completion", bool(completed.get("campaign_complete", false)))
	# Replay a completed level: best result is preserved and no reward duplicates.
	var best_before: int = app.game.game_state.best_stars(str(app.game.levels[2]["level_id"]))
	app._play_level(2)
	var guard2 := 0
	while not app.game.engine.is_solved() and guard2 < 60:
		if not app.game.guided_move():
			break
		while app.game.is_animating():
			app.game.cube_view.skip_animation()
		guard2 += 1
	app.game.confirm_solve()
	_check("replay keeps the best star rating", app.game.game_state.best_stars(str(app.game.levels[2]["level_id"])) >= best_before)
	_check("replay does not add a duplicate solved entry",
		app.game.game_state.solved_levels.size() == app.game.levels.size())
	if app.get_parent() != null:
		app.get_parent().remove_child(app)
	app.free()
	if had:
		var w := FileAccess.open(saved, FileAccess.WRITE)
		w.store_string(backup)
		w.close()
	else:
		SaveManager.delete_at_path(saved)

## The journal must show discovered entries with their real text and hide undiscovered text.
func _test_journal_visibility() -> void:
	print("[journal visibility]")
	var saved := "user://craftcube_save.json"
	var had := FileAccess.file_exists(saved)
	var backup := FileAccess.get_file_as_string(saved) if had else ""
	SaveManager.delete_at_path(saved)
	var app = _mount_app(load("res://scenes/App.tscn"))
	app._begin_new_game()
	# Fresh journal: nothing discovered, no hidden text leaked.
	app._open_journal()
	var list: VBoxContainer = app._screens["journal_list"]
	_eq("journal lists every discovery entry", list.get_child_count(), StoryContent.all_discoveries().size())
	var fresh_text := _all_label_text(list)
	var d1 := StoryContent.discovery_for("discovery.01.first_pulse")
	_check("undiscovered entry is labelled locked", fresh_text.contains("Undiscovered"))
	_check("undiscovered entry hides its real text", not fresh_text.contains(str(d1.get("text", ""))))
	# Discover entry 1 by completing levels 1 and 2 through the real controller path
	# (level 2 is gated behind level 1, so it must be reached sequentially).
	_check("level 1 solves for journal", _solve_current(app))
	app._play_level(1)
	_check("level 2 solves for journal", _solve_current(app))
	_check("level 2 recorded its discovery", app.game.game_state.discoveries.has("discovery.01.first_pulse"))
	app._open_journal()
	var shown := _all_label_text(list)
	_check("discovered entry shows its name", shown.contains(str(d1.get("name", ""))))
	_check("discovered entry shows its real text", shown.contains(str(d1.get("text", ""))))
	# The journal state must survive a reload from the save.
	app.game.save_progress()
	if app.get_parent() != null:
		app.get_parent().remove_child(app)
	app.free()
	var app2 = _mount_app(load("res://scenes/App.tscn"))
	app2._open_journal()
	var shown2 := _all_label_text(app2._screens["journal_list"])
	_check("journal state restores after reload", shown2.contains(str(d1.get("text", ""))))
	if app2.get_parent() != null:
		app2.get_parent().remove_child(app2)
	app2.free()
	if had:
		var w := FileAccess.open(saved, FileAccess.WRITE)
		w.store_string(backup)
		w.close()
	else:
		SaveManager.delete_at_path(saved)

## Nox must be unavailable before awakening, available after, restore from a save, and be a
## recognisable multi-part figure. Its dialogue must not replay one-time reward logic.
func _test_nox_interaction() -> void:
	print("[nox interaction]")
	var saved := "user://craftcube_save.json"
	var had := FileAccess.file_exists(saved)
	var backup := FileAccess.get_file_as_string(saved) if had else ""
	SaveManager.delete_at_path(saved)
	var app = _mount_app(load("res://scenes/App.tscn"))
	app._begin_new_game()
	_check("Nox is unavailable before awakening", not app.nox_available())
	_check("Nox offers no dialogue before awakening", app.nox_dialogue_text() == "")
	_check("Nox is hidden in the world before awakening", not app.game.world_view.nox_visible())
	# Complete the chapter's third level through the real path to awaken Nox.
	for i in range(3):
		app._play_level(i)
		var guard := 0
		while not app.game.engine.is_solved() and guard < 60:
			if not app.game.guided_move():
				break
			while app.game.is_animating():
				app.game.cube_view.skip_animation()
			guard += 1
		app.game.confirm_solve()
	_check("Nox is available after the third level", app.nox_available())
	_check("Nox is visible in the world after awakening", app.game.world_view.nox_visible())
	var text: String = app.nox_dialogue_text()
	_check("Nox dialogue uses the authored greeting", text.contains(StoryContent.nox_line("greeting")))
	_check("Nox dialogue uses the authored line", text.contains(StoryContent.nox_line("awakened")))
	# Equipment from the awakening is granted exactly once.
	_check("awakening granted the Rootweave Gauntlet", app.game.game_state.owns("equipment.rootweave_gauntlet"))
	var owned_before: int = app.game.game_state.owned_equipment.size()
	app._play_level(2)
	var guard2 := 0
	while not app.game.engine.is_solved() and guard2 < 60:
		if not app.game.guided_move():
			break
		while app.game.is_animating():
			app.game.cube_view.skip_animation()
		guard2 += 1
	app.game.confirm_solve()
	_eq("replaying the awakening level does not duplicate equipment",
		app.game.game_state.owned_equipment.size(), owned_before)
	# Restore from a save: Nox is available again without replaying the awakening.
	app.game.save_progress()
	if app.get_parent() != null:
		app.get_parent().remove_child(app)
	app.free()
	var app2 = _mount_app(load("res://scenes/App.tscn"))
	_check("Nox restores as available after reload", app2.nox_available())
	_check("Nox is visible in the world after reload", app2.game.world_view.nox_visible())
	_check("Nox dialogue is revisitable after reload", app2.nox_dialogue_text().contains(StoryContent.nox_line("awakened")))
	if app2.get_parent() != null:
		app2.get_parent().remove_child(app2)
	app2.free()
	if had:
		var w := FileAccess.open(saved, FileAccess.WRITE)
		w.store_string(backup)
		w.close()
	else:
		SaveManager.delete_at_path(saved)

## EPIC 0.4 Milestone C: the interactive three-notch sigil. Unavailable on a fresh world,
## tappable once the world answers, grants its discovery exactly once, and restores from a
## save. Also proves the world appearance is rebuilt from truth (no event replay on load).
func _test_world_sigil() -> void:
	print("[world sigil]")
	var saved := "user://craftcube_save.json"
	var had := FileAccess.file_exists(saved)
	var backup := FileAccess.get_file_as_string(saved) if had else ""
	SaveManager.delete_at_path(saved)
	var app = _mount_app(load("res://scenes/App.tscn"))
	app._begin_new_game()
	var w = app.game.world_view
	# Fresh world: nothing interactive, and the sigil cannot be read yet.
	_check("fresh world exposes no interactive targets", w.interactive_targets().is_empty())
	_check("fresh world hides the sigil", not w.sigil_available())
	_check("reading the sigil before it exists does nothing", not w.read_sigil())
	# Answer the world once.
	app._play_level(0)
	_check("level 1 solved for the sigil test", _solve_current(app))
	_check("sigil becomes available after the first solve", w.sigil_available())
	var ids := []
	for t in w.interactive_targets():
		ids.append(str(t["id"]))
	_check("sigil is registered as a world target", ids.has(WorldView.TARGET_SIGIL))
	# A real tap through the arbiter grants the discovery exactly once.
	var before: int = app.game.game_state.discoveries.size()
	app.game.router.world_tapped.emit(WorldView.TARGET_SIGIL)
	_check("tap grants the three-notch discovery", app.game.game_state.discoveries.has("discovery.01.three_notch_mark"))
	_eq("tap granted exactly one discovery", app.game.game_state.discoveries.size(), before + 1)
	app.game.router.world_tapped.emit(WorldView.TARGET_SIGIL)
	_eq("second tap does not duplicate the discovery", app.game.game_state.discoveries.size(), before + 1)
	_check("sigil_read world flag persisted", app.game.game_state.world_flags.has("sigil_read"))
	app.game.router.world_tapped.emit("world.does_not_exist")
	_eq("unknown target id is a safe no-op", app.game.game_state.discoveries.size(), before + 1)
	# Solve a second level so the reload proves the world is rebuilt from the real tally.
	app._play_level(1)
	_check("level 2 solved for the sigil test", _solve_current(app))
	# The journal reveals the newly discovered entry.
	app._open_journal()
	_check("journal reveals the sigil discovery", _all_label_text(app).contains("The Three-Notch Mark"))
	# Rebuilding the world from truth is idempotent (no double-lighting on re-entry).
	w.sync_from_state(2, {})
	w.sync_from_state(2, {})
	_eq("world rebuild is idempotent", w.lit_count(), 2)
	# Reload: the sigil stays read, the discovery survives, the world is rebuilt from truth.
	app.game.save_progress()
	if app.get_parent() != null:
		app.get_parent().remove_child(app)
	app.free()
	var app2 = _mount_app(load("res://scenes/App.tscn"))
	var w2 = app2.game.world_view
	_check("sigil stays read after reload", w2.sigil_read())
	_check("sigil discovery survives reload", app2.game.game_state.discoveries.has("discovery.01.three_notch_mark"))
	_eq("world rebuilt to the saved tally after reload", w2.lit_count(), 2)
	if app2.get_parent() != null:
		app2.get_parent().remove_child(app2)
	app2.free()
	if had:
		var wr := FileAccess.open(saved, FileAccess.WRITE)
		wr.store_string(backup)
		wr.close()
	else:
		SaveManager.delete_at_path(saved)

## EPIC 0.4 Milestone A: the single interaction arbiter. Deterministic replay of touch
## sequences through the real classifier + the real Main scene, proving the eight input
## acceptance points (face mapping, single command, cancel, UI/world pass-through,
## camera-only no puzzle mutation, multi-touch/animation safety, domain equivalence).
func _test_interaction_arbiter() -> void:
	print("[interaction arbiter]")
	var m = load("res://scenes/Main.tscn").instantiate()
	root.add_child(m)
	m._ready()
	var cam: Camera3D = m.get_node("Camera3D")
	var router: InteractionRouter = m.get_node("InteractionRouter")
	_check("router present and wired to the camera", router != null and cam != null and router.camera == cam)
	if router == null or cam == null:
		if m.get_parent() != null:
			m.get_parent().remove_child(m)
		m.free()
		return
	router.ui_hit_test = func(_p): return false
	var vp: Viewport = m.get_viewport()
	var vsize := Vector2(720, 1280)
	if vp != null:
		vsize = vp.get_visible_rect().size
	router.viewport_size = vsize
	var center := vsize * 0.5
	var twists: Array = []
	router.twist_requested.connect(func(f, cw): twists.append([f, cw]))
	var orbits: Array = []
	router.orbit_requested.connect(func(dy, dp): orbits.append([dy, dp]))
	var worlds: Array = []
	router.world_tapped.connect(func(id): worlds.append(id))

	# --- 1. face mapping across view orientations -------------------------------
	var mismatches := 0
	var framed := 0
	for face in range(6):
		var n: Vector3 = InteractionRouter.FACE_NORMALS[face]
		var yaw := atan2(n.x, n.z)
		var pitch := asin(clampf(n.y, -1.0, 1.0))
		cam.set_orientation(yaw, maxf(0.25, pitch), 7.3)
		# Offset from the centre so the hit point is not the degenerate face centre.
		var probe := center + Vector2(42, 18)
		var pr: Array = router.screen_ray(probe)
		var hit: Dictionary = router.raycast_cube(pr[0], pr[1])
		if hit.is_empty() or int(hit.get("face", -1)) != face:
			continue  # this orientation did not expose the face cleanly; skip, not a failure
		framed += 1
		var p: Vector3 = hit["point"]
		var r := p - n * p.dot(n)
		var tangent := n.cross(r)
		var b: Basis = cam.global_transform.basis
		var drag_dir := Vector2(tangent.dot(b.x), -tangent.dot(b.y))
		if drag_dir.length() < 0.001:
			continue
		drag_dir = drag_dir.normalized() * 70.0
		var before: int = twists.size()
		router.begin(probe, 1000)
		router.move(probe + drag_dir * 0.5, 1030)
		router.move(probe + drag_dir, 1060)
		router.end(probe + drag_dir, 1070)
		var emitted: int = twists.size() - before
		if emitted != 1 or str(twists[twists.size() - 1][0]) != InteractionRouter.FACE_LETTERS[face]:
			mismatches += 1
	_check("every framed face maps to the correct intended move", framed >= 4 and mismatches == 0)

	# --- 2. direction reverses with drag direction ------------------------------
	cam.set_orientation(0.0, 0.7, 7.3)  # front face F head-on
	var probe2 := center + Vector2(42, 0)
	var pr2: Array = router.screen_ray(probe2)
	var h2: Dictionary = router.raycast_cube(pr2[0], pr2[1])
	var cw_a := true
	var cw_b := true
	if not h2.is_empty():
		var n2: Vector3 = InteractionRouter.FACE_NORMALS[int(h2["face"])]
		var r2: Vector3 = h2["point"] - n2 * (h2["point"]).dot(n2)
		var tan2: Vector3 = n2.cross(r2)
		var b2: Basis = cam.global_transform.basis
		var dir2 := Vector2(tan2.dot(b2.x), -tan2.dot(b2.y)).normalized() * 70.0
		var c0: int = twists.size()
		router.begin(probe2, 2000); router.move(probe2 + dir2, 2040); router.end(probe2 + dir2, 2050)
		router.begin(probe2, 3000); router.move(probe2 - dir2, 3040); router.end(probe2 - dir2, 3050)
		if twists.size() - c0 == 2:
			cw_a = bool(twists[c0][1])
			cw_b = bool(twists[c0 + 1][1])
	_check("opposite drags produce opposite turn directions", cw_a != cw_b)

	# --- 3. ambiguous gesture cancels (no command) ------------------------------
	cam.set_orientation(0.0, 0.7, 7.3)
	var c1: int = twists.size()
	router.begin(probe2, 4000)
	router.move(probe2 + Vector2(6, 0), 4020)  # below TWIST_START_PX
	router.end(probe2 + Vector2(6, 0), 4030)
	_check("ambiguous short drag cancels without a move", twists.size() == c1)

	# --- 4. UI passthrough consumes its own input -------------------------------
	router.ui_hit_test = func(_p): return true
	var c2: int = twists.size()
	var o2: int = orbits.size()
	router.begin(probe2, 5000)
	var ui_intent: String = router.current_intent()
	router.move(probe2 + Vector2(90, 0), 5030)
	router.end(probe2 + Vector2(90, 0), 5040)
	_check("a UI tap is classified ui_passthrough", ui_intent == "ui_passthrough")
	_check("a UI gesture leaks to neither cube nor camera", twists.size() == c2 and orbits.size() == o2)
	router.ui_hit_test = func(_p): return false

	# --- 5. world-target tap is a world command, not a turn or orbit -------------
	cam.set_orientation(0.0, 0.7, 7.3)
	var world_pos := Vector3(0, 0, 3.0)
	router.world_targets = [{"id": "test.target", "position": world_pos, "radius": 0.35}]
	var wscreen: Vector2 = router.project_to_screen(world_pos)
	var c3: int = twists.size()
	var o3: int = orbits.size()
	var w0: int = worlds.size()
	router.begin(wscreen, 6000)
	router.end(wscreen, 6080)
	_check("a world target tap emits a world command", worlds.size() == w0 + 1 and str(worlds[worlds.size() - 1]) == "test.target")
	_check("a world tap does not twist or orbit", twists.size() == c3 and orbits.size() == o3)

	# --- 6. camera-only gesture never mutates the puzzle ------------------------
	router.world_targets = []
	var corner := Vector2(6, 6)
	var prc: Array = router.screen_ray(corner)
	if not router.raycast_cube(prc[0], prc[1]).is_empty():
		corner = Vector2(vsize.x - 6, 6)
	var moves_before: int = m.engine.move_count()
	var o4: int = orbits.size()
	router.begin(corner, 7000)
	router.move(corner + Vector2(0, 40), 7040)
	router.move(corner + Vector2(0, 80), 7080)
	router.end(corner + Vector2(0, 80), 7090)
	_check("an off-cube drag orbits the camera", orbits.size() > o4)
	_check("a camera drag does not mutate the puzzle", m.engine.move_count() == moves_before)

	# --- 7. multi-touch during a twist cancels (never a partial twist) ----------
	cam.set_orientation(0.0, 0.7, 7.3)
	var c5: int = twists.size()
	router.begin(probe2, 8000)
	router.move(probe2 + Vector2(40, 0), 8030)  # now a puzzle intent
	var mid_intent: String = router.current_intent()
	router.begin(center + Vector2(-80, -80), 8040, 1)  # second finger
	var after_second: String = router.current_intent()
	router.end(probe2 + Vector2(40, 0), 8060)
	router.end(center + Vector2(-80, -80), 8065, 1)
	_check("a drag on the cube becomes a puzzle intent", mid_intent == "puzzle")
	_check("a second finger cancels the twist", after_second == "cancelled")
	_check("a cancelled multi-touch twist emits no move", twists.size() == c5)

	# --- 8. animation safety + domain equivalence -------------------------------
	while m.is_animating():
		m.cube_view.skip_animation()
	m.restart_level()
	_check("restart returns the engine to the level's scrambled state", not m.engine.is_solved())
	var c6: int = twists.size()
	var start_fp: String = m.engine.state.fingerprint()
	router.begin(probe2, 9000)
	router.move(probe2 + Vector2(60, 0), 9030)
	router.end(probe2 + Vector2(60, 0), 9040)
	var emitted_face := ""
	var emitted_cw := true
	if twists.size() > c6:
		emitted_face = str(twists[c6][0])
		emitted_cw = bool(twists[c6][1])
	_check("a committed twist emits exactly one command", twists.size() == c6 + 1)
	# While the turn animates, a second gesture must not advance the logical state.
	var moves_mid: int = m.engine.move_count()
	router.begin(probe2, 9100)
	router.move(probe2 + Vector2(60, 0), 9130)
	router.end(probe2 + Vector2(60, 0), 9140)
	_check("no new move corrupts state while animating", m.engine.move_count() == moves_mid)
	while m.is_animating():
		m.cube_view.skip_animation()
	# The gesture path produces the same authoritative domain result as the equivalent
	# legal controller move applied to the same start state (the level's own scramble).
	var via_gesture: String = m.engine.state.fingerprint()
	var ref := CubeState.new(m.engine.state.n)
	for sm in m.engine._scramble_moves:
		ref.apply_move(sm)
	ref.apply_move(MoveTable.face_move(emitted_face, emitted_cw))
	_check("the gesture move equals the same legal controller move", ref.fingerprint() == via_gesture)
	_check("the rendered cube settled to the authoritative state",
			not m.cube_view.is_animating() and m.cube_view._facelets.size() == 6 * m.engine.state.n * m.engine.state.n)
	_check("gesture start fingerprint differed from solved", start_fp != _solved_fp(2))

	if m.get_parent() != null:
		m.get_parent().remove_child(m)
	m.free()


## EPIC 0.4 Milestone B: the gameplay HUD must stay readable on a narrow portrait screen
## (objective + move count pinned in a non-scrolling top banner) and a first solve must not
## yank the puzzle away — the completion panel offers the next step instead.
func _test_hud_compact_and_completion() -> void:
	print("[hud compact + non-interrupting completion]")
	var saved := "user://craftcube_save.json"
	var had := FileAccess.file_exists(saved)
	var backup := FileAccess.get_file_as_string(saved) if had else ""
	SaveManager.delete_at_path(saved)
	var m = load("res://scenes/Main.tscn").instantiate()
	root.add_child(m)
	m._ready()
	var hud = m.get_node("HUD")
	# The status (objective + moves) and title must NOT be inside the ScrollContainer, so they
	# stay pinned even when the control column overflows on a short screen.
	var scroll: ScrollContainer = null
	var node: Node = hud._status.get_parent()
	while node != null and scroll == null:
		if node is ScrollContainer:
			scroll = node
		node = node.get_parent()
	_check("the move/objective banner is pinned (not scrolled)", scroll == null)
	# A scroll container still exists for the control column, so nothing clips.
	var has_scroll := false
	for c in _all_descendants(hud):
		if c is ScrollContainer:
			has_scroll = true
	_check("a scroll container still holds the control column", has_scroll)
	_check("completion panel starts hidden", not hud._solved_panel.visible)

	# Solve level 1 through the real path; the panel must appear without leaving gameplay.
	m.load_level(0)
	var guard := 0
	while not m.engine.is_solved() and guard < 80:
		if not m.guided_move():
			break
		while m.is_animating():
			m.cube_view.skip_animation()
		guard += 1
	_check("level 1 solved for the completion panel", m.engine.is_solved())
	_check("confirm_solve succeeds", m.confirm_solve())
	_check("the completion panel appears on solve", hud._solved_panel.visible)
	_check("the completion panel names the level and result", hud._solved_label.text.contains("Solved") and hud._solved_label.text.contains("Moves"))
	_check("the player is still on the same level after the panel", m.current_index == 0)
	# The HUD node stays visible (the harness does not attach nodes to a live tree, so
	# `is_visible_in_tree()` is not meaningful here; the node's own flag is).
	_check("the gameplay HUD stays visible after the panel", hud.visible)
	# Continue advances to the next level via the real load path.
	hud._on_continue_pressed()
	_check("continue advances to level 2", m.current_index == 1)
	_check("the completion panel hides after continuing", not hud._solved_panel.visible)
	if m.get_parent() != null:
		m.get_parent().remove_child(m)
	m.free()
	if had:
		var w := FileAccess.open(saved, FileAccess.WRITE)
		w.store_string(backup)
		w.close()
	else:
		SaveManager.delete_at_path(saved)

func _all_descendants(node: Node) -> Array:
	var out: Array = []
	for c in node.get_children():
		out.append(c)
		out.append_array(_all_descendants(c))
	return out


func _mount_app(packed: PackedScene) -> Node:
	var app := packed.instantiate()
	get_root().add_child(app)
	# The test SceneTree runs entirely inside `_initialize`, before the tree's first frame, so
	# node `_ready` is not delivered automatically. Invoke the app's `_ready` (which mounts the
	# single gameplay instance), then ready that subtree bottom-up — the same order Godot uses —
	# so the HUD readies before the controller, exactly as at runtime.
	app._ready()
	_force_ready(app.game)
	return app

func _force_ready(node: Node) -> void:
	if node == null:
		return
	for c in node.get_children():
		_force_ready(c)
	if not node.is_node_ready() and node.has_method("_ready"):
		node._ready()

## Solve the level currently loaded in an app's gameplay controller through the real guided
## turn path (settling each animation), then confirm. Returns true when the level completed.
func _solve_current(app: Node) -> bool:
	var guard := 0
	while not app.game.engine.is_solved() and guard < 80:
		if not app.game.guided_move():
			break
		while app.game.is_animating():
			app.game.cube_view.skip_animation()
		guard += 1
	if not app.game.engine.is_solved():
		return false
	return app.game.confirm_solve()

## Concatenate every Label's text in a subtree (for asserting what a screen really shows).
func _all_label_text(node: Node) -> String:
	var out := ""
	if node is Label:
		out += str(node.text) + "\n"
	for c in node.get_children():
		out += _all_label_text(c)
	return out

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

## EPIC 0.4 Milestone D: the scoped Beat 5 world choice. Proves the choice is unavailable
## before its beat, records exactly once, drives the world from truth (not an event), persists
## across reload, and that the tappable path nodes are gated on the same availability.
func _test_world_choices() -> void:
	print("[world choices]")
	var saved := "user://craftcube_save.json"
	var had := FileAccess.file_exists(saved)
	var backup := FileAccess.get_file_as_string(saved) if had else ""
	SaveManager.delete_at_path(saved)
	var app = _mount_app(load("res://scenes/App.tscn"))
	app._begin_new_game()
	var w = app.game.world_view
	# Two path nodes are built as world scenery from the start.
	_eq("two path-choice nodes are built", w.choice_node_count(), 2)
	# The choice beat is unavailable on a fresh game (level 2 not yet solved)...
	_check("first-node choice unavailable on a fresh game", not app.game.first_node_choice_available())
	_check("no path node is tappable before the beat", not _has_target(w, WorldView.TARGET_NODE_NEAR) and not _has_target(w, WorldView.TARGET_NODE_FAR))
	# ...so a tap through the arbiter records nothing.
	app.game.router.world_tapped.emit(WorldView.TARGET_NODE_NEAR)
	_check("tapping a node before the beat records no choice", not app.game.game_state.has_choice(GameController.FIRST_NODE_CHOICE))
	# Solve level 2 (the seed bed) to reach the Beat 5 moment.
	app._play_level(0)
	_check("level 1 solved for the choice test", _solve_current(app))
	app._play_level(1)
	_check("level 2 solved for the choice test", _solve_current(app))
	_check("first-node choice becomes available after level 2", app.game.first_node_choice_available())
	_check("path nodes become tappable after the beat", _has_target(w, WorldView.TARGET_NODE_NEAR) and _has_target(w, WorldView.TARGET_NODE_FAR))
	# A real tap on the near node records the choice and lights it; the far node wakes in reply.
	app.game.router.world_tapped.emit(WorldView.TARGET_NODE_NEAR)
	_eq("tap records the near choice", app.game.first_node_choice(), "near")
	_check("chosen node is lit", w.choice_node_lit("near"))
	_check("the other node wakes in reply (not lit as chosen)", not w.choice_node_lit("far"))
	_check("choice world flag set", app.game.game_state.world_flags.has("ch01_node_near"))
	# Re-selecting the same option reports no change (idempotent), so no reward can duplicate.
	var changed: bool = app.game.record_choice(GameController.FIRST_NODE_CHOICE, "near")
	_check("re-selecting the same option is not a change", not changed)
	# Changing the decision is allowed and updates the world from the recorded choice.
	app.game.record_choice(GameController.FIRST_NODE_CHOICE, "far")
	_eq("decision can be changed", app.game.first_node_choice(), "far")
	_check("changing the choice re-lights the far node", w.choice_node_lit("far"))
	_check("the previously chosen node is no longer the chosen one", not w.choice_node_lit("near"))
	# Persist and reload: the choice survives and the world is rebuilt from the recorded value.
	app.game.save_progress()
	if app.get_parent() != null:
		app.get_parent().remove_child(app)
	app.free()
	var app2 = _mount_app(load("res://scenes/App.tscn"))
	var w2 = app2.game.world_view
	_eq("choice survives reload", app2.game.first_node_choice(), "far")
	_check("world rebuilt from the recorded choice after reload", w2.choice_node_lit("far") and not w2.choice_node_lit("near"))
	if app2.get_parent() != null:
		app2.get_parent().remove_child(app2)
	app2.free()
	if had:
		var wr := FileAccess.open(saved, FileAccess.WRITE)
		wr.store_string(backup)
		wr.close()
	else:
		SaveManager.delete_at_path(saved)

## EPIC 0.4 Milestone D: schema migration from the EPIC 0.3 version-2 save to version 3. A v2
## save has mastery records but no `world_choices`; every field must survive and the upgraded
## file must be written as version 3. Also proves a v1 save skips straight to v3 unchanged.
func _test_save_v2_to_v3_migration() -> void:
	print("[save v2 -> v3 migration]")
	var path := "user://t_migrate_v3.json"
	SaveManager.delete_at_path(path)
	var v2 := {
		"save_version": 2,
		"solved_levels": ["level.01.awaken", "level.01.seed_bed", "level.01.hollow_stone"],
		"discoveries": ["discovery.01.first_pulse", "discovery.01.stone_mark"],
		"owned_equipment": ["equipment.rootweave_gauntlet"],
		"loadout": ["equipment.rootweave_gauntlet"],
		"world_flags": {"mechanism_awakens": true, "seed_grows": true, "stone_marks_awaken": true},
		"current_level_index": 3,
		"level_records": {"level.01.awaken": {"best_moves": 3, "best_stars": 3, "attempts": 2, "hints": 1}},
	}
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(v2))
	f.close()
	var g := SaveManager.load_from_path(path)
	_check("v2 solved levels preserved", g.is_solved("level.01.hollow_stone"))
	_check("v2 mastery record preserved", g.best_stars("level.01.awaken") == 3 and g.best_moves("level.01.awaken") == 3)
	_check("v2 equipment preserved", g.owns("equipment.rootweave_gauntlet"))
	_check("v2 world flags preserved", g.world_flags.has("stone_marks_awaken"))
	_eq("v2 campaign position preserved", g.current_level_index, 3)
	_check("v2 save has no world choices (empty table)", g.world_choices.is_empty())
	# The next write must be schema version 3 and still carry every v2 field.
	SaveManager.save_to_path(g, path)
	var reread := SaveManager.load_from_path(path)
	_eq("upgraded save is version 3", int(reread.to_dict().get("save_version", 0)), 3)
	_check("upgrade keeps solved levels", reread.is_solved("level.01.seed_bed"))
	_check("upgrade keeps mastery", reread.best_stars("level.01.awaken") == 3)
	_check("upgrade keeps discoveries", reread.discoveries.has("discovery.01.stone_mark"))
	# A recorded choice round-trips through v3.
	reread.set_choice(GameController.FIRST_NODE_CHOICE, "far")
	SaveManager.save_to_path(reread, path)
	var reread2 := SaveManager.load_from_path(path)
	_eq("v3 choice round-trips", reread2.choice(GameController.FIRST_NODE_CHOICE, ""), "far")
	# Malformed world_choices are coerced away, never trusted.
	var v3bad := {"save_version": 3, "solved_levels": [], "world_choices": {"ok": "near", "bad_num": 5, "": "x"}}
	f = FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(v3bad))
	f.close()
	var gb := SaveManager.load_from_path(path)
	_eq("valid choice kept", gb.choice("ok", ""), "near")
	_check("non-string choice dropped", not gb.has_choice("bad_num"))
	_check("empty-key choice dropped", not gb.has_choice(""))
	# A version-1 save (no records, no choices) upgrades straight to v3 unchanged.
	var v1 := {
		"save_version": 1,
		"solved_levels": ["level.01.awaken"],
		"discoveries": [],
		"owned_equipment": [],
		"loadout": [],
		"world_flags": {},
		"current_level_index": 1,
	}
	f = FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(v1))
	f.close()
	var g1 := SaveManager.load_from_path(path)
	_check("v1 solved level survives to v3", g1.is_solved("level.01.awaken"))
	_check("v1 -> v3 leaves choices empty", g1.world_choices.is_empty())
	SaveManager.save_to_path(g1, path)
	var g1b := SaveManager.load_from_path(path)
	_eq("v1 upgraded save is version 3", int(g1b.to_dict().get("save_version", 0)), 3)
	SaveManager.delete_at_path(path)

func _has_target(w, target_id: String) -> bool:
	for t in w.interactive_targets():
		if str(t["id"]) == target_id:
			return true
	return false

## Collect the text of every Label AND Button in a subtree. Button captions (e.g. "Unequip")
## are not Labels, so a label-only scan would miss them and a naive `contains("Equip")` would
## match the "Equipment" heading — this helper lets a test assert the real control caption.
func _all_ui_text(node: Node) -> String:
	var out := ""
	if node is Label or node is Button:
		out += str(node.text) + "\n"
	for c in node.get_children():
		out += _all_ui_text(c)
	return out

## EPIC 0.4 Milestone D: the item discovery/use loop. Proves equipment is granted through the
## real reward path, appears in the journal's equipment panel, equipping/unequipping goes
## through real GameState, changes the live capability readout, persists across reload, and
## cannot equip an unowned item.
func _test_equipment_use_loop() -> void:
	print("[equipment use loop]")
	var saved := "user://craftcube_save.json"
	var had := FileAccess.file_exists(saved)
	var backup := FileAccess.get_file_as_string(saved) if had else ""
	SaveManager.delete_at_path(saved)
	var app = _mount_app(load("res://scenes/App.tscn"))
	app._begin_new_game()
	# A fresh game owns nothing; the panel shows the empty state, not a phantom item.
	app._open_journal()
	_check("fresh journal owns no equipment", app.game.game_state.owned_equipment.is_empty())
	_check("empty equipment panel explains how to earn items", _all_label_text(app).contains("No equipment yet"))
	_check("no resonance capability before the gauntlet", not app.game.game_state.has_capability("resonance"))
	# Earn the Rootweave Gauntlet by completing level 3 (its authored reward).
	app._play_level(0)
	_check("level 1 solved for equipment test", _solve_current(app))
	app._play_level(1)
	_check("level 2 solved for equipment test", _solve_current(app))
	app._play_level(2)
	_check("level 3 solved for equipment test", _solve_current(app))
	_check("gauntlet granted by level 3 reward", app.game.game_state.owns("equipment.rootweave_gauntlet"))
	_check("granted gauntlet is auto-equipped", app.game.game_state.is_equipped("equipment.rootweave_gauntlet"))
	_check("resonance capability active while equipped", app.game.game_state.has_capability("resonance"))
	# The journal shows the item with its real name and an Unequip control (it is equipped).
	app._open_journal()
	var jt := _all_ui_text(app)
	_check("journal shows the gauntlet by name", jt.contains("Rootweave Gauntlet"))
	_check("journal offers Unequip while equipped", jt.contains("Unequip"))
	# Unequip through the real path: capability turns off, panel offers Equip again.
	app._toggle_equip("equipment.rootweave_gauntlet")
	_check("unequip removes the capability", not app.game.game_state.has_capability("resonance"))
	app._open_journal()
	_check("journal offers Equip once unequipped", _all_ui_text(app).contains("Equip"))
	# Re-equip and confirm the live HUD readout reflects the capability again.
	app._toggle_equip("equipment.rootweave_gauntlet")
	_check("re-equip restores the capability", app.game.game_state.has_capability("resonance"))
	var hud = app.game.get_node_or_null("HUD")
	_check("live HUD resonance line is populated while equipped", hud != null and hud._resonance.text.contains("Resonance"))
	# An unowned item cannot be equipped (no phantom loadout entries).
	app._toggle_equip("equipment.stone_lens")
	_check("unowned item cannot be equipped", not app.game.game_state.is_equipped("equipment.stone_lens"))
	# Persist and reload: ownership and equipped state survive.
	app.game.save_progress()
	if app.get_parent() != null:
		app.get_parent().remove_child(app)
	app.free()
	var app2 = _mount_app(load("res://scenes/App.tscn"))
	_check("equipment survives reload", app2.game.game_state.owns("equipment.rootweave_gauntlet"))
	_check("equipped state survives reload", app2.game.game_state.is_equipped("equipment.rootweave_gauntlet"))
	_check("capability survives reload", app2.game.game_state.has_capability("resonance"))
	if app2.get_parent() != null:
		app2.get_parent().remove_child(app2)
	app2.free()
	if had:
		var wr := FileAccess.open(saved, FileAccess.WRITE)
		wr.store_string(backup)
		wr.close()
	else:
		SaveManager.delete_at_path(saved)

# =======================================================================================
# EPIC 0.4 Milestone E — gameplay audio
# =======================================================================================

## The audio director synthesises a distinct cue for every vocabulary entry, keeps a bounded
## player pool, and honours mute without losing the request record (so the real event path
## stays testable even when no audio device exists).
func _test_audio_director_cues() -> void:
	print("[audio director cues]")
	var p := "user://t_audio_settings.json"
	SaveManager.delete_settings(p)
	var d := AudioDirector.new()
	d.settings_path = p
	root.add_child(d)
	d._ready()
	_eq("audio director generates one cue per vocabulary entry", d.cue_count(), 7)
	var stream: AudioStreamWAV = d._streams[AudioDirector.CUE_TURN]
	_check("a cue is a real 16-bit PCM stream", stream != null and stream.format == AudioStreamWAV.FORMAT_16_BITS and stream.data.size() > 0)
	_check("turn and solve cues are different samples", d._streams[AudioDirector.CUE_TURN].data != d._streams[AudioDirector.CUE_SOLVE].data)
	_check("world and solve cues are different samples", d._streams[AudioDirector.CUE_WORLD].data != d._streams[AudioDirector.CUE_SOLVE].data)
	_check("discovery and world cues are different samples", d._streams[AudioDirector.CUE_DISCOVERY].data != d._streams[AudioDirector.CUE_WORLD].data)
	_check("player pool is bounded", d.pool_size() <= AudioDirector.POOL_SIZE)
	d.request(AudioDirector.CUE_TURN)
	_eq("turn cue request count is 1", d.request_count(AudioDirector.CUE_TURN), 1)
	d.set_muted(true)
	var played: bool = d.request(AudioDirector.CUE_SOLVE)
	_check("muted request does not play", not played)
	_eq("muted request is still recorded", d.request_count(AudioDirector.CUE_SOLVE), 1)
	_check("mute is persisted to the settings file", bool(SaveManager.load_settings(p).get("audio_muted", false)))
	d.set_muted(false)
	_check("unmute is persisted", not bool(SaveManager.load_settings(p).get("audio_muted", false)))
	if d.get_parent() != null:
		d.get_parent().remove_child(d)
	d.free()
	SaveManager.delete_settings(p)

## Real gameplay events must request the correct cues through the single audio director.
func _test_audio_event_wiring() -> void:
	print("[audio event wiring]")
	var saved := "user://craftcube_save.json"
	var had := FileAccess.file_exists(saved)
	var backup := FileAccess.get_file_as_string(saved) if had else ""
	SaveManager.delete_at_path(saved)
	var app = _mount_app(load("res://scenes/App.tscn"))
	app._begin_new_game()
	var a = app.game.audio
	_check("the gameplay scene has an audio director", a != null)
	var before_turn: int = a.request_count(AudioDirector.CUE_TURN)
	app.game.load_level(0)
	app.game.try_move("U", true, false)
	_check("a legal turn requests the turn cue", a.request_count(AudioDirector.CUE_TURN) == before_turn + 1)
	app.game.game_state.mark_solved("level.01.awaken")
	app.game.game_state.mark_solved("level.01.seed_bed")
	app.game.load_level(2)
	var before_ref: int = a.request_count(AudioDirector.CUE_REFUSED)
	app.game.try_move("U", true, false)
	_check("an illegal/locked move requests the refused cue", a.request_count(AudioDirector.CUE_REFUSED) > before_ref)
	SaveManager.delete_at_path(saved)
	app._begin_new_game()
	app._play_level(0)
	var s_before: int = a.request_count(AudioDirector.CUE_SOLVE)
	var w_before: int = a.request_count(AudioDirector.CUE_WORLD)
	_check("level 1 solved for audio wiring", _solve_current(app))
	_eq("a first solve requests the solve cue once", a.request_count(AudioDirector.CUE_SOLVE), s_before + 1)
	_eq("a first solve requests the world cue once", a.request_count(AudioDirector.CUE_WORLD), w_before + 1)
	app._play_level(0)
	_solve_current(app)
	_eq("a replay does not repeat the solve cue", a.request_count(AudioDirector.CUE_SOLVE), s_before + 1)
	app._play_level(1)
	_solve_current(app)
	var nox_before: int = a.request_count(AudioDirector.CUE_NOX)
	app._play_level(2)
	_solve_current(app)
	_eq("the Nox awakening requests the nox cue once", a.request_count(AudioDirector.CUE_NOX), nox_before + 1)
	var c_before: int = a.request_count(AudioDirector.CUE_CHOICE)
	app.game.record_choice(GameController.FIRST_NODE_CHOICE, "far")
	_check("recording a world choice requests the choice cue", a.request_count(AudioDirector.CUE_CHOICE) > c_before)
	SaveManager.delete_at_path(saved)
	app._begin_new_game()
	app._play_level(0)
	_solve_current(app)
	var d_before: int = a.request_count(AudioDirector.CUE_DISCOVERY)
	app._play_level(1)
	_solve_current(app)
	_check("a new discovery requests the discovery cue", a.request_count(AudioDirector.CUE_DISCOVERY) > d_before)
	if app.get_parent() != null:
		app.get_parent().remove_child(app)
	app.free()
	if had:
		var w := FileAccess.open(saved, FileAccess.WRITE)
		w.store_string(backup)
		w.close()
	else:
		SaveManager.delete_at_path(saved)

## The mute setting persists across a restart; malformed settings fall back to the default.
func _test_audio_settings_persistence() -> void:
	print("[audio settings persistence]")
	var p := "user://t_audio_persist.json"
	SaveManager.delete_settings(p)
	var d := AudioDirector.new()
	d.settings_path = p
	root.add_child(d)
	d._ready()
	_check("audio is unmuted by default on a clean install", not d.muted)
	d.set_muted(true)
	if d.get_parent() != null:
		d.get_parent().remove_child(d)
	d.free()
	var d2 := AudioDirector.new()
	d2.settings_path = p
	root.add_child(d2)
	d2._ready()
	_check("a fresh audio director restores the persisted mute", d2.muted)
	if d2.get_parent() != null:
		d2.get_parent().remove_child(d2)
	d2.free()
	var f := FileAccess.open(p, FileAccess.WRITE)
	f.store_string("{broken")
	f.close()
	var d3 := AudioDirector.new()
	d3.settings_path = p
	root.add_child(d3)
	d3._ready()
	_check("malformed audio settings fall back to unmuted default", not d3.muted)
	if d3.get_parent() != null:
		d3.get_parent().remove_child(d3)
	d3.free()
	SaveManager.delete_settings(p)
# =======================================================================================
# EPIC 0.4 Milestone F — world item loop (cache discovery + Stone Lens use)
# =======================================================================================

## The cache is a genuine in-world discovery: it appears only after the restored area exists
## (levels 1–2 solved), grants the Stone Lens + discovery exactly once, then is gone for good.
func _test_world_cache_item_loop() -> void:
	print("[world cache item loop]")
	var saved := "user://craftcube_save.json"
	var had := FileAccess.file_exists(saved)
	var backup := FileAccess.get_file_as_string(saved) if had else ""
	SaveManager.delete_at_path(saved)
	var app = _mount_app(load("res://scenes/App.tscn"))
	app._begin_new_game()
	# Fresh world: no cache exists and the router exposes no cache target.
	_check("fresh world has no cache", not app.game.world_view.cache_available())
	_check("fresh world exposes no cache target", not _has_target(app.game.world_view, WorldView.TARGET_CACHE))
	# Solve level 1: still no cache (needs the seed bed too).
	app._play_level(0)
	_check("level 1 solved for cache test", _solve_current(app))
	_check("cache absent after only level 1", not app.game.world_view.cache_available())
	# Solve level 2: the restored area exists, so the cache appears and is tappable.
	app._play_level(1)
	_check("level 2 solved for cache test", _solve_current(app))
	_check("cache appears once the restored area exists", app.game.world_view.cache_available())
	_check("cache is a registered world target", _has_target(app.game.world_view, WorldView.TARGET_CACHE))
	# Take it through the real world-tap path.
	app._on_world_tapped(WorldView.TARGET_CACHE)
	_check("taking the cache grants the Stone Lens", app.game.game_state.owns("equipment.stone_lens"))
	_check("taking the cache records its discovery", app.game.game_state.discoveries.has("discovery.01.stone_lens"))
	_check("taking the cache sets the world flag", bool(app.game.game_state.world_flags.get("cache_taken", false)))
	_check("the cache is gone after taking", not app.game.world_view.cache_available())
	_check("the taken cache is no longer a target", not _has_target(app.game.world_view, WorldView.TARGET_CACHE))
	# A repeat tap cannot re-grant or resurrect the cache.
	app._on_world_tapped(WorldView.TARGET_CACHE)
	_check("the cache stays gone on a repeat tap", not app.game.world_view.cache_available())
	_check("repeat tap does not duplicate the item", app.game.game_state.owned_equipment.count("equipment.stone_lens") == 1)
	if app.get_parent() != null:
		app.get_parent().remove_child(app)
	app.free()
	if had:
		var w := FileAccess.open(saved, FileAccess.WRITE)
		w.store_string(backup)
		w.close()
	else:
		SaveManager.delete_at_path(saved)

## The Stone Lens is a real item-use loop: the veiled mark only becomes tappable while the lens
## is owned, and revealing it makes the hidden glyph meshes visible — exactly once.
func _test_veiled_mark_item_use() -> void:
	print("[veiled mark item use]")
	var saved := "user://craftcube_save.json"
	var had := FileAccess.file_exists(saved)
	var backup := FileAccess.get_file_as_string(saved) if had else ""
	SaveManager.delete_at_path(saved)
	var app = _mount_app(load("res://scenes/App.tscn"))
	app._begin_new_game()
	# Without the lens the mark is scenery, not a target.
	app.game.world_view.set_lens_owned(false)
	_check("veiled mark is not tappable without the lens", not app.game.world_view.veiled_mark_available())
	_check("veiled mark is not a target without the lens", not _has_target(app.game.world_view, WorldView.TARGET_VEILED_MARK))
	_check("the glyph is not rendered before the reveal", not app.game.world_view.veiled_glyph_visible())
	# Grant the lens directly (item acquisition is covered by the cache test) and refresh targets.
	app.game.game_state.grant_equipment("equipment.stone_lens")
	app.game.world_view.set_lens_owned(true)
	app._refresh_world_targets()
	_check("veiled mark becomes tappable once the lens is owned", app.game.world_view.veiled_mark_available())
	_check("veiled mark is a target once the lens is owned", _has_target(app.game.world_view, WorldView.TARGET_VEILED_MARK))
	# Use the lens through the real world-tap path.
	app._on_world_tapped(WorldView.TARGET_VEILED_MARK)
	_check("using the lens reveals the mark", app.game.world_view.veiled_revealed())
	_check("the revealed glyph is actually rendered", app.game.world_view.veiled_glyph_visible())
	_check("the reveal records its discovery", app.game.game_state.discoveries.has("discovery.01.veiled_glyph"))
	_check("the reveal sets the world flag", bool(app.game.game_state.world_flags.get("veiled_mark_revealed", false)))
	_check("a revealed mark is no longer a target", not _has_target(app.game.world_view, WorldView.TARGET_VEILED_MARK))
	# A repeat use cannot re-grant or re-reveal.
	app._on_world_tapped(WorldView.TARGET_VEILED_MARK)
	_check("repeat use does not duplicate the discovery", app.game.game_state.discoveries.count("discovery.01.veiled_glyph") == 1)
	if app.get_parent() != null:
		app.get_parent().remove_child(app)
	app.free()
	if had:
		var w := FileAccess.open(saved, FileAccess.WRITE)
		w.store_string(backup)
		w.close()
	else:
		SaveManager.delete_at_path(saved)

## The whole item loop survives save/reload: the cache stays taken, the mark stays revealed (with
## its glyph rendered), and neither reward nor discovery is re-granted on reload.
func _test_item_loop_persistence() -> void:
	print("[item loop persistence]")
	var saved := "user://craftcube_save.json"
	var had := FileAccess.file_exists(saved)
	var backup := FileAccess.get_file_as_string(saved) if had else ""
	SaveManager.delete_at_path(saved)
	var app = _mount_app(load("res://scenes/App.tscn"))
	app._begin_new_game()
	app._play_level(0)
	_solve_current(app)
	app._play_level(1)
	_solve_current(app)
	app._on_world_tapped(WorldView.TARGET_CACHE)
	app._on_world_tapped(WorldView.TARGET_VEILED_MARK)
	_check("lens owned before reload", app.game.game_state.owns("equipment.stone_lens"))
	_check("mark revealed before reload", app.game.world_view.veiled_revealed())
	app.game.save_progress()
	if app.get_parent() != null:
		app.get_parent().remove_child(app)
	app.free()
	# Reload: the world must reconstruct to the saved state without replaying any event.
	var app2 = _mount_app(load("res://scenes/App.tscn"))
	app2._continue_game()
	_check("lens survives reload", app2.game.game_state.owns("equipment.stone_lens"))
	_check("cache stays taken after reload", not app2.game.world_view.cache_available())
	_check("cache-taken flag survives reload", bool(app2.game.game_state.world_flags.get("cache_taken", false)))
	_check("mark stays revealed after reload", app2.game.world_view.veiled_revealed())
	_check("the revealed glyph is rendered after reload", app2.game.world_view.veiled_glyph_visible())
	_check("veiled-mark flag survives reload", bool(app2.game.game_state.world_flags.get("veiled_mark_revealed", false)))
	_check("both discoveries survive reload", app2.game.game_state.discoveries.has("discovery.01.stone_lens") and app2.game.game_state.discoveries.has("discovery.01.veiled_glyph"))
	_check("the lens is not duplicated on reload", app2.game.game_state.owned_equipment.count("equipment.stone_lens") == 1)
	# The journal lists both new discoveries by name after reload.
	app2._open_journal()
	var jt := _all_ui_text(app2)
	_check("journal shows the Stone Lens discovery", jt.contains("The Stone Lens"))
	_check("journal shows the Veiled Glyph discovery", jt.contains("The Veiled Glyph"))
	if app2.get_parent() != null:
		app2.get_parent().remove_child(app2)
	app2.free()
	if had:
		var w := FileAccess.open(saved, FileAccess.WRITE)
		w.store_string(backup)
		w.close()
	else:
		SaveManager.delete_at_path(saved)


