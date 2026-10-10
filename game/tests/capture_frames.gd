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
        SaveManager.delete_at_path(_saved_path)
        if _saved_had:
                var w := FileAccess.open(_saved_path, FileAccess.WRITE)
                w.store_string(_saved_backup)
                w.close()
        quit(0)

func _capture(name: String) -> void:
        for _i in range(5):
                await process_frame
        var img: Image = root.get_texture().get_image()
        img.save_png("res://docs/evidence/screenshots/" + name)
        print("wrote ", name)
