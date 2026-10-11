extends SceneTree
## EPIC 0.5 Milestone E: runtime-quality evidence. Instantiates the real gameplay scene and
## the real application shell, then records the things that actually affect a mobile device:
##   * scene node / mesh / material counts (the "no heavy assets, procedural only" budget),
##   * steady-state frame time over a short window (software GL here - layout/geometry proof,
##     explicitly NOT a device GPU benchmark),
##   * that the app boots and reaches the title screen with the world mounted.
## Writes a JSON report next to the other evidence so the numbers are auditable.

const OUT := "res://docs/evidence/session15_runtime_quality.json"

var _frames := 0
var _accum := 0.0
var _min := 999999.0
var _max := 0.0

func _initialize() -> void:
	# Preserve any real player save: this run boots the game and may write progress.
	var save := "user://craftcube_save.json"
	var had := FileAccess.file_exists(save)
	var backup := FileAccess.get_file_as_string(save) if had else ""
	SaveManager.delete_at_path(save)

	var report := {}

	# --- gameplay scene (direct) -------------------------------------------------------
	var m: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(m)
	await _settle(20)
	report["gameplay"] = _measure_scene(m)
	await _sample(120)
	report["gameplay"]["frame_ms_avg"] = _accum / maxf(1.0, float(_frames))
	report["gameplay"]["frame_ms_min"] = _min
	report["gameplay"]["frame_ms_max"] = _max

	# --- application shell -------------------------------------------------------------
	if m.get_parent() != null:
		m.get_parent().remove_child(m)
	m.free()
	var app: Node = load("res://scenes/App.tscn").instantiate()
	root.add_child(app)
	app._ready()
	await _settle(10)
	report["app_boots_to_title"] = app.current_screen() == "title"
	report["app_screens"] = app._screen_roots.keys()
	# Enter gameplay through the real navigation path and measure the whole app tree.
	app._play_level(0)
	await _settle(10)
	report["app_gameplay_visible"] = app.game.visible
	report["app_backdrop_hidden_over_gameplay"] = not app._bg.visible
	report["app"] = _measure_scene(app)

	var f := FileAccess.open(OUT, FileAccess.WRITE)
	f.store_string(JSON.stringify(report, "  "))
	f.close()
	print("runtime-quality report written: ", OUT)
	print("gameplay nodes=", report["gameplay"]["nodes"],
		" meshes=", report["gameplay"]["meshes"],
		" frame_ms_avg=", report["gameplay"]["frame_ms_avg"])
	print("app nodes=", report["app"]["nodes"], " meshes=", report["app"]["meshes"])

	if app.get_parent() != null:
		app.get_parent().remove_child(app)
	app.free()
	SaveManager.delete_at_path(save)
	if had:
		var w := FileAccess.open(save, FileAccess.WRITE)
		w.store_string(backup)
		w.close()
	quit(0)

## Count the nodes, MeshInstance3D and distinct materials in a subtree.
func _measure_scene(n: Node) -> Dictionary:
	var nodes := 0
	var meshes := 0
	var mats := {}
	for c in _walk(n):
		nodes += 1
		if c is MeshInstance3D:
			meshes += 1
			var mm: Material = (c as MeshInstance3D).material_override
			if mm != null:
				mats[mm.get_instance_id()] = true
	return {"nodes": nodes, "meshes": meshes, "materials": mats.size()}

func _walk(n: Node) -> Array:
	var out: Array = []
	for c in n.get_children():
		out.append(c)
		out.append_array(_walk(c))
	return out

func _settle(frames: int) -> void:
	for _i in range(frames):
		await process_frame

## Sample per-frame deltas. Uses the SceneTree's frame signal timing via process_frame deltas.
func _sample(frames: int) -> void:
	_frames = 0
	_accum = 0.0
	_min = 999999.0
	_max = 0.0
	var prev := Time.get_ticks_usec()
	for _i in range(frames):
		await process_frame
		var now := Time.get_ticks_usec()
		var ms := float(now - prev) / 1000.0
		prev = now
		_frames += 1
		_accum += ms
		_min = minf(_min, ms)
		_max = maxf(_max, ms)
