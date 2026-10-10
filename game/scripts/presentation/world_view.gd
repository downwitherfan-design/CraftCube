class_name WorldView
extends Node3D

## Minimal original world-reaction presentation. Built procedurally (primitives only)
## so it needs no external assets and stays IP-safe. The world reacts to puzzle
## mastery: a ground plane and a growing ring of "growth" markers that light up when
## a world hook fires. This is presentation only — the trigger is domain content.

var _ground: MeshInstance3D
var _growth: Array = []
var _lit := 0

func build() -> void:
	for c in get_children():
		c.queue_free()
	_growth.clear()
	_lit = 0

	var ground_mesh := CylinderMesh.new()
	ground_mesh.top_radius = 3.2
	ground_mesh.bottom_radius = 3.2
	ground_mesh.height = 0.2
	ground_mesh.radial_segments = 48
	_ground = MeshInstance3D.new()
	_ground.mesh = ground_mesh
	var gm := StandardMaterial3D.new()
	gm.albedo_color = Color(0.12, 0.14, 0.12)
	_ground.material_override = gm
	_ground.position = Vector3(0, -1.55, 0)
	add_child(_ground)

	var ring_mesh := SphereMesh.new()
	ring_mesh.radius = 0.09
	ring_mesh.height = 0.18
	for i in range(12):
		var a := TAU * float(i) / 12.0
		var m := MeshInstance3D.new()
		m.mesh = ring_mesh
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.18, 0.2, 0.18)
		m.material_override = mat
		m.position = Vector3(cos(a) * 2.4, -1.4, sin(a) * 2.4)
		add_child(m)
		_growth.append({"node": m, "material": mat})

## Light up the next growth marker; represents a world hook firing. Idempotent in effect:
## lighting is capped at the marker count so a repeated/extra call cannot exceed the ring.
func react() -> bool:
	if _growth.is_empty() or _lit >= _growth.size():
		return false
	sync_lit(_lit + 1)
	return true

## Set the number of lit markers from authoritative progression (e.g. on resume from a
## save). The world must never show fewer reactions than the levels already completed.
func sync_lit(count: int) -> void:
	var target := clampi(count, 0, _growth.size())
	for i in range(_growth.size()):
		var lit := i < target
		var mat: StandardMaterial3D = _growth[i]["material"]
		if lit:
			mat.albedo_color = Color(0.45, 0.9, 0.5)
			mat.emission_enabled = true
			mat.emission = Color(0.3, 0.7, 0.35)
		else:
			mat.albedo_color = Color(0.18, 0.2, 0.18)
			mat.emission_enabled = false
	_lit = target

func lit_count() -> int:
	return _lit
