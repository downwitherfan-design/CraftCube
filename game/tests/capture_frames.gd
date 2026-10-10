extends SceneTree

## Milestone B/C evidence capture: instantiate the real Main scene, settle a few frames,
## optionally drive the camera/hint, and write PNG frames. Run under Xvfb with
## --display-driver x11 --rendering-driver opengl3 (Mesa llvmpipe).
## Usage: godot --path game --resolution 720x1280 --display-driver x11 \
##          --rendering-driver opengl3 --script res://tests/capture_frames.gd

var _m: Node

func _initialize() -> void:
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
        quit(0)

func _capture(name: String) -> void:
        for _i in range(5):
                await process_frame
        var img: Image = root.get_texture().get_image()
        img.save_png("res://docs/evidence/screenshots/" + name)
        print("wrote ", name)
