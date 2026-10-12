class_name CubeState
extends RefCounted

## Deterministic NxN twisting-puzzle domain model ("truth layer"). Pure GDScript,
## no engine/scene dependency. Same seed + ruleset + moves => same configuration.
##
## Representation: a facelet colour vector of 6*n*n ints (colour in 0..5). Each
## facelet has a 3D position + outward normal on an integer grid; a turn is a 90-degree
## rotation of every facelet in one layer. Permutations are derived from geometry at
## construction time, so the model scales to any N without hand-written index tables.

enum Face { U = 0, D = 1, L = 2, R = 3, F = 4, B = 5 }
const FACE_COUNT := 6
const FACE_LETTERS := ["U", "D", "L", "R", "F", "B"]

var n: int
var colours: PackedInt32Array  # size 6*n*n; solved => colours[i] == i / (n*n)

var _positions: Array = []      # facelet index -> Vector3i
var _normals: Array = []        # facelet index -> Vector3i
var _lookup: Dictionary = {}    # packed(pos, normal) -> facelet index

func _init(size: int = 3) -> void:
	assert(size >= 2)
	n = size
	_build_geometry()
	reset()

func _pack(pos: Vector3i, nrm: Vector3i) -> int:
	return (((pos.x * 8 + pos.y) * 8 + pos.z) * 3 + (nrm.x + 1)) * 9 \
		+ (nrm.y + 1) * 3 + (nrm.z + 1)

func _build_geometry() -> void:
	_positions.resize(FACE_COUNT * n * n)
	_normals.resize(FACE_COUNT * n * n)
	_lookup.clear()
	var faces := [
		{"f": Face.U, "fn": func(r, c): return Vector3i(c, n - 1, n - 1 - r), "n": Vector3i(0, 1, 0)},
		{"f": Face.D, "fn": func(r, c): return Vector3i(c, 0, r), "n": Vector3i(0, -1, 0)},
		{"f": Face.F, "fn": func(r, c): return Vector3i(c, r, n - 1), "n": Vector3i(0, 0, 1)},
		{"f": Face.B, "fn": func(r, c): return Vector3i(n - 1 - c, r, 0), "n": Vector3i(0, 0, -1)},
		{"f": Face.L, "fn": func(r, c): return Vector3i(0, r, c), "n": Vector3i(-1, 0, 0)},
		{"f": Face.R, "fn": func(r, c): return Vector3i(n - 1, r, n - 1 - c), "n": Vector3i(1, 0, 0)},
	]
	for entry in faces:
		for r in range(n):
			for c in range(n):
				var idx: int = int(entry["f"]) * n * n + r * n + c
				var p: Vector3i = entry["fn"].call(r, c)
				var nv: Vector3i = entry["n"]
				_positions[idx] = p
				_normals[idx] = nv
				_lookup[_pack(p, nv)] = idx

func reset() -> void:
	colours = PackedInt32Array()
	colours.resize(FACE_COUNT * n * n)
	for i in range(colours.size()):
		colours[i] = i / (n * n)

## Rotate a 3D integer vector 90 degrees about an axis THROUGH THE CUBE CENTER.
## Uses doubled coordinates (2*coord - (n-1)) so the center shift stays integral.
func _rotate_about_center(p: Vector3i, ax: int, cw: bool) -> Vector3i:
	var c2 := n - 1
	var q := Vector3i(2 * p.x - c2, 2 * p.y - c2, 2 * p.z - c2)
	var qr := _rotate_vec(q, ax, cw)
	return Vector3i((qr.x + c2) / 2, (qr.y + c2) / 2, (qr.z + c2) / 2)

## Rotate a 3D grid vector 90 degrees about an axis. ax: 0=X, 1=Y, 2=Z; cw: sign.
func _rotate_vec(v: Vector3i, ax: int, cw: bool) -> Vector3i:
	var s := 1 if cw else -1
	match ax:
		0:  # X axis: (x, y, z) -> (x, -s*z, s*y)
			return Vector3i(v.x, -s * v.z, s * v.y)
		1:  # Y axis: (x, y, z) -> (s*z, y, -s*x)
			return Vector3i(s * v.z, v.y, -s * v.x)
		_:  # Z axis: (x, y, z) -> (-s*y, s*x, z)
			return Vector3i(-s * v.y, s * v.x, v.z)

## Facelet indices occupying `layer_value` along `axis` (0=X,1=Y,2=Z). Shared by the
## permutation builder, the presentation (layer selection), and tests, so a layer is
## defined in exactly one place.
func layer_indices(axis: int, layer_value: int) -> Array:
	var out := []
	for i in range(_positions.size()):
		var p: Vector3i = _positions[i]
		var coord := p.x if axis == 0 else (p.y if axis == 1 else p.z)
		if coord == layer_value:
			out.append(i)
	return out

## Build the permutation (new_index[old_index]) for one layer turn.
## axis: 0=X,1=Y,2=Z. layer_value: coordinate along that axis in 0..n-1. cw: direction.
func turn_permutation(axis: int, layer_value: int, cw: bool) -> PackedInt32Array:
	var perm := PackedInt32Array()
	perm.resize(colours.size())
	for i in range(colours.size()):
		perm[i] = i
	for i in range(colours.size()):
		var p: Vector3i = _positions[i]
		var coord := p.x if axis == 0 else (p.y if axis == 1 else p.z)
		if coord != layer_value:
			continue
		var np := _rotate_about_center(p, axis, cw)
		var nn := _rotate_vec(_normals[i], axis, cw)
		var dst = _lookup.get(_pack(np, nn), -1)
		assert(dst != -1, "geometry permutation generated an invalid facelet")
		perm[dst] = i  # facelet moving from i now occupies dst
	return perm

func apply_permutation(perm: PackedInt32Array) -> void:
	var out := PackedInt32Array()
	out.resize(colours.size())
	for dst in range(perm.size()):
		out[dst] = colours[perm[dst]]
	colours = out

## Apply a move. move = {axis:int, layer:int, cw:bool, face:String}. A layer of -1 means
## "that face's outer layer" and is resolved here against the cube size.
func apply_move(move: Dictionary) -> void:
	var layer := int(move["layer"])
	if layer < 0:
		var face := str(move.get("face", ""))
		layer = MoveTable.resolve_layer(n, face, layer) if face != "" else 0
	apply_permutation(turn_permutation(int(move["axis"]), layer, bool(move["cw"])))

func clone() -> CubeState:
	var c := CubeState.new(n)
	c.colours = colours.duplicate()
	return c

func fingerprint() -> String:
	var parts := PackedStringArray()
	for v in colours:
		parts.append(str(v))
	return ",".join(parts)

func distinct_colours_on_face(face: int) -> int:
	var seen := {}
	for r in range(n):
		for c in range(n):
			seen[colours[face * n * n + r * n + c]] = true
	return seen.size()

func is_face_solid(face: int) -> bool:
	return distinct_colours_on_face(face) == 1

func is_aligned(faces: Array) -> bool:
	if faces.is_empty():
		return false
	for f in faces:
		if not is_face_solid(int(f)):
			return false
	return true
