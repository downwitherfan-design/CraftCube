extends SceneTree

## Evidence capture (Checkpoint E): drive the real App shell through its real navigation,
## capturing every player-facing screen into game/docs/evidence/runtime_recovery/.
var _app

func _initialize() -> void:
        var saved := "user://craftcube_save.json"
        var had := FileAccess.file_exists(saved)
        var backup := FileAccess.get_file_as_string(saved) if had else ""
        SaveManager.delete_at_path(saved)

        _app = load("res://scenes/App.tscn").instantiate()
        root.add_child(_app)
        _app._ready()
        await _ready_frames(40)
        await _shot("e01_title.png")

        # Fresh campaign: real New Game path.
        _app._begin_new_game()
        await _settle()
        await _shot("e02_level1_cube.png")

        # A real legal move + animation mid-sweep.
        _app.game.try_move("F", true)
        await _ready_frames(2)
        await _shot("e03_turn_midsweep.png")
        _app.game.cube_view.skip_animation()
        await _settle()
        await _shot("e04_turn_settled.png")

        # Hint path (real HUD control handler).
        var hud = _app.game.get_node_or_null("HUD")
        if hud:
                hud._on_hint()
        await _settle()
        await _shot("e05_hint.png")

        # Complete level 1 through the real guided path.
        _app.game.load_level(0)
        _solve_current()
        await _shot("e06_level1_solved.png")

        # Play the whole chapter so the world + Nox are genuinely revealed.
        for i in range(_app.game.levels.size()):
                _app.game.load_level(i)
                _solve_current()
                if i < _app.game.levels.size() - 1:
                        _app.game.next_level()
        await _settle()
        await _shot("e07_world_complete.png")

        _app._refresh_world_targets()
        _app._read_sigil()
        await _settle()
        await _shot("e08_sigil.png")

        _app._open_nox()
        await _ready_frames(5)
        await _shot("e09_nox.png")
        _app._open_map()
        await _settle()
        await _shot("e10_map.png")
        _app._open_journal()
        await _settle()
        await _shot("e11_journal.png")
        _app._open_settings()
        await _settle()
        await _shot("e12_settings.png")
        _app._open_title()
        await _settle()
        await _shot("e13_title_return.png")

        # Small portrait size for responsive check.
        if DisplayServer.get_name() != "headless":
                DisplayServer.window_set_size(Vector2i(360, 640))
        await _ready_frames(10)
        _app._open_map()
        await _settle()
        await _shot("e14_map_360.png")

        _app.queue_free()
        SaveManager.delete_at_path(saved)
        if had:
                var w := FileAccess.open(saved, FileAccess.WRITE)
                w.store_string(backup)
                w.close()
        quit(0)

func _solve_current() -> void:
        var guard := 0
        while not _app.game.engine.is_solved() and guard < 60:
                if not _app.game.guided_move():
                        break
                while _app.game.is_animating():
                        _app.game.cube_view.skip_animation()
                guard += 1
        _app.game.confirm_solve()

func _ready_frames(n: int) -> void:
        for _i in range(n):
                await process_frame

func _settle() -> void:
        await _ready_frames(12)

func _shot(name: String) -> void:
        for _i in range(4):
                await process_frame
        var img: Image = root.get_texture().get_image()
        img.save_png("res://docs/evidence/runtime_recovery/" + name)
        print("wrote ", name)
