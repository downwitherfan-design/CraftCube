extends Control

## Mobile-first HUD for the vertical slice. Built in code so the scene graph stays
## simple and the layout is deterministic. Touch-sized buttons; a large-text
## accessibility toggle; onboarding, hint, pause/restart and undo controls.
## Presentation only — it calls GameController, it does not implement game rules.

var controller: Node3D
var _title: Label
var _status: Label
var _onboard: Label
var _hint: Label
var _story: Label
var _face_buttons: Array = []
var _flip_btn: Button
var _ccw_mode := false
var _big_text := false
var _busy := false
var _root: VBoxContainer
var _undo_btn: Button
var _restart_btn: Button
var _guide: Label
var _hint_btn: Button
var _step_btn: Button
var _readiness: Label
var _resonance: Label
var _version: Label
## Audio mute toggle (drives the single AudioDirector; state read from it, never duplicated).
var _audio_btn: Button
## Non-interrupting completion panel: after the win predicate passes, the puzzle stays on
## screen and the player chooses when to move on (so the win is not yanked away instantly).
var _solved_panel: PanelContainer
var _solved_label: Label
var _continue_btn: Button

## Accessibility state: large text and reduced motion, both persisted in the settings file.
var _reduced_motion := false

## Settings file used for accessibility persistence; tests override this to isolate.
var settings_path := SaveManager.SETTINGS_PATH

const BTN_MIN := Vector2(88, 64)

## On mobile, take the full screen so the game is not letterboxed and no system
## chrome forces a smaller play area. Guarded and safe to call on desktop/headless.
func _ready() -> void:
	if OS.has_feature("mobile"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func bind(ctrl: Node3D) -> void:
	controller = ctrl
	_build()
	_apply_saved_settings()
	# Idempotent: the node can be (re)readied by the headless test harness, and a second
	# connect would make every gameplay signal fire its HUD handler twice.
	_connect_once(controller.level_loaded, _on_level_loaded)
	_connect_once(controller.world_reacted, _on_world_reacted)
	_connect_once(controller.reward_granted, _on_reward)
	_connect_once(controller.discovery_found, _on_discovery)
	_connect_once(controller.solved, _on_solved)
	_connect_once(controller.move_applied, _on_move_applied)

func _connect_once(sig: Signal, cb: Callable) -> void:
	if not sig.is_connected(cb):
		sig.connect(cb)

## Apply persisted accessibility preferences. Missing/ malformed settings fall back to the
## default (normal text); loading must never fail or crash on a bad file.
func _apply_saved_settings() -> void:
	_big_text = false
	_reduced_motion = false
	var s := SaveManager.load_settings(settings_path)
	if bool(s.get("big_text", false)):
		_apply_big_text(true)
	if bool(s.get("reduced_motion", false)):
		_apply_reduced_motion(true)

func _label(text: String, size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# Labels must not eat mouse events; empty-space drags should reach the orbit camera.
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func _button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = BTN_MIN
	b.add_theme_font_size_override("font_size", 24)
	return b

func _build() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	# The HUD container must not swallow touches aimed at the 3D cube: it ignores mouse
	# input itself while its child Buttons still consume their own taps. This is what lets
	# the InteractionRouter raycast the cube through the empty middle of the screen.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var outer := VBoxContainer.new()
	outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(outer)

	# Top banner: title + objective/moves stay pinned (never scrolled off) so the player can
	# always read the goal and move count, even on a short narrow portrait phone.
	_title = _label("", 30)
	_status = _label("", 20)
	outer.add_child(_title)
	# Single source of truth: the app version shown here comes from res://app_version.json.
	_version = _label("", 13)
	var ver := Version.display()
	_version.text = ("CraftCube " + ver) if ver != "" else ""
	outer.add_child(_version)
	outer.add_child(_status)

	# Middle: a fixed-height band reserves the vertical area the camera views, so the cube is
	# never occluded by guidance/control text (the cube is the one thing the player must read
	# clearly). Everything below scrolls, so a crowded control column on a small screen can
	# never push the essential readout off the top.
	outer.add_child(_cube_band())

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outer.add_child(scroll)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 10)
	scroll.add_child(col)

	_onboard = _label("", 20)
	_hint = _label("", 20)
	_story = _label("", 22)
	_guide = _label("", 20)
	_readiness = _label("", 18)
	_resonance = _label("", 18)
	col.add_child(_readiness)
	col.add_child(_resonance)
	col.add_child(_onboard)
	col.add_child(_hint)
	col.add_child(_guide)
	col.add_child(_story)

	_root = VBoxContainer.new()
	_root.add_theme_constant_override("separation", 10)
	col.add_child(_root)

	# Face-turn row (legal faces). Tap = recommended direction; toggle flips it.
	var face_row := GridContainer.new()
	face_row.columns = 3
	face_row.add_theme_constant_override("h_separation", 8)
	face_row.add_theme_constant_override("v_separation", 8)
	_root.add_child(face_row)
	for f in ["U", "D", "L", "R", "F", "B"]:
		var b := _button(f)
		b.custom_minimum_size = Vector2(72, 60)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(_on_face_pressed.bind(f))
		face_row.add_child(b)
		_face_buttons.append({"face": f, "button": b})

	var action_row := HBoxContainer.new()
	action_row.alignment = BoxContainer.ALIGNMENT_CENTER
	action_row.add_theme_constant_override("separation", 8)
	_root.add_child(action_row)
	var flip := _button("Direction: CW")
	flip.pressed.connect(_on_flip)
	action_row.add_child(flip)
	_flip_btn = flip
	var undo := _button("Undo")
	undo.pressed.connect(func(): if not controller.is_animating(): controller.undo(); _refresh_guide(); _refresh_status())
	action_row.add_child(undo)
	_undo_btn = undo
	var restart := _button("Restart")
	restart.pressed.connect(func(): if not controller.is_animating(): controller.restart_level(); _refresh_guide(); _refresh_status())
	action_row.add_child(restart)
	_restart_btn = restart

	# Solving: request guidance, and confirm the win. Advancing to the next level is offered
	# only on the completion panel, so progress is never skipped by accident.
	var solve_row := HBoxContainer.new()
	solve_row.alignment = BoxContainer.ALIGNMENT_CENTER
	solve_row.add_theme_constant_override("separation", 8)
	_root.add_child(solve_row)
	var hint := _button("Hint")
	hint.pressed.connect(_on_hint)
	solve_row.add_child(hint)
	_hint_btn = hint
	var step := _button("Guide: next step")
	step.pressed.connect(_on_guided_step)
	solve_row.add_child(step)
	_step_btn = step
	var solve := _button("I solved it")
	solve.pressed.connect(_on_solve)
	solve_row.add_child(solve)

	var a11y_row := HBoxContainer.new()
	a11y_row.alignment = BoxContainer.ALIGNMENT_CENTER
	a11y_row.add_theme_constant_override("separation", 8)
	_root.add_child(a11y_row)
	var big := _button("Large text")
	big.pressed.connect(_on_big_text)
	a11y_row.add_child(big)
	var rm := _button("Reduced motion")
	rm.pressed.connect(_on_reduced_motion)
	a11y_row.add_child(rm)
	# Mute the real gameplay audio (same single audio director the settings screen drives).
	var snd := _button("Audio")
	snd.pressed.connect(_on_audio_toggle)
	_audio_btn = snd
	a11y_row.add_child(snd)
	# Return to the application menu. The app shell owns navigation; this only asks for it.
	var menu := _button("Menu")
	menu.pressed.connect(func(): controller.request_menu())
	a11y_row.add_child(menu)

	_build_solved_panel()

## A fixed-height band that reserves the screen region the 3D camera frames the cube in. It has
## no mouse filter (so drags still reach the orbit camera) and no children, so nothing is ever
## drawn over the cube. Height is a fraction of the viewport so it scales with the device.
func _cube_band() -> Control:
	var s := Control.new()
	s.custom_minimum_size = Vector2(0, 300)
	s.size_flags_vertical = Control.SIZE_FILL
	s.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return s

## Completion panel: appears only when the win predicate has passed, sits above the controls,
## and never replaces the puzzle. The player presses Continue when they are ready.
func _build_solved_panel() -> void:
	# Bottom-anchored layer so the panel hugs its content instead of stretching into a large
	# empty box; it overlays the controls but never covers the cube above.
	var layer := MarginContainer.new()
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_theme_constant_override("margin_left", 24)
	layer.add_theme_constant_override("margin_right", 24)
	layer.add_theme_constant_override("margin_bottom", 32)
	add_child(layer)
	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_END
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(vbox)

	_solved_panel = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.14, 0.24, 0.2, 0.97)
	sb.corner_radius_top_left = 14
	sb.corner_radius_top_right = 14
	sb.corner_radius_bottom_left = 14
	sb.corner_radius_bottom_right = 14
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	_solved_panel.add_theme_stylebox_override("panel", sb)
	_solved_panel.visible = false
	vbox.add_child(_solved_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	_solved_panel.add_child(box)
	_solved_label = _label("", 22)
	box.add_child(_solved_label)
	_continue_btn = _button("Continue")
	_continue_btn.pressed.connect(_on_continue_pressed)
	box.add_child(_continue_btn)

func _on_level_loaded(level: Dictionary) -> void:
	_title.text = "%d. %s" % [int(level.get("ordinal", 0)), str(level.get("title", ""))]
	_hint.text = "Hint: " + str(level.get("hint", ""))
	if controller.game_state.solved_levels.has(str(level["level_id"])):
		_status.text = "Already solved — replay freely."
	else:
		_refresh_status()
	# Onboarding guidance is shown only on the first level; the story panel below is
	# cleared so completion feedback from a previous level never lingers.
	_onboard.visible = int(level.get("ordinal", 1)) == 1
	_onboard.text = "Drag across a face to twist it, or drag empty space to orbit the cube. Make every required face one colour, then press \"I solved it\"."
	_story.text = ""
	_guide.text = ""
	if _solved_panel:
		_solved_panel.visible = false
	_refresh_legal()
	_refresh_readiness()
	_refresh_resonance()
	_refresh_audio_button()

func _refresh_legal() -> void:
	var legal: Array = controller.legal_faces()
	for entry in _face_buttons:
		entry["button"].disabled = not legal.has(entry["face"])

func _refresh_status() -> void:
	var prog: Dictionary = controller.objective_progress()
	var total := int(prog.get("total", 0))
	var aligned := int(prog.get("aligned", 0))
	var par := int(controller.current_level().get("par_moves", 0))
	if total > 0:
		_status.text = "%s · %d/%d aligned · Moves: %d (par %d)" % [_objective_faces_text(), aligned, total, controller.engine.move_count(), par]
	else:
		_status.text = "Moves: %d (par %d)" % [controller.engine.move_count(), par]
	# Live cue so the player knows when the required faces are aligned; the win is still
	# confirmed by the domain predicate via "I solved it".
	if controller.engine.is_solved():
		_status.text = "All required faces aligned — press \"I solved it\"."
	_refresh_readiness()
	_refresh_resonance()

## Per-face mastery readout: for every face, say whether it is solid (a single colour) or
## still shows several shades, and mark the objective faces so the player can read progress
## on the whole cube, not just the win condition.
func _refresh_readiness() -> void:
	var names := {"U": "top", "D": "bottom", "L": "left", "R": "right", "F": "front", "B": "back"}
	var objective := {}
	for f in controller.current_level().get("objective", {}).get("params", {}).get("faces", []):
		objective[str(f)] = true
	var parts := PackedStringArray()
	for entry in controller.face_readiness():
		var face := str(entry["face"])
		var mark := "*" if objective.has(face) else ""
		var state := "solid" if bool(entry["solid"]) else "%d shades" % int(entry["distinct"])
		parts.append("%s%s %s" % [names.get(face, face), mark, state])
	_readiness.text = "Faces: " + " · ".join(parts) + "   (* = required)"

## Equipment capability readout (PD-002: equipment changes what you can perceive, never
## puzzle truth). The Rootweave Gauntlet's declared "perceive.resonance" capability surfaces
## which faces are one turn from settling — a hint about the same truth, not a shortcut past it.
func _refresh_resonance() -> void:
	if not controller.game_state.has_capability("resonance"):
		_resonance.text = ""
		return
	var names := {"U": "top", "D": "bottom", "L": "left", "R": "right", "F": "front", "B": "back"}
	var near := PackedStringArray()
	for entry in controller.face_readiness():
		if not bool(entry["solid"]) and int(entry["distinct"]) == 2:
			near.append(str(names.get(str(entry["face"]), str(entry["face"]))))
	if near.is_empty():
		_resonance.text = "Resonance: no face is one turn from settling."
	else:
		_resonance.text = "Resonance: one turn from settling — " + ", ".join(near) + "."

## Names the objective's required faces in player terms, so "Align U" reads as "top".
func _objective_faces_text() -> String:
	var names := {"U": "top", "D": "bottom", "F": "front", "B": "back", "L": "left", "R": "right"}
	var faces: Array = controller.current_level().get("objective", {}).get("params", {}).get("faces", [])
	var out := PackedStringArray()
	for f in faces:
		out.append(names.get(str(f), str(f)))
	return "Align " + ", ".join(out)

func _on_flip() -> void:
	_ccw_mode = not _ccw_mode
	if _flip_btn:
		_flip_btn.text = "Direction: CCW" if _ccw_mode else "Direction: CW"

func _on_face_pressed(face: String) -> void:
	if controller.is_animating():
		return
	var applied: bool = controller.try_move(face, not _ccw_mode)
	if applied:
		_haptic(18)
		set_busy(true)
	_refresh_guide()
	_refresh_status()

## Request/recompute a guided route and show the next actionable step. Recomputing on
## request is safe (the route is a pure function of the engine's history).
func _on_hint() -> void:
	var st: Dictionary = controller.guide_status()
	_guide.text = str(st.get("text", ""))
	_refresh_guide_buttons()

## Execute the next guided step through the real engine/animation path.
func _on_guided_step() -> void:
	if controller.is_animating():
		return
	if controller.guided_move():
		_haptic(18)
		set_busy(true)
	_refresh_guide()
	_refresh_status()

## Refresh the guide line from the controller's current route (state-derived, not cached).
func _refresh_guide() -> void:
	var st: Dictionary = controller.guide_status()
	if bool(st.get("solved", false)):
		_guide.text = ""
		_refresh_guide_buttons()
		return
	_guide.text = "Guide: turn the %s %s · %d step(s) to solved." % [
		controller._face_word(str(st.get("face", ""))),
		"clockwise" if bool(st.get("cw", true)) else "counter-clockwise",
		int(st.get("remaining", 0))]
	_refresh_guide_buttons()

func _refresh_guide_buttons() -> void:
	if _step_btn:
		_step_btn.disabled = _busy or bool(controller.guide_status().get("solved", false))

## Lock the interactive controls while a turn animation is in flight so a second input can
## never start a competing turn (which would desync the rendered layer from the truth).
func set_busy(busy: bool) -> void:
	_busy = busy
	for entry in _face_buttons:
		entry["button"].disabled = busy or not controller.legal_faces().has(entry["face"])
	if _undo_btn:
		_undo_btn.disabled = busy
	if _restart_btn:
		_restart_btn.disabled = busy
	if _hint_btn:
		_hint_btn.disabled = busy
	_refresh_guide_buttons()

func _on_move_applied() -> void:
	set_busy(false)
	_refresh_guide()
	_refresh_status()

## Re-read the live gameplay readouts from current state. The app calls this after a loadout
## change made outside gameplay (equip/unequip) so a capability's effect appears at once.
func refresh_readouts() -> void:
	_refresh_status()
	_refresh_audio_button()

func _on_solve() -> void:
	if not controller.confirm_solve():
		_status.text = "Not yet — the required faces are not aligned."
	else:
		_haptic(60)

## Short vibration on supported handhelds; a harmless no-op elsewhere.
func _haptic(ms: int) -> void:
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(ms)

## Completion feedback accumulates in `_story` so the world reaction, the reward
## narrative and the discovery are all readable together. Writing them to one shared
## label made later signals overwrite earlier ones and hid the authored narrative.
func _append_story(line: String) -> void:
	if line == "":
		return
	_story.text = line if _story.text == "" else _story.text + "\n" + line

func _on_world_reacted(_hook: String, text: String) -> void:
	_append_story(text)

func _on_reward(reward_id: String, equipment: Dictionary) -> void:
	_status.text = "Reward: " + reward_id
	var narrative := str(StoryContent.reward_for(reward_id).get("narrative", ""))
	if narrative != "":
		_append_story(narrative)
	if not equipment.is_empty():
		_hint.text = "Equipment: %s — %s" % [str(equipment.get("name", "")), str(equipment.get("purpose", ""))]
	_refresh_resonance()

func _on_discovery(discovery: Dictionary) -> void:
	_append_story("Discovery — %s: %s" % [str(discovery.get("name", "")), str(discovery.get("text", ""))])

func _on_solved(_level: Dictionary, _reward: Dictionary) -> void:
	_status.text = "Solved! The world answered. Saved."
	# Non-interrupting completion: keep the puzzle on screen and offer the next step rather
	# than yanking the player away the instant the predicate passes.
	var r: Dictionary = controller.last_result_data()
	var stars := int(r.get("stars", 0))
	var star_text := ""
	for k in range(3):
		star_text += "★" if k < stars else "☆"
	_solved_label.text = "Solved!  %s\nMoves %d · par %d" % [star_text, int(r.get("moves", 0)), int(r.get("par", 0))]
	var has_next: bool = int(r.get("next_index", -1)) >= 0
	_continue_btn.text = "Continue to next level" if has_next else "Chapter map"
	_solved_panel.visible = true

## Continue from the completion panel: enter the next level when one remains, otherwise ask
## the app to return to the chapter map. Reachable only by a deliberate press.
func _on_continue_pressed() -> void:
	_solved_panel.visible = false
	var r: Dictionary = controller.last_result_data()
	if int(r.get("next_index", -1)) >= 0 and controller.load_level(int(r["next_index"]), true):
		return
	controller.request_menu()

func _on_big_text() -> void:
	_apply_big_text(not _big_text)
	SaveManager.update_settings({"big_text": _big_text, "reduced_motion": _reduced_motion}, settings_path)

## Reduced-motion toggle: face turns settle instantly for players who prefer less movement.
## Persisted together with the other accessibility choices.
func _on_reduced_motion() -> void:
	_apply_reduced_motion(not _reduced_motion)
	SaveManager.update_settings({"big_text": _big_text, "reduced_motion": _reduced_motion}, settings_path)

## Toggle the real gameplay audio mute through the single AudioDirector and reflect the new
## state on the button. Reads the director's state (single source of truth), never a copy.
func _on_audio_toggle() -> void:
	if controller == null or controller.audio == null:
		return
	controller.audio.set_muted(not controller.audio.muted)
	_refresh_audio_button()

func _refresh_audio_button() -> void:
	if _audio_btn == null:
		return
	var muted: bool = controller != null and controller.audio != null and bool(controller.audio.muted)
	_audio_btn.text = "Audio: muted" if muted else "Audio: on"

## Apply reduced motion to the cube view. Shared by the toggle and the settings restore path.
func _apply_reduced_motion(on: bool) -> void:
	_reduced_motion = on
	if controller and controller.cube_view:
		controller.cube_view.reduced_motion = on

## Apply the accessibility text scale. Shared by the toggle and by settings restore, so the
## restore path and the interactive path can never diverge.
func _apply_big_text(on: bool) -> void:
	_big_text = on
	var mult := 1.5 if _big_text else 1.0
	for l in [_title, _status, _onboard, _hint, _story, _guide, _readiness, _resonance, _version, _solved_label]:
		var base := 34 if l == _title else (22 if (l == _status or l == _story) else (18 if (l == _readiness or l == _resonance) else (14 if l == _version else 20)))
		l.add_theme_font_size_override("font_size", int(base * mult))
	for entry in _face_buttons:
		entry["button"].add_theme_font_size_override("font_size", int(24 * mult))

## App-facing setter: apply a large-text preference pushed down from the application shell
## (settings screen), without re-persisting. Keeps the app and the in-game HUD in agreement.
func set_big_text(on: bool) -> void:
	_apply_big_text(on)

## App-facing setter: apply a reduced-motion preference pushed down from the application
## shell, reaching the cube view through the same shared path the in-game toggle uses.
func set_reduced_motion(on: bool) -> void:
	_apply_reduced_motion(on)
