class_name CubeView
extends Node3D

## 3D presentation of a CubeState: builds one MeshInstance3D per facelet from
## primitive BoxMeshes with unshaded per-colour materials (no external assets).
## Grid geometry is defined so the cube axis ranges [-1, 1] regardless of N.

const FACE_COLOURS := [
	Color(0.95, 0.95, 0.95),  # U white
	Color(0.98, 0.82, 0.20),  # D amber
	Color(0.24, 0.62, 0.95),  # L blue
	Color(0.35, 0.85, 0.45),  # R green
	Color(0.93, 0.34, 0.32),  # F red
	Color(0.99, 0.58, 0.24),  # B orange
]

var _facelets: Array = []
var _materials: Array = []
var _n: int = 3
var _tile := 0.98

func build(state: CubeState) -> void:
	for c in get_children():
		c.queue_free()
	_facelets.clear()
	_n = state.n
	_tile = 2.0 / float(_n) * 0.94
	_materials.clear()
	for i in range(6):
		var m := StandardMaterial3D.new()
		m.albedo_color = FACE_COLOURS[i]
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.roughness = 0.85
		_materials.append(m)
	var box := BoxMesh.new()
	box.size = Vector3(_tile, _tile, _tile)
	for face in range(6):
		for r in range(_n):
			for c in range(_n):
				var idx := face * _n * _n + r * _n + c
				var mi := MeshInstance3D.new()
				mi.mesh = box
				mi.material_override = _materials[_colour_of(state, face, r, c)]
				var p := _facelet_local_pos(face, r, c)
				mi.position = p
				add_child(mi)
				_facelets.append(mi)

func _colour_of(state: CubeState, face: int, r: int, c: int) -> int:
	var v := state.colours[face * _n * _n + r * _n + c]
	return (v / (_n * _n)) % 6

## Local position (cube spans [-1,1]) for facelet (face, row, col), matching the
## domain geometry convention (U down-normal, D up-normal, F +Z, B -Z, L -X, R +X).
func _facelet_local_pos(face: int, r: int, c: int) -> Vector3:
	var half := 1.0
	var step := 2.0 / float(_n)
	var off := -half + step * (float(r) + 0.5)
	var u := -half + step * (float(c) + 0.5)
	var s := half + 0.006  # slight outward offset so facelets sit on the surface
	match face:
		0: return Vector3(u, -s, off)        # U
		1: return Vector3(u, s, -off)        # D
		2: return Vector3(-s, off, u)        # L
		3: return Vector3(s, off, -u)        # R
		4: return Vector3(u, off, s)         # F
		5: return Vector3(-u, off, -s)       # B
	return Vector3.ZERO

func refresh(state: CubeState) -> void:
	var i := 0
	for face in range(6):
		for r in range(_n):
			for c in range(_n):
				_facelets[i].material_override = _materials[_colour_of(state, face, r, c)]
				i += 1
