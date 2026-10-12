class_name CubeView
extends Node3D

## 3D presentation of a CubeState. Builds one MeshInstance3D per facelet from primitive
## BoxMeshes with unshaded per-colour materials (no external assets). Grid geometry is
## defined so the cube spans [-1, 1] regardless of N.
##
## Facelets are placed from the domain's own facelet positions, so the rendered cube
## always matches the authoritative logical geometry, and turns are animated: a move
## selects the layer's facelets, sweeps them about the cube centre and, when the
## animation ends, the view re-syncs to the authoritative state and releases the lock.

## Face colours come from the shared palette so the cube reads as part of the same world.
## Face order matches CubeState.Face: U D L R F B.
const TURN_DURATION := 0.22
const SOLVE_FLASH := 0.5
## Gap between facelets (fraction of the tile) so tile separation is visible; the dark core
## shows through the seams instead of the tiles looking like one flat slab.
const TILE_GAP := 0.16
## The core is the dark "slab" the tiles sit on. It MUST be smaller than the facelet shell's
## outer surface (which is 1 - TILE_GAP/n), otherwise it encloses the tiles, wins the depth
## test and renders the whole cube as a black block (the reported "black screen" / invisible
## cube). CORE_INSET keeps it tucked just inside the tiles so only the seams show the core.
const CORE_INSET := 0.03

## The visual U face points up on screen because the domain's +Y face is U; the view is
## used directly (no flip). A mismatch here was a real defect where the objective face
## rendered at the bottom, out of the player's view.
var _facelets: Array = []          # MeshInstance3D per facelet index
var _materials: Array = []
var _n: int = 3
var _tile := 0.98
var _half := 1.0

# Camera-facing letters on the six faces so the player can tell which face a button twists.
var _glyphs: Array = []

var _animating := false

## Accessibility: when true, face turns settle instantly (no sweep). The logical lifecycle is
## unchanged, so gameplay is identical, only the visual duration changes.
var reduced_motion := false
var _active: Array = []
var _tween: Tween
var _pivot: Node3D
var _solve_flash := -1.0
var _pending_done: Callable
var _pending_state: CubeState

func build(state: CubeState) -> void:
	for c in get_children():
		c.queue_free()
	_facelets.clear()
	_glyphs.clear()
	_pivot = null
	_animating = false
	_active.clear()
	_solve_flash = -1.0
	_n = state.n
	_half = 1.0
	_tile = 2.0 / float(_n) * (1.0 - TILE_GAP)
	_materials.clear()
	for i in range(6):
		var m := StandardMaterial3D.new()
		m.albedo_color = CraftPalette.FACE_COLOURS[i]
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.roughness = 0.85
		_materials.append(m)
	_build_core()
	var box := BoxMesh.new()
	box.size = Vector3(_tile, _tile, _tile)
	_facelets.resize(6 * _n * _n)
	for face in range(6):
		for r in range(_n):
			for c in range(_n):
				var idx := face * _n * _n + r * _n + c
				var mi := MeshInstance3D.new()
				mi.mesh = box
				mi.material_override = _materials[_colour_of(state, face, r, c)]
				mi.position = _facelet_local_pos(state, face, r, c)
				add_child(mi)
				_facelets[idx] = mi
	_build_glyphs()

## A dark inner core the facelets sit on, so the seams between tiles read as depth. The core
## is deliberately SMALLER than the facelet shell (which reaches 1 - TILE_GAP/n) so it can
## never occlude the coloured tiles. No separate edge frame is added: a slightly larger frame
## would enclose the tiles and render the whole cube as a black block.
func _build_core() -> void:
	var core := MeshInstance3D.new()
	var core_mesh := BoxMesh.new()
	var outer := 1.0 - TILE_GAP / float(_n)
	var half: float = maxf(0.1, outer - CORE_INSET)
	core_mesh.size = Vector3(half * 2.0, half * 2.0, half * 2.0)
	core.mesh = core_mesh
	var core_mat := StandardMaterial3D.new()
	core_mat.albedo_color = CraftPalette.CUBE_BODY
	core_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	core.material_override = core_mat
	add_child(core)

## Small camera-facing letters on each face so the six buttons map to visible faces.
func _build_glyphs() -> void:
	var face_dirs := [
		Vector3(0, 1, 0), Vector3(0, -1, 0),
		Vector3(-1, 0, 0), Vector3(1, 0, 0),
		Vector3(0, 0, 1), Vector3(0, 0, -1),
	]
	var letters := ["U", "D", "L", "R", "F", "B"]
	for f in range(6):
		var lbl := Label3D.new()
		lbl.text = letters[f]
		lbl.font_size = 96
		lbl.outline_size = 12
		lbl.modulate = Color(0.08, 0.08, 0.1)
		lbl.outline_modulate = Color(0.95, 0.95, 0.95)
		lbl.position = face_dirs[f] * (_half + 0.09)
		lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		add_child(lbl)
		_glyphs.append(lbl)

## World position of a facelet in the current (settled) configuration. Derived from the
## domain position so the view and the truth layer can never disagree about geometry.
func _facelet_local_pos(state: CubeState, face: int, r: int, c: int) -> Vector3:
	var idx := face * _n * _n + r * _n + c
	var p: Vector3i = state._positions[idx]
	var step := 2.0 / float(_n)
	var xx := -_half + step * (float(p.x) + 0.5)
	var yy := -_half + step * (float(p.y) + 0.5)
	var zz := -_half + step * (float(p.z) + 0.5)
	var nrm: Vector3i = state._normals[idx]
	return Vector3(xx, yy, zz) + Vector3(nrm.x, nrm.y, nrm.z) * 0.006

func _colour_of(state: CubeState, face: int, r: int, c: int) -> int:
	var v := state.colours[face * _n * _n + r * _n + c]
	return (v / (_n * _n)) % 6

## Re-sync every facelet to the authoritative state (colour + position). Used on
## build/refresh and as the guaranteed settle step when an animation ends.
func refresh(state: CubeState) -> void:
	if _facelets.size() != 6 * _n * _n:
		build(state)
		return
	for face in range(6):
		for r in range(_n):
			for c in range(_n):
				var idx := face * _n * _n + r * _n + c
				var mi: MeshInstance3D = _facelets[idx]
				mi.material_override = _materials[_colour_of(state, face, r, c)]
				mi.position = _facelet_local_pos(state, face, r, c)
				if mi.get_parent() != self:
					mi.get_parent().remove_child(mi)
					add_child(mi)

func is_animating() -> bool:
	return _animating

## Animate a quarter turn of `move`'s facelets about the move axis. Returns false if an
## animation is already running; the caller must not advance the logic in that case.
func animate_move(move: Dictionary, state: CubeState, on_done: Callable = Callable()) -> bool:
	if _animating:
		return false
	var axis := int(move.get("axis", 0))
	var layer := int(move.get("layer", 0))
	if layer < 0:
		layer = MoveTable.resolve_layer(_n, str(move.get("face", "")), layer)
	var cw := bool(move.get("cw", true))

	_active.clear()
	for i in state.layer_indices(axis, layer):
		_active.append(_facelets[i])

	_pivot = Node3D.new()
	add_child(_pivot)
	for mi in _active:
		mi.get_parent().remove_child(mi)
		_pivot.add_child(mi)

	var target := _axis_vector(axis) * (PI * 0.5 if cw else -PI * 0.5)
	_animating = true
	_pending_done = on_done
	_pending_state = state
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# Reduced motion: keep the identical lifecycle (so the logic still advances on settle) but
	# make the sweep instantaneous. The turn still goes through the same _finish_move path.
	_tween.tween_property(_pivot, "rotation", target, TURN_DURATION if not reduced_motion else 0.0)
	_tween.tween_callback(_finish_move.bind(state, on_done))
	return true

## Test seam: complete the in-flight turn immediately through the same settle path the tween
## callback uses. Returns false when idle. Never used by gameplay input.
func skip_animation() -> bool:
	if not _animating:
		return false
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_finish_move(_pending_state, _pending_done)
	return true

func _axis_vector(axis: int) -> Vector3:
	match axis:
		0: return Vector3.RIGHT
		1: return Vector3.UP
		_: return Vector3.BACK

func _finish_move(_state: CubeState, on_done: Callable) -> void:
	if _pivot != null:
		_pivot.queue_free()
		_pivot = null
	_animating = false
	# Advance/authorise the truth layer FIRST, then re-sync the render from it. Ordering
	# matters: refreshing before the logic moves would render the pre-move colours.
	if on_done.is_valid():
		on_done.call()

## Brief brighten pulse on the solved faces; purely visual, cleared on the next refresh.
func flash_solved(_state: CubeState) -> void:
	_solve_flash = SOLVE_FLASH

func _process(delta: float) -> void:
	if _solve_flash < 0.0:
		return
	_solve_flash -= delta
	var t := clampf(_solve_flash / SOLVE_FLASH, 0.0, 1.0)
	var boost := 1.0 - pow(1.0 - t, 2.0)
	for mat in _materials:
		mat.emission_enabled = true
		mat.emission = mat.albedo_color * 0.6 * boost
	if _solve_flash <= 0.0:
		for mat in _materials:
			mat.emission_enabled = false
