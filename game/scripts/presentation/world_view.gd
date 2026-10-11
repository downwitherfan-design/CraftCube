class_name WorldView
extends Node3D

## Original world-reaction presentation, built procedurally (primitives only) so it needs
## no external assets and stays IP-safe. The world reacts to puzzle mastery and remembers
## progress:
##   * a ground plane that warms as the chapter advances,
##   * a tally ring of 12 markers (one per solved level, capped) — this is `lit_count()`,
##   * six larger "ward" stones, one per Chapter 01 level, each awakening as its level is
##     solved, so every level's completion leaves a distinct, spatially separate landmark,
##   * Nox, the stone companion from `reward.01.nox_meets`, who awakens once the chapter's
##     third level is solved and is presented as a small recognisable figure.
## This is presentation only — the trigger is domain content (world hooks / solved count).

const RING_MARKERS := 12
const WARD_COUNT := 6
## Nox awakens at the chapter's third level (the authored `reward.01.nox_meets` beat).
const NOX_AWAKEN_LEVELS := 3

var _ground: MeshInstance3D
var _growth: Array = []
var _wards: Array = []
var _nox: Node3D
var _nox_parts: Array = []
var _lit := 0
var _lit_ground := Color(0.12, 0.14, 0.12)
var _warm_ground := Color(0.2, 0.21, 0.16)

func build() -> void:
	for c in get_children():
		c.queue_free()
	_growth.clear()
	_wards.clear()
	_nox = null
	_lit = 0

	var ground_mesh := CylinderMesh.new()
	ground_mesh.top_radius = 3.2
	ground_mesh.bottom_radius = 3.2
	ground_mesh.height = 0.2
	ground_mesh.radial_segments = 48
	_ground = MeshInstance3D.new()
	_ground.mesh = ground_mesh
	var gm := StandardMaterial3D.new()
	gm.albedo_color = _lit_ground
	_ground.material_override = gm
	_ground.position = Vector3(0, -1.55, 0)
	add_child(_ground)

	var ring_mesh := SphereMesh.new()
	ring_mesh.radius = 0.09
	ring_mesh.height = 0.18
	for i in range(RING_MARKERS):
		var a := TAU * float(i) / float(RING_MARKERS)
		var m := MeshInstance3D.new()
		m.mesh = ring_mesh
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.18, 0.2, 0.18)
		m.material_override = mat
		m.position = Vector3(cos(a) * 2.4, -1.4, sin(a) * 2.4)
		add_child(m)
		_growth.append({"node": m, "material": mat})

	_build_wards()
	_build_nox()

## One ward stone per Chapter 01 level, placed at increasing radius and turn so each level's
## completion leaves a distinct, spatially separate landmark.
func _build_wards() -> void:
	var palette := [
		Color(0.55, 0.85, 0.95),  # level 1 — cool "mechanism awakens" light
		Color(0.6, 0.95, 0.55),   # level 2 — green "seed grows"
		Color(0.98, 0.82, 0.45),  # level 3 — amber "stone marks awaken"
		Color(0.62, 0.78, 0.98),  # level 4 — "resonance deepens"
		Color(0.78, 0.62, 0.95),  # level 5 — "paths converge"
		Color(0.98, 0.9, 0.62),   # level 6 — "chapter sealed"
	]
	for i in range(WARD_COUNT):
		var a := -0.7 + float(i) * 0.62
		var radius := 2.9 + float(i) * 0.16
		var pillar := CylinderMesh.new()
		pillar.top_radius = 0.16
		pillar.bottom_radius = 0.22
		pillar.height = 0.9 + float(i) * 0.25
		pillar.radial_segments = 8
		var node := MeshInstance3D.new()
		node.mesh = pillar
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.16, 0.17, 0.16)
		node.material_override = mat
		node.position = Vector3(cos(a) * radius, -1.15, sin(a) * radius)
		add_child(node)
		var cap := MeshInstance3D.new()
		var cap_mesh := SphereMesh.new()
		cap_mesh.radius = 0.12
		cap_mesh.height = 0.24
		cap.mesh = cap_mesh
		var cap_mat := StandardMaterial3D.new()
		cap_mat.albedo_color = Color(0.14, 0.15, 0.14)
		cap.material_override = cap_mat
		cap.position = Vector3(0, 0.6 + float(i) * 0.12, 0)
		node.add_child(cap)
		_wards.append({"node": node, "material": mat, "cap": cap_mat, "colour": palette[i]})

## Nox: a small stone companion near the cube, hidden until it awakens (chapter's third
## level). Assembled from a few primitives into a recognisable figure — a body, a head with
## two eyes, two arm nubs and a crest — rather than a single decorative sphere. Still
## lightweight (six primitive meshes) and entirely procedural.
func _build_nox() -> void:
	_nox = Node3D.new()
	_nox.position = Vector3(1.7, -1.05, 1.4)
	_nox.visible = false
	_nox_parts.clear()

	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.6, 0.58, 0.66)
	body_mat.emission_enabled = true
	body_mat.emission = Color(0.2, 0.27, 0.38)

	var eye_mat := StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.85, 0.95, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.5, 0.8, 1.0)

	var crest_mat := StandardMaterial3D.new()
	crest_mat.albedo_color = Color(0.72, 0.9, 0.95)
	crest_mat.emission_enabled = true
	crest_mat.emission = Color(0.3, 0.6, 0.7)

	var body := SphereMesh.new()
	body.radius = 0.2
	body.height = 0.34
	_add_nox_part(body, body_mat, Vector3(0, 0, 0))
	var head := SphereMesh.new()
	head.radius = 0.14
	head.height = 0.26
	_add_nox_part(head, body_mat, Vector3(0, 0.3, 0))
	var eye := SphereMesh.new()
	eye.radius = 0.035
	eye.height = 0.07
	_add_nox_part(eye, eye_mat, Vector3(-0.05, 0.32, 0.11))
	_add_nox_part(eye, eye_mat, Vector3(0.05, 0.32, 0.11))
	var arm := CylinderMesh.new()
	arm.top_radius = 0.03
	arm.bottom_radius = 0.03
	arm.height = 0.18
	_add_nox_part(arm, body_mat, Vector3(-0.19, 0.02, 0), Vector3(0, 0, deg_to_rad(28)))
	_add_nox_part(arm, body_mat, Vector3(0.19, 0.02, 0), Vector3(0, 0, deg_to_rad(-28)))
	var crest := CylinderMesh.new()
	crest.top_radius = 0.0
	crest.bottom_radius = 0.06
	crest.height = 0.12
	_add_nox_part(crest, crest_mat, Vector3(0, 0.46, 0))
	add_child(_nox)

func _add_nox_part(mesh: Mesh, mat: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation = rot
	_nox.add_child(mi)
	_nox_parts.append(mi)

## Light up the next growth marker; represents a world hook firing. Idempotent in effect:
## lighting is capped at the marker count so a repeated/extra call cannot exceed the ring.
func react() -> bool:
	if _lit >= RING_MARKERS:
		return false
	sync_lit(_lit + 1)
	return true

## Set the world's revealed state from authoritative progression (e.g. on resume from a
## save), so the world never shows fewer reactions than the levels already completed. The
## count drives the tally ring, the ward stones and Nox together (one source of truth).
func sync_lit(count: int) -> void:
	var target := clampi(count, 0, RING_MARKERS)
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
	for i in range(_wards.size()):
		var revealed := i < target
		var w: Dictionary = _wards[i]
		var wmat: StandardMaterial3D = w["material"]
		var cap: StandardMaterial3D = w["cap"]
		var colour: Color = w["colour"]
		if revealed:
			wmat.albedo_color = colour
			wmat.emission_enabled = true
			wmat.emission = colour * 0.35
			cap.albedo_color = colour
			cap.emission_enabled = true
			cap.emission = colour * 0.5
		else:
			wmat.albedo_color = Color(0.16, 0.17, 0.16)
			wmat.emission_enabled = false
			cap.albedo_color = Color(0.14, 0.15, 0.14)
			cap.emission_enabled = false
	if _ground != null:
		var t := clampf(float(target) / float(WARD_COUNT), 0.0, 1.0)
		(_ground.material_override as StandardMaterial3D).albedo_color = _lit_ground.lerp(_warm_ground, t)
	# Nox awakens at the chapter's third level, not at full completion — the companion joins
	# the player for the last three levels (matches the `reward.01.nox_meets` beat).
	if _nox != null:
		_nox.visible = target >= NOX_AWAKEN_LEVELS
	_lit = target

func lit_count() -> int:
	return _lit

## Number of ward stones awakened (0..WARD_COUNT); distinct from the tally-ring count.
func wards_lit() -> int:
	return clampi(_lit, 0, _wards.size())

func nox_visible() -> bool:
	return _nox != null and _nox.visible

## Number of primitive meshes composing the companion (0 before it is built). Lets a test
## prove Nox is a recognisable multi-part figure rather than a single decorative sphere.
func nox_part_count() -> int:
	return _nox_parts.size()

## Interactive world targets currently registered with the input arbiter. Each entry is
## {id, position, radius}; only targets that are actually visible/available are returned, so
## a tap can never interact with a veiled target. Base implementation: none yet.
func interactive_targets() -> Array:
	return []
