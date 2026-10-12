class_name InteractionRouter
extends Node3D

## Single owner of raw touch/mouse input for gameplay (AI-04 Gesture Arbitration Model).
## Every other system receives typed commands emitted from here — no second consumer of raw
## touches exists (anti-duplication rule). This class does NOT implement puzzle rules; it
## classifies an intent once per touch sequence and emits exactly one command.
##
## Hit identification is analytic ray/geometry (camera ray vs. the cube's face planes and
## world-target spheres), never screen quadrants. Thresholds are centralised consts; their
## values are AI-04 Phase-00 hypotheses, not measured device facts (see
## 04_AI_ACCOUNTS/AI-04/phase_00/04_GESTURE_ARBITRATION_MODEL.md §5).
##
## Determinism: given the same ordered (event, pos, t) tuples and tunables, the same ordered
## commands are produced. No frame-time dependency, so tests can replay sequences headless.

signal twist_requested(face: String, cw: bool)
signal orbit_requested(delta_yaw: float, delta_pitch: float)
signal zoom_requested(delta: float)
signal world_tapped(target_id: String)
signal intent_changed(intent: String)

# --- tunables (AI-04 hypotheses; single source, never duplicated) -----------------------
const TAP_MS := 180
const TAP_MOVE_PX := 8.0
const HOLD_MS := 350
const TWIST_START_PX := 12.0
const TWIST_COMMIT_PX := 26.0
const FLICK_PX_PER_S := 900.0
const ORBIT_START_PX := 10.0
const ORBIT_SENSITIVITY := 0.006
const ZOOM_PER_PX := 0.01
const WHEEL_ZOOM_STEP := 0.6
const EDGE_INSET_PX := 24.0

const FACE_LETTERS := ["U", "D", "L", "R", "F", "B"]
## Outward normal per face index (matches CubeState.Face ordering).
const FACE_NORMALS := [
        Vector3(0, 1, 0), Vector3(0, -1, 0),
        Vector3(-1, 0, 0), Vector3(1, 0, 0),
        Vector3(0, 0, 1), Vector3(0, 0, -1),
]

var camera: Camera3D
var cube_half := 1.0
## Recognised interactive world targets: [{id:String, position:Vector3, radius:float}].
var world_targets: Array = []
## Injectable UI hit-test: (Vector2) -> bool. Defaults to the viewport's hovered Control.
var ui_hit_test: Callable = Callable()
var enabled := true
## When true, puzzle intents are accepted (a level is playable). World intents are always
## recognised so a target tap never turns into an orbit.
var puzzle_enabled := true

var _intent := "none"
var _touch := -1
var _start_pos := Vector2.ZERO
var _start_t := 0
var _start_hit: Dictionary = {}
var _last_pos := Vector2.ZERO
var _last_t := 0
var _touches: Dictionary = {}      # touch index -> last position
var _pinch_prev := -1.0
var _second_finger := false

# --- synthetic-friendly API (used by _unhandled_input and by tests) ---------------------

## Begin a touch sequence. Returns the classified intent so far ("undecided" normally).
func begin(pos: Vector2, t: int, index: int = 0) -> String:
        if not enabled:
                return "none"
        if _touches.size() == 0:
                _start_sequence(pos, t, index)
        else:
                _on_second_touch(pos, index)
        _touches[index] = pos
        return _intent

func _start_sequence(pos: Vector2, t: int, index: int) -> void:
        _touch = index
        _start_pos = pos
        _start_t = t
        _last_pos = pos
        _last_t = t
        _second_finger = false
        if _ui_consumed(pos):
                _start_hit = {}
                _set_intent("ui_passthrough")
                return
        _start_hit = _hit_at(pos)
        _set_intent("undecided")

## A second finger arriving while a twist is in progress cancels the twist (never converts a
## partial twist into a zoom). During a camera orbit it promotes to pinch-zoom.
func _on_second_touch(pos: Vector2, index: int) -> void:
        _second_finger = true
        if _intent == "puzzle":
                _set_intent("cancelled")
        elif _intent == "camera":
                _pinch_prev = -1.0
                _set_intent("camera_zoom")
        elif _intent == "undecided":
                # Two fingers at once: treat as pinch-zoom (camera), never a cube twist.
                _set_intent("camera_zoom")
        _touches[index] = pos

func move(pos: Vector2, t: int, index: int = 0) -> String:
        if not enabled:
                return "none"
        if index != _touch:
                _touches[index] = pos
                if _touches.size() >= 2:
                        _pinch()
                return _intent
        var d := pos.distance_to(_start_pos)
        _last_pos = pos
        _last_t = t
        match _intent:
                "undecided":
                        if _start_hit.get("kind", "none") == "cube" and puzzle_enabled and d >= TWIST_START_PX:
                                _set_intent("puzzle")
                        elif _start_hit.get("kind", "none") == "world" and d >= ORBIT_START_PX:
                                # Dragging off an anchor orbits; tapping it interacts.
                                _set_intent("camera")
                        elif _start_hit.get("kind", "none") == "none" and d >= ORBIT_START_PX:
                                _set_intent("camera")
                        elif (t - _start_t) >= HOLD_MS and d < TAP_MOVE_PX:
                                _set_intent("hold")
                "camera":
                        var rel := pos - _prev_of(index, pos)
                        orbit_requested.emit(-rel.x * ORBIT_SENSITIVITY, -rel.y * ORBIT_SENSITIVITY)
                _:
                        pass
        _touches[index] = pos
        return _intent

func end(pos: Vector2, t: int, index: int = 0) -> String:
        if not enabled:
                return "none"
        if _touches.has(index):
                _touches.erase(index)
        var out := _intent
        match _intent:
                "undecided":
                        var d := pos.distance_to(_start_pos)
                        if (t - _start_t) <= TAP_MS and d < TAP_MOVE_PX:
                                _on_tap(pos)
                        # else: ambiguous movement cancels safely (no command).
                "puzzle":
                        _commit_twist(pos, t)
                _:
                        pass
        _reset()
        return out

## OS touch-cancel / interrupted touch: cancel without emitting any command.
func cancel() -> void:
        _reset()

func _reset() -> void:
        _intent = "none"
        _touch = -1
        _start_hit = {}
        _touches.clear()
        _pinch_prev = -1.0
        _second_finger = false

func _set_intent(v: String) -> void:
        if _intent != v:
                _intent = v
                intent_changed.emit(v)

func current_intent() -> String:
        return _intent

func _prev_of(index: int, fallback: Vector2) -> Vector2:
        return _touches.get(index, fallback)

# --- classification --------------------------------------------------------------------

## Tap on a recognised world target emits a world command; a tap on the cube is a
## presentation-only tile tap (no-op here); empty space is a no-op.
func _on_tap(pos: Vector2) -> void:
        var hit := _hit_at(pos)
        if hit.get("kind", "none") == "world":
                world_tapped.emit(str(hit.get("id", "")))

## Classify the twist from the face's outward normal and the world-space drag direction.
## Velocity of a point p under a +rotation about unit axis n is (n x p); a point on the face
## has p = n*half + r, so velocity = n x r. The drag sign relative to (n x r) selects the
## rotation sign; the engine's `cw` is a +quarter turn about the *positive* axis.
static func classify_twist(face_index: int, hit_point: Vector3, drag_world: Vector3) -> Dictionary:
        if face_index < 0 or face_index >= FACE_NORMALS.size():
                return {}
        var n: Vector3 = FACE_NORMALS[face_index]
        var r := hit_point - n * hit_point.dot(n)
        var tangent := n.cross(r)
        var s := drag_world.dot(tangent)
        if absf(s) < 0.000001:
                # Degenerate (drag exactly radial): fall back to the dominant tangent axis.
                s = drag_world.x if absf(tangent.x) >= absf(tangent.z) else drag_world.z
        var n_pos_axis := n.x + n.y + n.z > 0.0
        var cw := (s > 0.0) == n_pos_axis
        return {"face": FACE_LETTERS[face_index], "cw": cw}

func _commit_twist(pos: Vector2, t: int) -> void:
        if _start_hit.get("kind", "none") != "cube":
                return
        var total := pos.distance_to(_start_pos)
        var dt := maxi(1, t - _start_t)
        var speed := total / (float(dt) / 1000.0)
        if total < TWIST_COMMIT_PX and speed < FLICK_PX_PER_S:
                return  # dead band / hesitant drag: cancel, never guess
        var world_drag := _screen_to_world_dir(pos - _start_pos)
        var move := classify_twist(int(_start_hit.get("face", -1)), _start_hit.get("point", Vector3.ZERO), world_drag)
        if move.is_empty():
                return
        twist_requested.emit(str(move["face"]), bool(move["cw"]))

## Map a screen delta to a world direction using the camera basis (screen y is down).
func _screen_to_world_dir(screen_delta: Vector2) -> Vector3:
        var b := _cam_basis()
        var d := b.x * screen_delta.x + b.y * (-screen_delta.y)
        return d.normalized() if d.length() > 0.000001 else Vector3.ZERO

# --- screen <-> world (deterministic, no in-tree requirement) ---------------------------
# The router owns its own pinhole unprojection/projection so the exact same math runs in the
# headless test harness and at runtime, and so classification never depends on whether the
# camera has been rendered yet. The camera's parent (the gameplay root) sits at the origin,
# so the local transform is the world transform.

var viewport_size := Vector2(720, 1280)

func _cam_basis() -> Basis:
        return camera.transform.basis if camera else Basis()

func _cam_origin() -> Vector3:
        return camera.transform.origin if camera else Vector3.ZERO

func _fov_radians() -> float:
        return deg_to_rad(camera.fov) if camera else deg_to_rad(70.0)

## Screen position -> world ray (origin, unit direction). Matches Camera3D.project_ray_*.
func screen_ray(pos: Vector2) -> Array:
        var size := _effective_viewport_size()
        var half_h := tan(_fov_radians() * 0.5)
        var half_w := half_h * (size.x / maxf(1.0, size.y))
        var b := _cam_basis()
        var ndc := Vector2((2.0 * pos.x / maxf(1.0, size.x)) - 1.0, 1.0 - (2.0 * pos.y / maxf(1.0, size.y)))
        var dir := -b.z + b.x * (ndc.x * half_w) + b.y * (ndc.y * half_h)
        return [_cam_origin(), dir.normalized()]

## World point -> screen position (inverse of screen_ray). Used to aim tests at targets.
func project_to_screen(point: Vector3) -> Vector2:
        var size := _effective_viewport_size()
        var half_h := tan(_fov_radians() * 0.5)
        var half_w := half_h * (size.x / maxf(1.0, size.y))
        var b := _cam_basis()
        var rel := point - _cam_origin()
        var depth := rel.dot(-b.z)
        if absf(depth) < 0.000001:
                return Vector2(-1, -1)
        var ndc := Vector2(rel.dot(b.x) / depth / half_w, rel.dot(b.y) / depth / half_h)
        return Vector2((ndc.x + 1.0) * 0.5 * size.x, (1.0 - ndc.y) * 0.5 * size.y)

func _effective_viewport_size() -> Vector2:
        if viewport_size.x > 1.0:
                return viewport_size
        if is_inside_tree():
                var vp := get_viewport()
                if vp != null:
                        var s := vp.get_visible_rect().size
                        if s.x > 1.0:
                                return s
        return Vector2(720, 1280)

# --- hit testing (analytic, deterministic) ----------------------------------------------

## Classify a screen position: a world target, the cube, or nothing (UI handled upstream).
func _hit_at(pos: Vector2) -> Dictionary:
        if camera == null:
                return {"kind": "none"}
        var ray := screen_ray(pos)
        var origin: Vector3 = ray[0]
        var dir: Vector3 = ray[1]
        var world := _raycast_world(origin, dir)
        var cube := raycast_cube(origin, dir)
        if not world.is_empty() and (cube.is_empty() or float(world["t"]) <= float(cube["t"])):
                return world
        if not cube.is_empty():
                return cube
        return {"kind": "none"}

func _raycast_world(origin: Vector3, dir: Vector3) -> Dictionary:
        var best: Dictionary = {}
        for tgt in world_targets:
                var c: Vector3 = tgt.get("position", Vector3.ZERO)
                var rad: float = float(tgt.get("radius", 0.3))
                var t := _ray_sphere(origin, dir, c, rad)
                if t > 0.0 and (best.is_empty() or t < float(best["t"])):
                        best = {"kind": "world", "id": str(tgt.get("id", "")), "t": t}
        return best

static func _ray_sphere(o: Vector3, d: Vector3, c: Vector3, rad: float) -> float:
        var oc := o - c
        var b := oc.dot(d)
        var cc := oc.dot(oc) - rad * rad
        var disc := b * b - cc
        if disc < 0.0:
                return -1.0
        var sq := sqrt(disc)
        var t0 := -b - sq
        if t0 > 0.0:
                return t0
        var t1 := -b + sq
        return t1 if t1 > 0.0 else -1.0

## Ray vs. the cube's six face planes at +/-cube_half. Returns the nearest hit with its face
## index and world hit point, or {} when the ray misses.
func raycast_cube(origin: Vector3, dir: Vector3) -> Dictionary:
        var best: Dictionary = {}
        for face in range(6):
                var n: Vector3 = FACE_NORMALS[face]
                var denom := n.dot(dir)
                if absf(denom) < 0.000001:
                        continue
                var t := (cube_half - n.dot(origin)) / denom
                if t <= 0.0:
                        continue
                var p := origin + dir * t
                if not _inside_face(n, p):
                        continue
                if best.is_empty() or t < float(best["t"]):
                        best = {"kind": "cube", "face": face, "point": p, "t": t}
        return best

func _inside_face(n: Vector3, p: Vector3) -> bool:
        var lim := cube_half + 0.0001
        for axis in range(3):
                var nv := n.x if axis == 0 else (n.y if axis == 1 else n.z)
                if absf(nv) > 0.5:
                        continue  # this is the normal axis; not constrained
                var c := p.x if axis == 0 else (p.y if axis == 1 else p.z)
                if absf(c) > lim:
                        return false
        return true

func _ui_consumed(pos: Vector2) -> bool:
        if ui_hit_test.is_valid():
                return bool(ui_hit_test.call(pos))
        if not is_inside_tree():
                return false
        var vp := get_viewport()
        if vp == null:
                return false
        var hovered := vp.gui_get_hovered_control()
        return hovered != null and hovered.is_visible_in_tree()

# --- raw input -------------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
        if not enabled:
                return
        if event is InputEventScreenTouch:
                if event.pressed:
                        begin(event.position, Time.get_ticks_msec(), event.index)
                else:
                        end(event.position, Time.get_ticks_msec(), event.index)
        elif event is InputEventScreenDrag:
                move(event.position, Time.get_ticks_msec(), event.index)
        elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
                if event.pressed:
                        begin(event.position, Time.get_ticks_msec(), 0)
                else:
                        end(event.position, Time.get_ticks_msec(), 0)
        elif event is InputEventMouseMotion and _touches.size() == 1:
                move(event.position, Time.get_ticks_msec(), 0)
        elif event is InputEventMouseButton and event.pressed:
                if event.button_index == MOUSE_BUTTON_WHEEL_UP:
                        zoom_requested.emit(-WHEEL_ZOOM_STEP)
                elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
                        zoom_requested.emit(WHEEL_ZOOM_STEP)

func _pinch() -> void:
        var pts := _touches.values()
        if pts.size() < 2:
                return
        var d: float = pts[0].distance_to(pts[1])
        if _pinch_prev > 0.0:
                zoom_requested.emit((_pinch_prev - d) * ZOOM_PER_PX)
        _pinch_prev = d
