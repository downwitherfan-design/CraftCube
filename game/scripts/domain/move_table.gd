class_name MoveTable
extends RefCounted

## Named face/slice turns mapped to a (axis, layer, cw) primitive over the CubeState
## geometry. Face turns are the legal-move vocabulary of the vertical slice.

const U := "U"
const D := "D"
const L := "L"
const R := "R"
const F := "F"
const B := "B"

const ALL_FACES := [U, D, L, R, F, B]

## face -> axis. U/D spin about Y; L/R about X; F/B about Z.
const AXIS_OF := {U: 1, D: 1, L: 0, R: 0, F: 2, B: 2}

## A clockwise quarter turn of the named face. `cw` follows a consistent right-hand
## convention so that each face and its inverse commute back to solved.
static func face_move(face: String, cw: bool = true, layer: int = -1) -> Dictionary:
	# layer == -1 => the outer layer of that face.
	return {"face": face, "axis": AXIS_OF[face], "layer": layer, "cw": cw}

static func inverse(move: Dictionary) -> Dictionary:
	return {"face": move["face"], "axis": move["axis"], "layer": move["layer"], "cw": not bool(move["cw"])}

## Resolve a face move's outer layer index (0..n-1) from that face's orientation.
static func resolve_layer(size: int, face: String, layer: int) -> int:
	if layer >= 0:
		return layer
	match face:
		U: return 0
		D: return size - 1
		L: return 0
		R: return size - 1
		F: return size - 1
		B: return 0
	return 0

static func all_face_moves() -> Array:
	var moves := []
	for f in ALL_FACES:
		moves.append(face_move(f, true))
		moves.append(face_move(f, false))
	return moves
