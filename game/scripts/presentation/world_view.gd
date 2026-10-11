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
## Interactive world-target ids the arbiter can route. Consts so the router, the app
## and the tests agree on the identifier without duplicating a magic string.
const TARGET_SIGIL := "world.three_notch_sigil"
const TARGET_NOX := "world.nox"
## The two Beat 5 path nodes are tappable once the choice is available, so the decision is made
## by touching the world rather than only through a menu.
const TARGET_NODE_NEAR := "world.path_node.near"
const TARGET_NODE_FAR := "world.path_node.far"
## The world cache (Milestone F): a small container that appears in the restored area once the
## seed bed (level 2) is solved. Tapping it is the genuine in-world item discovery.
const TARGET_CACHE := "world.cache"
## The veiled mark: a stone slab whose hidden glyph is invisible until the Stone Lens is
## equipped, at which point it becomes a tappable world target. Using the lens on it reveals
## the mark — a real world change, not a HUD line.
const TARGET_VEILED_MARK := "world.veiled_mark"
## Nox awakens at the chapter's third level (the authored `reward.01.nox_meets` beat).
const NOX_AWAKEN_LEVELS := 3
## The cache appears once the restored area exists (levels 1 and 2 solved).
const CACHE_UNLOCK_LEVELS := 2

var _ground: MeshInstance3D
var _growth: Array = []
var _wards: Array = []
var _nox: Node3D
var _nox_parts: Array = []
## Interactive three-notch sigil near the cube: a tap reveals the Architect clue
## (FIRST_TEN_MINUTES Beat 2). Built as a small distinct figure, hidden until the
## world has begun to answer, so a fresh world has nothing to tap.
var _sigil: Node3D
var _sigil_read := false
## Two dormant nodes flanking the broken path (FIRST_TEN_MINUTES Beat 5). One is woken first;
## the world remembers which, without gating progression either way.
var _choice_nodes: Array = []
## Milestone F world props: the cache (item discovery) and the veiled mark (item use).
var _cache: Node3D
var _cache_taken := false
var _veiled_mark: Node3D
var _veiled_glyph: MeshInstance3D
var _veiled_revealed := false
var _veiled_revealed_lit := false
## True when the player currently owns the Stone Lens (drives whether the mark is tappable).
var _lens_owned := false
## True once the Beat 5 first-node choice is offered (level 2 solved). Gates whether the path
## nodes are tappable; the nodes are always visible so the path reads even before the choice.
var _choice_available := false
var _lit := 0
var _lit_ground := Color(0.12, 0.14, 0.12)
var _warm_ground := Color(0.2, 0.21, 0.16)

func build() -> void:
	for c in get_children():
		c.queue_free()
	_growth.clear()
	_wards.clear()
	_nox = null
	_sigil = null
	_sigil_read = false
	_choice_nodes.clear()
	_choice_available = false
	_cache = null
	_cache_taken = false
	_veiled_mark = null
	_veiled_glyph = null
	_veiled_revealed = false
	_veiled_revealed_lit = false
	_lens_owned = false
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
	_build_sigil()
	_build_choice_nodes()
	_build_cache()
	_build_veiled_mark()

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

## The two path nodes of the Beat 5 choice. Built as short pillars with a glowing cap, placed
## inside the tally ring so they read as "the path", not as more ward stones. Both start dormant;
## whichever the player wakes first is lit brightly and the other wakes in reply (dim but present),
## so the world shows the decision the player made rather than only that a decision happened.
func _build_choice_nodes() -> void:
	var placements := [
		{"option": "near", "pos": Vector3(-1.0, -1.15, 1.9), "colour": Color(0.7, 0.85, 0.98)},
		{"option": "far", "pos": Vector3(1.0, -1.15, -1.9), "colour": Color(0.85, 0.75, 0.62)},
	]
	for p in placements:
		var node := Node3D.new()
		node.position = p["pos"]
		var pillar := CylinderMesh.new()
		pillar.top_radius = 0.12
		pillar.bottom_radius = 0.16
		pillar.height = 0.7
		pillar.radial_segments = 8
		var mi := MeshInstance3D.new()
		mi.mesh = pillar
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.17, 0.18, 0.17)
		mi.material_override = mat
		node.add_child(mi)
		var cap := MeshInstance3D.new()
		var cap_mesh := SphereMesh.new()
		cap_mesh.radius = 0.13
		cap_mesh.height = 0.26
		cap.mesh = cap_mesh
		var cap_mat := StandardMaterial3D.new()
		cap_mat.albedo_color = Color(0.15, 0.16, 0.15)
		cap.material_override = cap_mat
		cap.position = Vector3(0, 0.42, 0)
		node.add_child(cap)
		add_child(node)
		_choice_nodes.append({"node": node, "material": mat, "cap": cap_mat, "colour": p["colour"], "option": p["option"]})

## The world cache (Milestone F): a small lidded container that appears in the restored area
## once the seed bed is solved. Built from a base cylinder, a body box and a small lid — a
## distinct silhouette from the ward pillars and the sigil so the player reads it as "a thing
## to open", not scenery. Hidden until its prerequisite is met; the router only registers it
## as a target while it is visible.
func _build_cache() -> void:
	_cache = Node3D.new()
	_cache.position = Vector3(2.5, -1.4, 0.0)
	_cache.visible = false
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.34, 0.28, 0.22)
	body_mat.emission_enabled = true
	body_mat.emission = Color(0.28, 0.2, 0.1)
	var lid_mat := StandardMaterial3D.new()
	lid_mat.albedo_color = Color(0.52, 0.42, 0.3)
	var base := CylinderMesh.new()
	base.top_radius = 0.28
	base.bottom_radius = 0.3
	base.height = 0.1
	base.radial_segments = 12
	var base_mi := MeshInstance3D.new()
	base_mi.mesh = base
	base_mi.material_override = body_mat
	_cache.add_child(base_mi)
	var body := BoxMesh.new()
	body.size = Vector3(0.42, 0.3, 0.34)
	var body_mi := MeshInstance3D.new()
	body_mi.mesh = body
	body_mi.material_override = body_mat
	body_mi.position = Vector3(0, 0.2, 0)
	_cache.add_child(body_mi)
	var lid := BoxMesh.new()
	lid.size = Vector3(0.46, 0.07, 0.38)
	var lid_mi := MeshInstance3D.new()
	lid_mi.mesh = lid
	lid_mi.material_override = lid_mat
	lid_mi.position = Vector3(0, 0.38, 0)
	_cache.add_child(lid_mi)
	add_child(_cache)

## The veiled mark (Milestone F): a stone slab whose hidden glyph is invisible to the naked
## eye. The slab is always present as scenery; the glyph mesh only becomes visible once the
## Stone Lens reveals it. It is registered as a router target only while the player owns the
## lens and the glyph is still veiled, so the "use the item" step is a genuine world tap.
func _build_veiled_mark() -> void:
	_veiled_mark = Node3D.new()
	_veiled_mark.position = Vector3(-2.1, -1.35, -0.7)
	var slab_mat := StandardMaterial3D.new()
	slab_mat.albedo_color = Color(0.19, 0.2, 0.2)
	var slab := BoxMesh.new()
	slab.size = Vector3(0.7, 0.9, 0.12)
	var slab_mi := MeshInstance3D.new()
	slab_mi.mesh = slab
	slab_mi.material_override = slab_mat
	_veiled_mark.add_child(slab_mi)
	# The hidden glyph: a bright inset cross of thin slabs, hidden until revealed.
	var glyph_mat := StandardMaterial3D.new()
	glyph_mat.albedo_color = Color(0.75, 0.9, 1.0)
	glyph_mat.emission_enabled = true
	glyph_mat.emission = Color(0.35, 0.6, 0.75)
	_veiled_glyph = MeshInstance3D.new()
	var glyph := BoxMesh.new()
	glyph.size = Vector3(0.42, 0.07, 0.04)
	_veiled_glyph.mesh = glyph
	_veiled_glyph.material_override = glyph_mat
	_veiled_glyph.position = Vector3(0, 0.06, 0.075)
	_veiled_glyph.visible = false
	_veiled_mark.add_child(_veiled_glyph)
	var glyph2 := MeshInstance3D.new()
	var glyph_b := BoxMesh.new()
	glyph_b.size = Vector3(0.07, 0.42, 0.04)
	glyph2.mesh = glyph_b
	glyph2.material_override = glyph_mat
	glyph2.position = Vector3(0, 0.06, 0.075)
	glyph2.visible = false
	_veiled_mark.add_child(glyph2)
	_veiled_glyph.set_meta("cross", glyph2)
	add_child(_veiled_mark)


## The three-notch sigil: a small distinct figure (three upright notches on a base) placed
## beside the cube. Hidden until the world has answered (>= 1 solved level), then tappable to
## reveal the Architect clue. Distinct from the ward stones (which are pillars) so the player
## reads it as a *mark*, not another progress bar.
func _build_sigil() -> void:
	_sigil = Node3D.new()
	_sigil.position = Vector3(-1.8, -1.05, 1.5)
	_sigil.visible = false
	var base_mat := StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.2, 0.21, 0.2)
	var notch_mat := StandardMaterial3D.new()
	notch_mat.albedo_color = Color(0.55, 0.6, 0.62)
	notch_mat.emission_enabled = true
	notch_mat.emission = Color(0.1, 0.13, 0.15)
	var base := CylinderMesh.new()
	base.top_radius = 0.26
	base.bottom_radius = 0.3
	base.height = 0.16
	base.radial_segments = 12
	var base_mi := MeshInstance3D.new()
	base_mi.mesh = base
	base_mi.material_override = base_mat
	_sigil.add_child(base_mi)
	# Three notches: each a thin upright slab, evenly spaced and leaning slightly outward.
	for k in range(3):
		var notch := BoxMesh.new()
		notch.size = Vector3(0.05, 0.3 + float(k) * 0.04, 0.05)
		var mi := MeshInstance3D.new()
		mi.mesh = notch
		mi.material_override = notch_mat
		mi.position = Vector3((float(k) - 1.0) * 0.13, 0.23, 0.0)
		mi.rotation = Vector3(0, 0, (float(k) - 1.0) * 0.16)
		_sigil.add_child(mi)
	add_child(_sigil)

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
	# The sigil becomes tappable as soon as the world has begun to answer (>= 1 level),
	# so a fresh world exposes no interactive target and cannot be read out of order.
	if _sigil != null:
		_sigil.visible = target >= 1
	# The cache appears once the restored area exists (the seed bed solved), but stays visible
	# after it is opened only if it has NOT yet been taken — once taken it is gone for good.
	if _cache != null:
		_cache.visible = target >= CACHE_UNLOCK_LEVELS and not _cache_taken
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
## a tap can never interact with a veiled target (the sigil before the world answers, or Nox
## before it awakens).
func interactive_targets() -> Array:
	var out: Array = []
	if _sigil != null and _sigil.visible:
		out.append({"id": TARGET_SIGIL, "position": _sigil.position, "radius": 0.45})
	if _nox != null and _nox.visible:
		out.append({"id": TARGET_NOX, "position": _nox.position, "radius": 0.5})
	# The cache is tappable only while it exists and has not been taken.
	if _cache != null and _cache.visible and not _cache_taken:
		out.append({"id": TARGET_CACHE, "position": _cache.position, "radius": 0.5})
	# The veiled mark is tappable only once the player owns the Stone Lens and has not yet
	# revealed it — so the "use the item" step is a genuine world interaction, not a menu press.
	if _veiled_mark != null and _lens_owned and not _veiled_revealed:
		out.append({"id": TARGET_VEILED_MARK, "position": _veiled_mark.position, "radius": 0.55})
	# Path nodes are tappable only once the choice beat is offered; before that they are visible
	# scenery, so a tap cannot record a decision the story has not reached.
	if _choice_available:
		for c in _choice_nodes:
			var target := TARGET_NODE_NEAR if str(c["option"]) == "near" else TARGET_NODE_FAR
			out.append({"id": target, "position": (c["node"] as Node3D).position, "radius": 0.45})
	return out

## Number of path-choice nodes built (0 before the world is built).
func choice_node_count() -> int:
	return _choice_nodes.size()

## True when the given option's node is currently the woken (bright) one.
func choice_node_lit(option: String) -> bool:
	for c in _choice_nodes:
		if str(c["option"]) == option:
			return bool(c.get("lit", false))
	return false

## Light the chosen path node brightly and let the other wake in reply (dim, but present).
## Rebuilt from the recorded choice, so a loaded save shows the same world without replaying
## the decision.
func apply_world_choices(choices: Dictionary) -> void:
	var chosen := str(choices.get("nar.flag.ch01_first_node_choice", ""))
	for c in _choice_nodes:
		var opt := str(c["option"])
		var mat: StandardMaterial3D = c["material"]
		var cap: StandardMaterial3D = c["cap"]
		var colour: Color = c["colour"]
		if chosen == "":
			c["lit"] = false
			mat.albedo_color = Color(0.17, 0.18, 0.17)
			mat.emission_enabled = false
			cap.albedo_color = Color(0.15, 0.16, 0.15)
			cap.emission_enabled = false
		elif opt == chosen:
			c["lit"] = true
			mat.albedo_color = colour
			mat.emission_enabled = true
			mat.emission = colour * 0.4
			cap.albedo_color = colour
			cap.emission_enabled = true
			cap.emission = colour * 0.6
		else:
			c["lit"] = false
			mat.albedo_color = colour * 0.35
			mat.emission_enabled = true
			mat.emission = colour * 0.12
			cap.albedo_color = colour * 0.4
			cap.emission_enabled = true
			cap.emission = colour * 0.15

## True once the three-notch clue has been read (persisted as a world flag).
func sigil_read() -> bool:
	return _sigil_read

## True when the sigil is currently tappable.
func sigil_available() -> bool:
	return _sigil != null and _sigil.visible

## Reveal the sigil's clue. Returns true the first time only, so the app can grant the
## discovery exactly once; a repeat tap re-opens the text without re-granting anything.
func read_sigil() -> bool:
	if not sigil_available():
		return false
	var first := not _sigil_read
	_sigil_read = true
	return first

## Apply persisted world flags onto the presentation. `sigil_read` is a flag, not a
## progression count, so it is restored explicitly (the tally ring is rebuilt from the
## solved-level count by sync_lit).
func apply_world_flags(flags: Dictionary) -> void:
	if bool(flags.get("sigil_read", false)):
		_sigil_read = true
	if bool(flags.get("cache_taken", false)):
		_cache_taken = true
	if bool(flags.get("veiled_mark_revealed", false)):
		_veiled_revealed = true
		_veiled_revealed_lit = true

# --- Milestone F: world cache (item discovery) -----------------------------------------

## True when the cache exists in the world and has not yet been taken.
func cache_available() -> bool:
	return _cache != null and _cache.visible and not _cache_taken

## True once the cache has been opened (persisted as a world flag).
func cache_taken() -> bool:
	return _cache_taken

## Take the cache. Returns true only on the first take, so the app can grant the item exactly
## once; a repeat call changes nothing. Hides the cache for good.
func take_cache() -> bool:
	if not cache_available():
		return false
	_cache_taken = true
	if _cache != null:
		_cache.visible = false
	return true

# --- Milestone F: veiled mark (item use) -----------------------------------------------

## Tell the world whether the player currently owns the Stone Lens. Owned => the mark becomes
## a tappable target (the player can try to use it).
func set_lens_owned(owned: bool) -> void:
	_lens_owned = owned

## True when the veiled mark is currently tappable (lens owned, not yet revealed).
func veiled_mark_available() -> bool:
	return _veiled_mark != null and _lens_owned and not _veiled_revealed

## True once the hidden mark has been revealed.
func veiled_revealed() -> bool:
	return _veiled_revealed

## Reveal the hidden mark with the Stone Lens. Returns true only the first time, so the app
## grants the reveal consequence exactly once. Makes the glyph meshes visible — a real world
## change, not a HUD line.
func reveal_veiled_mark() -> bool:
	if not veiled_mark_available():
		return false
	_veiled_revealed = true
	_veiled_revealed_lit = true
	if _veiled_glyph != null:
		_veiled_glyph.visible = true
		var cross = _veiled_glyph.get_meta("cross", null)
		if cross is MeshInstance3D:
			(cross as MeshInstance3D).visible = true
	return true

## True when the revealed glyph mesh is actually rendered (proves the world changed).
func veiled_glyph_visible() -> bool:
	if _veiled_glyph == null:
		return false
	var cross = _veiled_glyph.get_meta("cross", null)
	return _veiled_glyph.visible and cross is MeshInstance3D and (cross as MeshInstance3D).visible

## Reconstruct the whole world appearance from authoritative progression: the solved
## count drives the ring, wards, Nox and cache (via sync_lit), and the saved world flags drive
## the sigil, cache-taken and veiled-mark states. `lens_owned` gates whether the veiled mark is
## currently tappable. One call restores a loaded save without replaying any event.
func sync_from_state(solved_count: int, flags: Dictionary, choices: Dictionary = {}, choice_available: bool = false, lens_owned: bool = false) -> void:
	# Flags first: `_cache_taken` / `_veiled_revealed` must be known before sync_lit decides the
	# cache's visibility, so a loaded save never re-shows a cache that was already opened.
	apply_world_flags(flags)
	_lens_owned = lens_owned
	sync_lit(solved_count)
	apply_world_choices(choices)
	_choice_available = choice_available
	# Restore the revealed glyph's meshes to match the saved reveal state.
	if _veiled_revealed and _veiled_glyph != null:
		_veiled_glyph.visible = true
		var cross = _veiled_glyph.get_meta("cross", null)
		if cross is MeshInstance3D:
			(cross as MeshInstance3D).visible = true
