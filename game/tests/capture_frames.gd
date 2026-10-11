extends SceneTree

## Milestone B/C evidence capture: instantiate the real Main scene, settle a few frames,
## optionally drive the camera/hint, and write PNG frames. Run under Xvfb with
## --display-driver x11 --rendering-driver opengl3 (Mesa llvmpipe).
## Usage: godot --path game --resolution 720x1280 --display-driver x11 \
##          --rendering-driver opengl3 --script res://tests/capture_frames.gd

var _m: Node
var _saved_path := "user://craftcube_save.json"
var _saved_had := false
var _saved_backup := ""

func _initialize() -> void:
        # This script plays the chapter for real, which writes the player save. Preserve and
        # restore it so capturing evidence never destroys a player's or another test's save.
        _saved_had = FileAccess.file_exists(_saved_path)
        if _saved_had:
                _saved_backup = FileAccess.get_file_as_string(_saved_path)
        SaveManager.delete_at_path(_saved_path)
        _m = load("res://scenes/Main.tscn").instantiate()
        root.add_child(_m)
        await _capture("session10_initial.png")
        var cam = _m.get_node("Camera3D")
        cam.orbit(0.7, -0.2)
        cam.zoom(-1.0)
        for _i in range(30):
                cam._process(0.05)
        await _capture("session10_orbit.png")
        var hud = _m.get_node("HUD")
        hud._on_hint()
        cam.reset_view()
        await _capture("session10_hint.png")
        # EPIC 0.4 Milestone B: the non-interrupting completion panel. Solve level 1 for real
        # and capture the panel while the puzzle is still on screen.
        _m.load_level(0)
        var g1 := 0
        while not _m.engine.is_solved() and g1 < 40:
                if not _m.guided_move():
                        break
                while _m.is_animating():
                        _m.cube_view.skip_animation()
                g1 += 1
        _m.confirm_solve()
        await _capture("session11_completion.png")
        # Milestone C: play the chapter via the guide so the world's ward stones and the
        # companion (Nox) are revealed, then frame the world from a higher angle.
        for i in range(_m.levels.size()):
                _m.load_level(i)
                var guard := 0
                while not _m.engine.is_solved() and guard < 40:
                        if not _m.guided_move():
                                break
                        while _m.is_animating():
                                _m.cube_view.skip_animation()
                        guard += 1
                _m.confirm_solve()
                if i < _m.levels.size() - 1:
                        _m.next_level()
        cam.orbit(0.0, 0.35)
        cam.zoom(1.2)
        for _i in range(30):
                cam._process(0.05)
        await _capture("session10_world_complete.png")
        # Milestone C: the interactive three-notch sigil and the Nox dialogue it can open.
        # Free the Main instance first so only one Camera3D is current in the viewport.
        if _m.get_parent() != null:
                _m.get_parent().remove_child(_m)
        _m.free()
        _m = null
        var app = load("res://scenes/App.tscn").instantiate()
        root.add_child(app)
        app._ready()
        # Drive the world to the chapter-complete truth so the sigil and the companion are
        # genuinely revealed (no event replay: this is a state rebuild, not a playthrough).
        for lv in app.game.levels:
                app.game.game_state.mark_solved(str(lv["level_id"]))
        app.game.game_state.set_world_flag("stone_marks_awaken")
        app.game.world_view.sync_from_state(app.game.game_state.solved_levels.size(), app.game.game_state.world_flags)
        app._play_level(2)
        app._refresh_world_targets()
        _print_targets(app)
        # Hide the gameplay HUD so the capture frames the world itself, not the controls.
        await _capture("session12_world_sigil.png")
        app._read_sigil()
        await _capture("session12_sigil_clue.png")
        app._open_nox()
        await _capture("session12_nox_dialogue.png")
        if app.get_parent() != null:
                app.get_parent().remove_child(app)
        app.free()
        SaveManager.delete_at_path(_saved_path)
        if _saved_had:
                var w := FileAccess.open(_saved_path, FileAccess.WRITE)
                w.store_string(_saved_backup)
                w.close()
        quit(0)

## Print the world targets the arbiter would hit-test, with their projected screen
## positions, so a capture run can be checked for real rendered geometry.
func _print_targets(app: Node) -> void:
        var w = app.game.world_view
        for t in w.interactive_targets():
                var sp: Vector2 = app.game.router.project_to_screen(t["position"])
                print("target ", t["id"], " world=", t["position"], " screen=", sp)

func _capture(name: String) -> void:
        for _i in range(5):
                await process_frame
        var img: Image = root.get_texture().get_image()
        img.save_png("res://docs/evidence/screenshots/" + name)
        print("wrote ", name)
