class_name SaveManager
extends RefCounted

## Godot-native local persistence (user:// path, JSON). Versioned for compatibility:
## a save from a newer/unknown version is rejected rather than mis-loaded.
## Clock-free and filesystem-light so it is unit-testable headless via an explicit path.
##
## Writes are atomic: the payload is written to a temporary file, flushed, then
## renamed over the target, so an interrupted write never leaves a half-written save.
## A malformed/unparseable save is quarantined to `<path>.corrupt` and a fresh state
## is returned, so a corrupt save can never masquerade as valid completed progress.

const DEFAULT_PATH := "user://craftcube_save.json"

static func save_to_path(gs: GameState, path: String = DEFAULT_PATH) -> bool:
	var payload := JSON.stringify(gs.to_dict())
	var tmp := path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_error("SaveManager: cannot open %s for writing" % tmp)
		return false
	f.store_string(payload)
	f.flush()
	f.close()
	# rename() is atomic on the same filesystem; fall back if the platform refuses.
	var err := DirAccess.rename_absolute(_abs(tmp), _abs(path))
	if err != OK:
		push_warning("SaveManager: rename failed (%d); writing in place" % err)
		var g := FileAccess.open(path, FileAccess.WRITE)
		if g == null:
			return false
		g.store_string(payload)
		g.close()
		DirAccess.remove_absolute(_abs(tmp))
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
		push_warning("SaveManager: save file is not valid JSON; quarantined, starting fresh")
		_quarantine(path)
		return GameState.new()
	var version := int(parsed.get("save_version", 0))
	if version <= 0:
		push_warning("SaveManager: save file has no usable version; quarantined, starting fresh")
		_quarantine(path)
		return GameState.new()
	if version > GameState.SAVE_VERSION:
		push_warning("SaveManager: save version %d is newer than supported %d" % [version, GameState.SAVE_VERSION])
		return GameState.new()
	return GameState.from_dict(parsed)

static func delete_at_path(path: String = DEFAULT_PATH) -> void:
	for p in [path, path + ".tmp", path + ".corrupt"]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(_abs(p))

static func _abs(path: String) -> String:
	return ProjectSettings.globalize_path(path)

## Preserve a corrupt save next to the original (never destroyed) and stop it from
## being re-read as valid progress on the next launch.
static func _quarantine(path: String) -> void:
	var dest := path + ".corrupt"
	if FileAccess.file_exists(dest):
		DirAccess.remove_absolute(_abs(dest))
	DirAccess.rename_absolute(_abs(path), _abs(dest))
