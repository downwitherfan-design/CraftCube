class_name OrbitCamera
extends Camera3D

## Interactive inspection camera (Milestone B). Orbits a stable target (the cube centre),
## zooms within bounds, and resets to a readable default framing. Works with desktop mouse
## and mobile touch; smoothing keeps motion usable without feeling laggy.
##
## Input routing: this camera reads only *unhandled* input, so a tap that lands on a HUD
## Button (which consumes the event) never rotates the camera underneath it. HUD containers
## are set to ignore mouse input so empty-space drags reach the camera.

const DEFAULT_YAW := 0.62
const DEFAULT_PITCH := 0.72
const DEFAULT_DISTANCE := 7.3

const MIN_DISTANCE := 4.2
const MAX_DISTANCE := 12.0
const MIN_PITCH := 0.12          # never look from directly above/below the cube
const MAX_PITCH := 1.35
const SMOOTH_SPEED := 12.0
const ORBIT_SENSITIVITY := 0.006
const WHEEL_ZOOM_STEP := 0.6

var target := Vector3.ZERO
var default_target := Vector3.ZERO

var _yaw := DEFAULT_YAW
var _pitch := DEFAULT_PITCH
var _distance := DEFAULT_DISTANCE

var _want_yaw := DEFAULT_YAW
var _want_pitch := DEFAULT_PITCH
var _want_distance := DEFAULT_DISTANCE

var _dragging := false
var _touches := {}                # touch index -> Vector2 position
var _pinch_prev := -1.0

func _ready() -> void:
        _apply(_want_yaw, _want_pitch, _want_distance, target)

## Orbit by a yaw/pitch delta (radians); pitch is clamped so the view never flips.
func orbit(delta_yaw: float, delta_pitch: float) -> void:
        _want_yaw += delta_yaw
        _want_pitch = clampf(_want_pitch + delta_pitch, MIN_PITCH, MAX_PITCH)

## Zoom by a signed distance delta; clamped to [MIN_DISTANCE, MAX_DISTANCE].
func zoom(delta: float) -> void:
        _want_distance = clampf(_want_distance + delta, MIN_DISTANCE, MAX_DISTANCE)

## Restore the default readable framing (optionally snap immediately).
func reset_view(snap: bool = true) -> void:
        _want_yaw = DEFAULT_YAW
        _want_pitch = DEFAULT_PITCH
        _want_distance = DEFAULT_DISTANCE
        target = default_target
        if snap:
                _yaw = _want_yaw
                _pitch = _want_pitch
                _distance = _want_distance
                _apply(_yaw, _pitch, _distance, target)

func get_distance() -> float:
        return _distance

func get_yaw() -> float:
        return _yaw

func get_pitch() -> float:
        return _pitch

func _process(delta: float) -> void:
        var t := 1.0 - exp(-SMOOTH_SPEED * delta)
        _yaw = lerpf(_yaw, _want_yaw, t)
        _pitch = lerpf(_pitch, _want_pitch, t)
        _distance = lerpf(_distance, _want_distance, t)
        _apply(_yaw, _pitch, _distance, target)
        # Snap tiny residuals so repeated gestures cannot leave an unbounded small error.
        if absf(_yaw - _want_yaw) < 0.0005:
                _yaw = _want_yaw
        if absf(_pitch - _want_pitch) < 0.0005:
                _pitch = _want_pitch
        if absf(_distance - _want_distance) < 0.001:
                _distance = _want_distance

func _apply(yaw: float, pitch: float, distance: float, look_target: Vector3) -> void:
        var dir := Vector3(cos(pitch) * sin(yaw), sin(pitch), cos(pitch) * cos(yaw))
        var pos := look_target + dir * distance
        # Set the LOCAL transform (the parent node is at the origin), which is valid even
        # before the node is inside the tree; global_transform would error there.
        transform = Transform3D(Basis(), pos).looking_at(look_target, Vector3.UP)

func _unhandled_input(event: InputEvent) -> void:
        if event is InputEventMouseButton:
                if event.button_index == MOUSE_BUTTON_LEFT:
                        _dragging = event.pressed
                elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
                        zoom(-WHEEL_ZOOM_STEP)
                elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
                        zoom(WHEEL_ZOOM_STEP)
        elif event is InputEventMouseMotion and _dragging:
                orbit(-event.relative.x * ORBIT_SENSITIVITY, -event.relative.y * ORBIT_SENSITIVITY)
        elif event is InputEventScreenTouch:
                if event.pressed:
                        _touches[event.index] = event.position
                else:
                        _touches.erase(event.index)
                        if _touches.size() < 2:
                                _pinch_prev = -1.0
        elif event is InputEventScreenDrag:
                _touches[event.index] = event.position
                if _touches.size() >= 2:
                        _pinch()
                else:
                        orbit(-event.relative.x * ORBIT_SENSITIVITY, -event.relative.y * ORBIT_SENSITIVITY)

## Two-finger pinch: distance between the first two touches drives the zoom.
func _pinch() -> void:
        var pts := _touches.values()
        var d: float = pts[0].distance_to(pts[1])
        if _pinch_prev > 0.0:
                zoom((_pinch_prev - d) * 0.01)
        _pinch_prev = d
