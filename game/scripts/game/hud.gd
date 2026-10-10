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
var _root: VBoxContainer

const BTN_MIN := Vector2(88, 64)

## On mobile, take the full screen so the game is not letterboxed and no system
## chrome forces a smaller play area. Guarded and safe to call on desktop/headless.
func _ready() -> void:
	if OS.has_feature("mobile"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func bind(ctrl: Node3D) -> void:
	controller = ctrl
	_build()
	controller.level_loaded.connect(_on_level_loaded)
	controller.world_reacted.connect(_on_world_reacted)
	controller.reward_granted.connect(_on_reward)
	controller.discovery_found.connect(_on_discovery)
	controller.solved.connect(_on_solved)

func _label(text: String, size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func _button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = BTN_MIN
	b.add_theme_font_size_override("font_size", 24)
	return b

func _build() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)

	var outer := VBoxContainer.new()
	outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(outer)

	_title = _label("", 34)
	_status = _label("", 22)
	_onboard = _label("", 20)
	_hint = _label("", 20)
	_story = _label("", 22)
	outer.add_child(_title)
	outer.add_child(_status)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.add_child(spacer)
	outer.add_child(_onboard)
	outer.add_child(_hint)
	outer.add_child(_story)

	_root = VBoxContainer.new()
	_root.add_theme_constant_override("separation", 10)
	outer.add_child(_root)

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
	undo.pressed.connect(func(): controller.undo(); _refresh_status())
	action_row.add_child(undo)
	var restart := _button("Restart")
	restart.pressed.connect(func(): controller.restart_level(); _refresh_status())
	action_row.add_child(restart)

	var solve_row := HBoxContainer.new()
	solve_row.alignment = BoxContainer.ALIGNMENT_CENTER
	solve_row.add_theme_constant_override("separation", 8)
	_root.add_child(solve_row)
	var solve := _button("I solved it")
	solve.pressed.connect(_on_solve)
	solve_row.add_child(solve)
	var nxt := _button("Next level")
	nxt.pressed.connect(func(): if not controller.next_level(): _status.text = "Chapter 01 slice complete.")
	solve_row.add_child(nxt)

	var a11y_row := HBoxContainer.new()
	a11y_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_root.add_child(a11y_row)
	var big := _button("Large text")
	big.pressed.connect(_on_big_text)
	a11y_row.add_child(big)

func _on_level_loaded(level: Dictionary) -> void:
	_title.text = "%d. %s" % [int(level.get("ordinal", 0)), str(level.get("title", ""))]
	_hint.text = "Hint: " + str(level.get("hint", ""))
	if controller.game_state.solved_levels.has(str(level["level_id"])):
		_status.text = "Already solved — replay freely."
	else:
		_status.text = ""
	# Onboarding guidance is shown only on the first level; the story panel below is
	# cleared so completion feedback from a previous level never lingers.
	_onboard.visible = int(level.get("ordinal", 1)) == 1
	_onboard.text = "Tap a face to twist the cube. Make every required face one colour, then press \"I solved it\"."
	_story.text = ""
	_refresh_legal()

func _refresh_legal() -> void:
	var legal: Array = controller.legal_faces()
	for entry in _face_buttons:
		entry["button"].disabled = not legal.has(entry["face"])

func _refresh_status() -> void:
	_status.text = "Moves: %d" % controller.engine.move_count()
	# Live cue so the player knows when the required faces are aligned; the win is still
	# confirmed by the domain predicate via "I solved it".
	if controller.engine.is_solved():
		_status.text = "All required faces aligned — press \"I solved it\"."

func _on_flip() -> void:
	_ccw_mode = not _ccw_mode
	if _flip_btn:
		_flip_btn.text = "Direction: CCW" if _ccw_mode else "Direction: CW"

func _on_face_pressed(face: String) -> void:
	var applied: bool = controller.try_move(face, not _ccw_mode)
	if applied:
		_haptic(18)
	_refresh_status()

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

func _on_discovery(discovery: Dictionary) -> void:
	_append_story("Discovery — %s: %s" % [str(discovery.get("name", "")), str(discovery.get("text", ""))])

func _on_solved(_level: Dictionary, _reward: Dictionary) -> void:
	_status.text = "Solved! The world answered. Saved."

func _on_big_text() -> void:
	_big_text = not _big_text
	var mult := 1.5 if _big_text else 1.0
	for l in [_title, _status, _onboard, _hint, _story]:
		var base := 34 if l == _title else (22 if (l == _status or l == _story) else 20)
		l.add_theme_font_size_override("font_size", int(base * mult))
	for entry in _face_buttons:
		entry["button"].add_theme_font_size_override("font_size", int(24 * mult))
