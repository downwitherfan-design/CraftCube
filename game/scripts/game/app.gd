extends Control

## CraftCube application shell (EPIC 0.3). Boots into a title/menu flow and routes into the
## real gameplay scene. This node owns exactly ONE gameplay instance (`Main.tscn`), so the
## controller, puzzle engine, camera and save system are never duplicated across competing
## scenes. All screens are built procedurally (no external assets) and are driven by the real
## game state: the campaign map reads GameState, the results panel reads the controller's
## derived result, and the journal reads StoryContent + GameState discoveries.
##
## Navigation: title -> {new game, continue, chapter map, journal, settings} -> gameplay ->
## results -> {continue, replay, chapter map}. Android back / desktop close persists progress
## and moves back one screen (or quits from the title).

const GAME_SCENE := "res://scenes/Main.tscn"

const BG := Color(0.07, 0.08, 0.1)
const CARD := Color(0.13, 0.15, 0.18)
const CARD_DONE := Color(0.16, 0.22, 0.18)
const CARD_LOCKED := Color(0.11, 0.12, 0.13)
const ACCENT := Color(0.55, 0.85, 0.95)
const MUTED := Color(0.62, 0.66, 0.7)
const STAR_ON := Color(0.98, 0.82, 0.35)

## The single mounted gameplay instance (created once; reused for every level).
var game: GameController
## Cached preferences (single source: the settings file).
var settings: Dictionary = {}
var settings_path := SaveManager.SETTINGS_PATH

var _game_layer: Node3D
var _screen_layer: Control
## The five screen roots (added to _screen_layer, toggled for visibility).
var _screen_roots: Dictionary = {}
## Named references to every control the app needs later (roots + sub-nodes).
var _screens: Dictionary = {}
var _active := ""
var _confirm: ConfirmationDialog
var _nox_dialog: AcceptDialog
## The Beat 5 first-node choice dialog + its two option buttons (custom actions "near"/"far").
var _choice_dialog: AcceptDialog
var _choice_near_btn: Button
var _choice_far_btn: Button
var _big_text := false
var _reduced_motion := false
var _initialized := false

func _ready() -> void:
	if _initialized:
		return
	_initialized = true
	set_anchors_preset(Control.PRESET_FULL_RECT)
	# The app root must not consume input destined for the 3D cube; menu screens toggle their
	# own visibility and their buttons still consume their own taps.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if OS.has_feature("mobile"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	settings = SaveManager.load_settings(settings_path)
	_big_text = bool(settings.get("big_text", false))
	_reduced_motion = bool(settings.get("reduced_motion", false))

	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	_game_layer = Node3D.new()
	_game_layer.name = "GameLayer"
	add_child(_game_layer)
	_screen_layer = Control.new()
	_screen_layer.name = "ScreenLayer"
	_screen_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	# Menu screens sit above the 3D view but must not block cube/world input while hidden.
	_screen_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_screen_layer)

	_build_screens()
	_mount_game()
	_open_title()

# --- gameplay mounting -----------------------------------------------------------------

## Instantiate the gameplay scene once and keep it. It is created hidden; entering the game
## just reveals it, so no second controller/engine/camera/save instance ever competes.
func _mount_game() -> void:
	var packed: PackedScene = load(GAME_SCENE)
	if packed == null:
		push_error("App: cannot load gameplay scene %s" % GAME_SCENE)
		return
	game = packed.instantiate()
	game.visible = false
	# The app owns navigation/back handling, so the gameplay node must not quit the tree on a
	# back request (it still saves progress; the app decides where to go).
	game.exit_quits = false
	_game_layer.add_child(game)
	game.menu_requested.connect(_on_menu_requested)
	game.result_ready.connect(_on_result_ready)
	game.level_loaded.connect(_on_game_level_loaded)
	game.world_tapped.connect(_on_world_tapped)

func _on_menu_requested() -> void:
	game.save_progress()
	_open_map()

func _on_game_level_loaded(_lvl: Dictionary) -> void:
	# Keep the gameplay HUD's accessibility state in sync with the app's cached preferences.
	_sync_game_accessibility()
	if _active == "game":
		_refresh_world_targets()

# --- screens ---------------------------------------------------------------------------

func _build_screens() -> void:
	_screen_roots["title"] = _build_title()
	_screen_roots["map"] = _build_map()
	_screen_roots["journal"] = _build_journal()
	_screen_roots["settings"] = _build_settings()
	_screen_roots["results"] = _build_results()
	for name in _screen_roots.keys():
		var s: Control = _screen_roots[name]
		s.visible = false
		_screen_layer.add_child(s)

	_confirm = ConfirmationDialog.new()
	_confirm.title = "Start a new game?"
	_confirm.dialog_text = "Starting a new game will erase your current Chapter One progress. Continue?"
	_confirm.ok_button_text = "Erase and start"
	_confirm.cancel_button_text = "Keep progress"
	_confirm.confirmed.connect(_begin_new_game)
	add_child(_confirm)

	_nox_dialog = AcceptDialog.new()
	_nox_dialog.title = "Nox"
	_nox_dialog.ok_button_text = "Close"
	add_child(_nox_dialog)

	# The Beat 5 first-node choice. One dialog with both options so the player can decide from
	# the map, plus tapping a path node in the world routes through the same record path.
	_choice_dialog = AcceptDialog.new()
	_choice_dialog.title = "The Broken Path"
	_choice_dialog.ok_button_text = "Decide later"
	add_child(_choice_dialog)
	_choice_near_btn = _choice_dialog.add_button("Wake the near node", true, "near")
	_choice_far_btn = _choice_dialog.add_button("Wake the far node", true, "far")
	_choice_dialog.custom_action.connect(_on_choice_dialog_action)

	_apply_big_text(_big_text)

## A full-screen panel with a scrollable vertical column (mobile-first: nothing clips on a
## narrow portrait screen because the whole column scrolls).
func _panel(name: String) -> Dictionary:
	var root := Control.new()
	root.name = name
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 28)
	root.add_child(margin)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 14)
	scroll.add_child(col)
	return {"root": root, "col": col}

func _label(text: String, base: int, colour: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", base)
	l.add_theme_color_override("font_color", colour)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.set_meta("base_font", base)
	return l

func _button(text: String, base: int = 24) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(240, 66)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size", base)
	b.set_meta("base_font", base)
	return b

func _card(title: String, subtitle: String, colour: Color) -> Dictionary:
	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = colour
	sb.corner_radius_top_left = 12
	sb.corner_radius_top_right = 12
	sb.corner_radius_bottom_left = 12
	sb.corner_radius_bottom_right = 12
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", sb)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	var t := _label(title, 24)
	box.add_child(t)
	var s := _label(subtitle, 18, MUTED)
	box.add_child(s)
	return {"panel": panel, "box": box, "title": t, "subtitle": s}

# --- title -----------------------------------------------------------------------------

func _build_title() -> Control:
	var p := _panel("Title")
	var col: VBoxContainer = p["col"]
	var title := _label("CraftCube", 56, ACCENT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var sub := _label("Chapter One — First Light", 22, MUTED)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(sub)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	col.add_child(spacer)

	var new_game := _button("New Game")
	new_game.pressed.connect(_on_new_game_pressed)
	col.add_child(new_game)
	var cont := _button("Continue")
	cont.pressed.connect(_on_continue_pressed)
	col.add_child(cont)
	_screens.set("title_continue", cont)
	var map := _button("Chapter Map")
	map.pressed.connect(_open_map)
	col.add_child(map)
	var journal := _button("Discoveries")
	journal.pressed.connect(_open_journal)
	col.add_child(journal)
	var settings_btn := _button("Settings")
	settings_btn.pressed.connect(_open_settings)
	col.add_child(settings_btn)
	var exit_btn := _button("Exit")
	exit_btn.pressed.connect(_on_exit)
	col.add_child(exit_btn)

	var spacer2 := Control.new()
	spacer2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(spacer2)
	var ver := Version.display()
	var ver_label := _label("CraftCube " + ver if ver != "" else "", 14, MUTED)
	ver_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(ver_label)
	return p["root"]

# --- chapter map -----------------------------------------------------------------------

func _build_map() -> Control:
	var p := _panel("Map")
	var col: VBoxContainer = p["col"]
	var title := _label("Chapter One", 38, ACCENT)
	col.add_child(title)
	var sub := _label("", 20, MUTED)
	_screens.set("map_sub", sub)
	col.add_child(sub)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	col.add_child(grid)
	_screens.set("map_grid", grid)

	var nox_btn := _button("Talk to Nox")
	nox_btn.pressed.connect(_open_nox)
	_screens.set("map_nox", nox_btn)
	col.add_child(nox_btn)

	var choice_btn := _button("The Broken Path")
	choice_btn.pressed.connect(_open_choice)
	_screens.set("map_choice", choice_btn)
	col.add_child(choice_btn)

	var back := _button("Back")
	back.pressed.connect(_open_title)
	col.add_child(back)
	return p["root"]

func _refresh_map() -> void:
	var grid: GridContainer = _screens["map_grid"]
	for c in grid.get_children():
		# Detach immediately, then free: keeps a re-entered map free of stale duplicate
		# cards even when no frame has elapsed (e.g. synchronous tests).
		grid.remove_child(c)
		c.queue_free()
	var levels: Array = game.levels
	var solved_count := 0
	for i in range(levels.size()):
		var lvl: Dictionary = levels[i]
		var lid := str(lvl["level_id"])
		var solved := game.game_state.is_solved(lid)
		if solved:
			solved_count += 1
		var unlocked: bool = game.game_state.is_level_unlocked(levels, i)
		var stars: int = game.game_state.best_stars(lid)
		var star_text := "☆☆☆"
		if solved:
			star_text = ""
			for k in range(3):
				star_text += "★" if k < stars else "☆"
		var status := "Locked" if not unlocked else ("Completed" if solved else "Available")
		if solved:
			star_text = "Best: " + star_text
		elif unlocked:
			star_text = "Not yet solved"
		var colour := CARD_LOCKED if not unlocked else (CARD_DONE if solved else CARD)
		var card := _card("%d. %s" % [int(lvl.get("ordinal", i + 1)), str(lvl.get("title", ""))], "%s · %s" % [status, star_text], colour)
		grid.add_child(card["panel"])
		var action := _button("Replay" if solved else "Play", 20)
		action.disabled = not unlocked
		action.pressed.connect(_play_level.bind(i))
		card["box"].add_child(action)

	var sub: Label = _screens["map_sub"]
	if game.game_state.campaign_complete(levels):
		sub.text = "Chapter One complete — every ward is lit. Replay any level to improve your best."
	else:
		sub.text = "%d of %d levels solved. Choose an available level." % [solved_count, levels.size()]
	# Nox is only offered once it has genuinely awakened.
	var nox_btn: Button = _screens["map_nox"]
	var awakened: bool = game.game_state.world_flags.has("stone_marks_awaken")
	nox_btn.visible = awakened
	nox_btn.disabled = not awakened
	# The first-node choice appears once its beat is reachable; label shows the decision made.
	var choice_btn: Button = _screens["map_choice"]
	var choice_available: bool = game.first_node_choice_available()
	choice_btn.visible = choice_available
	var chosen := game.first_node_choice()
	if choice_available and chosen != "":
		choice_btn.text = "The Broken Path — chose the %s node" % chosen
	else:
		choice_btn.text = "The Broken Path"

# --- journal ---------------------------------------------------------------------------

func _build_journal() -> Control:
	var p := _panel("Journal")
	var col: VBoxContainer = p["col"]
	var title := _label("Discoveries", 38, ACCENT)
	col.add_child(title)
	var sub := _label("", 20, MUTED)
	_screens.set("journal_sub", sub)
	col.add_child(sub)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 10)
	col.add_child(list)
	_screens.set("journal_list", list)
	var equip_title := _label("Equipment", 30, ACCENT)
	col.add_child(equip_title)
	var equip_list := VBoxContainer.new()
	equip_list.add_theme_constant_override("separation", 10)
	col.add_child(equip_list)
	_screens.set("journal_equipment", equip_list)
	var back := _button("Back")
	back.pressed.connect(_open_map)
	col.add_child(back)
	return p["root"]

func _refresh_journal() -> void:
	var list: VBoxContainer = _screens["journal_list"]
	for c in list.get_children():
		list.remove_child(c)
		c.queue_free()
	var all := StoryContent.all_discoveries()
	var found := 0
	for disc in all:
		var did := str(disc.get("id", ""))
		var have: bool = game.game_state.discoveries.has(did)
		if have:
			found += 1
		var name := str(disc.get("name", "")) if have else "Undiscovered"
		var text := str(disc.get("text", "")) if have else "Locked — keep playing to reveal this entry."
		var card := _card(name, text, CARD_DONE if have else CARD_LOCKED)
		list.add_child(card["panel"])
	var sub: Label = _screens["journal_sub"]
	sub.text = "%d of %d entries discovered." % [found, all.size()]
	_refresh_equipment()

## The equipment panel: every owned item with an Equip/Unequip control that performs the real
## loadout change. Equipping is the "use item" loop — it changes what the HUD can perceive
## (PD-002), never puzzle truth. Owned items only, so nothing unobtained can be equipped.
func _refresh_equipment() -> void:
	var list: VBoxContainer = _screens["journal_equipment"]
	for c in list.get_children():
		list.remove_child(c)
		c.queue_free()
	var owned: Array = game.game_state.owned_equipment
	if owned.is_empty():
		var empty := _card("No equipment yet", "Complete Chapter One levels to earn equipment.", CARD_LOCKED)
		list.add_child(empty["panel"])
		return
	for id in owned:
		var item := StoryContent.equipment_by_id(str(id))
		var equipped: bool = game.game_state.is_equipped(str(id))
		var card := _card(str(item.get("name", str(id))), str(item.get("purpose", "")), CARD_DONE if equipped else CARD_LOCKED)
		var btn := _button("Unequip" if equipped else "Equip", 20)
		var item_id := str(id)
		btn.pressed.connect(func() -> void: _toggle_equip(item_id))
		card["box"].add_child(btn)
		list.add_child(card["panel"])

## Toggle one owned item's equipped state through the real GameState, persist, and refresh the
## live gameplay readouts so the change is visible immediately during play.
func _toggle_equip(id: String) -> void:
	if not game.game_state.owns(id):
		return
	if game.game_state.is_equipped(id):
		game.game_state.unequip(id)
	else:
		game.game_state.equip(id)
	game.save_progress()
	_refresh_equipment()
	_refresh_live_gameplay()

## Push a loadout change made in the journal into the running gameplay HUD, so equipping an
## item has a visible effect immediately rather than only after re-entering the level.
func _refresh_live_gameplay() -> void:
	if game == null:
		return
	var hud := game.get_node_or_null("HUD")
	if hud and hud.has_method("refresh_readouts"):
		hud.refresh_readouts()

# --- settings --------------------------------------------------------------------------

func _build_settings() -> Control:
	var p := _panel("Settings")
	var col: VBoxContainer = p["col"]
	var title := _label("Settings", 38, ACCENT)
	col.add_child(title)

	var big := _button("Large text: Off")
	big.pressed.connect(_toggle_big_text)
	_screens.set("set_big", big)
	col.add_child(big)
	var rm := _button("Reduced motion: Off")
	rm.pressed.connect(_toggle_reduced_motion)
	_screens.set("set_rm", rm)
	col.add_child(rm)

	var cam_label := _label("Camera distance", 20, MUTED)
	col.add_child(cam_label)
	var slider := HSlider.new()
	slider.min_value = 4.2
	slider.max_value = 12.0
	slider.step = 0.1
	slider.value = 7.3
	slider.custom_minimum_size = Vector2(0, 44)
	slider.value_changed.connect(_on_camera_distance)
	_screens.set("set_cam", slider)
	col.add_child(slider)
	var reset_cam := _button("Reset camera view")
	reset_cam.pressed.connect(_on_reset_camera)
	col.add_child(reset_cam)

	var note := _label("Audio settings are not shown because no game audio is implemented yet.", 16, MUTED)
	col.add_child(note)

	var back := _button("Back")
	back.pressed.connect(_open_title)
	col.add_child(back)
	return p["root"]

func _refresh_settings() -> void:
	var big: Button = _screens["set_big"]
	big.text = "Large text: %s" % ("On" if _big_text else "Off")
	var rm: Button = _screens["set_rm"]
	rm.text = "Reduced motion: %s" % ("On" if _reduced_motion else "Off")

func _toggle_big_text() -> void:
	_big_text = not _big_text
	settings["big_text"] = _big_text
	SaveManager.update_settings({"big_text": _big_text}, settings_path)
	_apply_big_text(_big_text)
	_refresh_settings()
	_sync_game_accessibility()

func _toggle_reduced_motion() -> void:
	_reduced_motion = not _reduced_motion
	settings["reduced_motion"] = _reduced_motion
	SaveManager.update_settings({"reduced_motion": _reduced_motion}, settings_path)
	_refresh_settings()
	_sync_game_accessibility()

func _on_camera_distance(value: float) -> void:
	if game and game.camera:
		game.camera.zoom(value - game.camera.get_distance())

func _on_reset_camera() -> void:
	if game and game.camera:
		game.camera.reset_view()

## Push the app's accessibility preferences onto the gameplay HUD + cube view, so a change
## made in the settings screen has a real effect during play. The HUD also persists the same
## keys, so the two paths agree.
func _sync_game_accessibility() -> void:
	if game == null:
		return
	if game.cube_view:
		game.cube_view.reduced_motion = _reduced_motion
	var hud := game.get_node_or_null("HUD")
	if hud and hud.has_method("set_big_text"):
		hud.set_big_text(_big_text)
	if hud and hud.has_method("set_reduced_motion"):
		hud.set_reduced_motion(_reduced_motion)

# --- results ---------------------------------------------------------------------------

func _build_results() -> Control:
	var p := _panel("Results")
	var col: VBoxContainer = p["col"]
	var title := _label("", 40, ACCENT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_screens.set("res_title", title)
	col.add_child(title)
	var stars := _label("", 48, STAR_ON)
	stars.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_screens.set("res_stars", stars)
	col.add_child(stars)
	var body := _label("", 22)
	_screens.set("res_body", body)
	col.add_child(body)

	var cont := _button("Continue")
	cont.pressed.connect(_on_results_continue)
	_screens.set("res_continue", cont)
	col.add_child(cont)
	var replay := _button("Replay")
	replay.pressed.connect(_on_results_replay)
	col.add_child(replay)
	var to_map := _button("Chapter Map")
	to_map.pressed.connect(_open_map)
	col.add_child(to_map)
	return p["root"]

func _on_result_ready(result: Dictionary) -> void:
	_refresh_results(result)
	_show("results", true)
	# The world just changed (a ward lit); re-register targets so the sigil/companion that
	# became available can be tapped without leaving and re-entering gameplay.
	_refresh_world_targets()

func _refresh_results(result: Dictionary) -> void:
	var title: Label = _screens["res_title"]
	var stars: Label = _screens["res_stars"]
	var body: Label = _screens["res_body"]
	var cont: Button = _screens["res_continue"]
	title.text = "%d. %s" % [int(result.get("ordinal", 0)), str(result.get("title", ""))]
	var s := int(result.get("stars", 0))
	stars.text = ""
	for k in range(3):
		stars.text += "★" if k < s else "☆"
	var lines := PackedStringArray()
	lines.append("Moves: %d (par %d)" % [int(result.get("moves", 0)), int(result.get("par", 0))])
	lines.append("Mastery this attempt: %d star%s" % [s, "" if s == 1 else "s"])
	lines.append("Best: %d star%s · %d moves" % [int(result.get("best_stars", 0)), "" if int(result.get("best_stars", 0)) == 1 else "s", int(result.get("best_moves", 0))])
	if bool(result.get("improved", false)):
		lines.append("New best result!")
	elif bool(result.get("is_best", false)):
		lines.append("First result recorded.")
	else:
		lines.append("Kept your stronger previous result.")
	if result.has("discovery_name"):
		lines.append("Discovery: " + str(result.get("discovery_name", "")))
	if result.has("reward_narrative") and str(result.get("reward_narrative", "")) != "":
		lines.append(str(result.get("reward_narrative", "")))
	body.text = "\n".join(lines)
	if bool(result.get("campaign_complete", false)):
		cont.text = "Finish chapter"
	elif int(result.get("next_index", -1)) >= 0:
		cont.text = "Continue to next level"
	else:
		cont.text = "Chapter map"

func _on_results_continue() -> void:
	var r := game.last_result_data()
	if int(r.get("next_index", -1)) >= 0:
		_play_level(int(r["next_index"]))
	else:
		_open_map()

func _on_results_replay() -> void:
	_play_level(game.current_index)

# --- navigation ------------------------------------------------------------------------

func current_screen() -> String:
	return _active

## Show a screen by name. "game" is a pseudo-screen: no menu root is shown and the gameplay
## instance is revealed instead. Any other name must be a real screen root.
func _show(name: String, keep_game_visible: bool = false) -> void:
	for key in _screen_roots.keys():
		var c: Control = _screen_roots[key]
		c.visible = false
	var show_game := name == "game"
	if game:
		game.visible = show_game and keep_game_visible
		if game.router:
			# The arbiter only classifies puzzle/world intents while gameplay is on screen, so a
			# menu tap can never twist the cube behind it.
			game.router.enabled = show_game
			if show_game:
				_refresh_world_targets()
	if not show_game and _screen_roots.has(name):
		var s: Control = _screen_roots[name]
		s.visible = true
	_active = name

## Register the current interactive world targets with the router so a tap on a target
## emits a world command (never an orbit or a cube twist). Targets are presentation data
## owned by WorldView; the router only hit-tests them.
func _refresh_world_targets() -> void:
	if game == null or game.router == null or game.world_view == null:
		return
	# Keep the router's projection in sync with the real viewport so hit-testing matches what
	# the player actually sees.
	var vp := get_viewport()
	if vp != null:
		game.router.viewport_size = vp.get_visible_rect().size
	game.router.world_targets = game.world_view.interactive_targets()

func _open_title() -> void:
	_refresh_title()
	_show("title")

func _refresh_title() -> void:
	var cont: Button = _screens["title_continue"]
	var has_progress: bool = _has_progress()
	cont.disabled = not has_progress
	cont.text = "Continue" if has_progress else "Continue (no progress yet)"

func _open_map() -> void:
	_refresh_map()
	_show("map")

func _open_journal() -> void:
	_refresh_journal()
	_show("journal")

func _open_settings() -> void:
	_refresh_settings()
	_show("settings")

func _has_progress() -> bool:
	if game == null:
		return false
	return not game.game_state.solved_levels.is_empty() or game.game_state.current_level_index > 0

func _on_new_game_pressed() -> void:
	if _has_progress():
		# Never erase progress on a single press: the wipe happens only via the dialog's
		# confirmed signal (`_begin_new_game`).
		if is_inside_tree():
			_confirm.popup_centered()
	else:
		_begin_new_game()

## Erase progress and start Chapter One from the first level. This is the ONLY path that
## clears a save, and it is reachable only through the deliberate confirmation above.
func _begin_new_game() -> void:
	SaveManager.delete_at_path(game.save_path)
	game.start_new_game()
	_sync_game_accessibility()
	_play_level(0)

func _on_continue_pressed() -> void:
	if not _has_progress():
		return
	var levels: Array = game.levels
	var idx: int = game.game_state.first_unsolved_index(levels)
	if idx < 0:
		# Campaign finished: send the player to the map, which offers replay.
		_open_map()
		return
	if not game.game_state.is_level_unlocked(levels, idx):
		idx = game.game_state.highest_unlocked_index(levels)
	_play_level(idx)

## Enter a level from the app. `force` (replay of a solved level) is passed through, but a
## locked level is still refused by the controller's own gate, so no UI path can skip a
## prerequisite. Returns false when the level could not be entered.
func _play_level(index: int) -> bool:
	var solved := index >= 0 and index < game.levels.size() and game.game_state.is_solved(str(game.levels[index]["level_id"]))
	var ok: bool = game.load_level(index, solved)
	if not ok:
		return false
	_show("game", true)
	return true

func _on_exit() -> void:
	if game:
		game.save_progress()
	if is_inside_tree():
		get_tree().quit()

# --- Nox -------------------------------------------------------------------------------

## The authored Nox dialogue the companion can currently offer. Empty before Nox awakens,
## so the interaction is genuinely unavailable before the real progression event.
func nox_dialogue_text() -> String:
	if game == null or not game.game_state.world_flags.has("stone_marks_awaken"):
		return ""
	var lines := PackedStringArray()
	lines.append(StoryContent.nox_line("greeting"))
	lines.append(StoryContent.nox_line("awakened"))
	lines.append(StoryContent.nox_line("resonance"))
	if game.game_state.campaign_complete(game.levels):
		lines.append(StoryContent.nox_line("closing"))
	return "\n\n".join(lines)

func nox_available() -> bool:
	return game != null and game.game_state.world_flags.has("stone_marks_awaken")

## A tap on a world target (routed by the single interaction arbiter) performs the target's
## real action. The sigil reveals the three-notch clue and grants its discovery exactly once;
## a repeat tap re-opens the text without re-granting. Tapping the companion opens its
## dialogue. Unknown ids are ignored, so a stale target can never do something unexpected.
func _on_world_tapped(target_id: String) -> void:
	match target_id:
		WorldView.TARGET_SIGIL:
			_read_sigil()
		WorldView.TARGET_NOX:
			_open_nox()
		WorldView.TARGET_NODE_NEAR:
			_choose_first_node("near")
		WorldView.TARGET_NODE_FAR:
			_choose_first_node("far")
		_:
			pass

## The Beat 5 choice is only actionable once it is genuinely available (level 2 solved) and
## Nox/the world have begun to answer. A tap on a path node records the decision and re-opens
## the dialogue showing the world's reply.
func _choose_first_node(option: String) -> void:
	if game == null or not game.first_node_choice_available():
		return
	game.record_choice(GameController.FIRST_NODE_CHOICE, option)
	_open_choice()

## Open the first-node choice. Unavailable before the beat, so the interaction cannot be
## reached out of order; re-opening after a decision shows the recorded option and its reply.
func _open_choice() -> void:
	if game == null or not game.first_node_choice_available():
		return
	var chosen := game.first_node_choice()
	var text := "Two dormant nodes flank the broken path. Only one will wake first."
	if chosen != "":
		text += "\n\n" + StoryContent.choice_option_reaction(GameController.FIRST_NODE_CHOICE, chosen)
	_choice_dialog.dialog_text = text
	# Reflect the recorded decision on the option buttons so re-deciding is legible.
	_choice_near_btn.disabled = chosen == "near"
	_choice_far_btn.disabled = chosen == "far"
	if is_inside_tree():
		_choice_dialog.popup_centered()

func _on_choice_dialog_action(action: StringName) -> void:
	var option := str(action)
	if option == "near" or option == "far":
		if game != null and game.first_node_choice_available():
			game.record_choice(GameController.FIRST_NODE_CHOICE, option)
			_open_choice()

## Reveal the sigil clue. The discovery is granted only on the first read (idempotent), and
## the "sigil_read" world flag is persisted so the clue stays discovered across restarts.
func _read_sigil() -> void:
	if game == null or game.world_view == null or not game.world_view.sigil_available():
		return
	var first: bool = game.world_view.read_sigil()
	if first:
		game.game_state.add_discovery("discovery.01.three_notch_mark")
		game.game_state.set_world_flag("sigil_read")
		game.save_progress()
	if _nox_dialog == null:
		return
	_nox_dialog.title = "The Three-Notch Mark"
	_nox_dialog.dialog_text = StoryContent.sigil_clue()
	if is_inside_tree():
		_nox_dialog.popup_centered()

func _open_nox() -> void:
	var text := nox_dialogue_text()
	if text == "":
		return
	_nox_dialog.title = "Nox"
	_nox_dialog.dialog_text = text
	if is_inside_tree():
		_nox_dialog.popup_centered()

# --- accessibility text scaling --------------------------------------------------------

## Scale every label/button the app built by the large-text factor. Base sizes are stored in
## node metadata at creation, so this is idempotent and never compounds.
func _apply_big_text(on: bool) -> void:
	var mult := 1.4 if on else 1.0
	for name in _screen_roots.keys():
		_scale_subtree(_screen_roots[name], mult)

func _scale_subtree(node: Node, mult: float) -> void:
	if node.has_meta("base_font"):
		var base := int(node.get_meta("base_font"))
		if node is Label or node is Button:
			node.add_theme_font_size_override("font_size", int(base * mult))
	for c in node.get_children():
		_scale_subtree(c, mult)

# --- platform back / close -------------------------------------------------------------

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if game:
			game.save_progress()
		if is_inside_tree():
			get_tree().quit()
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if game:
			game.save_progress()
		if _active == "title":
			if is_inside_tree():
				get_tree().quit()
		elif _active == "game":
			_open_map()
		elif _active == "results":
			_open_map()
		else:
			_open_title()
