# Rendered gameplay evidence — Session 9 (2026-10-10)

Real frames captured from the running Godot 4.7.2 project (`game/scenes/Main.tscn`), not
mock-ups. Renderer: OpenGL3 / Mesa llvmpipe under Xvfb at the real 720x1280 portrait canvas.

- `session9_initial.png` — scene on load (scrambled `level.01.awaken`), cube + HUD visible.
- `session9_after_moves.png` — after three animated turns (R, F, U) settled: the cube's
  colours visibly changed while the HUD stayed laid out, i.e. the animated view keeps the
  rendered cube consistent with the authoritative state.

Reproduce (requires Godot 4.7.2-stable and a virtual X server):

```bash
# A short SceneTree script that instantiates res://scenes/Main.tscn, waits a few frames,
# then saves root.get_texture().get_image() to PNG, run under:
xvfb-run -a -s "-screen 0 720x1280x24" \
  godot --path game --resolution 720x1280 \
  --display-driver x11 --rendering-driver opengl3 \
  --script res://tests/<capture_script>.gd
```

Note: this validates on-screen rendering of the slice. There is still no physical Android
device in this environment, so it is NOT a device playtest.
