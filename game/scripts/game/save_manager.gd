class_name SaveManager
extends RefCounted

## Godot-native local persistence (user:// path, JSON). Versioned for compatibility:
## a save from a newer/unknown version is rejected rather than mis-loaded.
## Clock-free and filesystem-light so it is unit-testable headless via an explicit path.

const DEFAULT_PATH := "user://craftcube_save.json"

static func save_to_path(gs: GameState, path: String = DEFAULT_PATH) -> bool:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("SaveManager: cannot open %s for writing" % path)
		return false
	f.store_string(JSON.stringify(gs.to_dict()))
	f.close()
	return true

static func load_from_path(path: String = DEFAULT_PATH) -> GameState:
	if not FileAccess.file_exists(path):
		return GameState.new()
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return GameState.new()
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("SaveManager: save file is not valid JSON; starting fresh")
		return GameState.new()
	var version := int(parsed.get("save_version", 0))
	if version > GameState.SAVE_VERSION:
		push_warning("SaveManager: save version %d is newer than supported %d" % [version, GameState.SAVE_VERSION])
		return GameState.new()
	return GameState.from_dict(parsed)

static func delete_at_path(path: String = DEFAULT_PATH) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
