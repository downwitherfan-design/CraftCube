class_name Version
extends RefCounted
## Single source of truth for the CraftCube application version, read from
## res://app_version.json. Used for the on-screen version and as the value that
## game/ci/validate_version.py proves is consistent with export_presets.cfg.
##
## The authoritative application version is MAJOR.MINOR.PATCH; version_code is a
## separate, strictly increasing Android integer (see 12_RELEASE/ANDROID_RELEASE_POLICY.md).

const VERSION_PATH := "res://app_version.json"

## "MAJOR.MINOR.PATCH", or "" when the file is missing/malformed.
static func app_version() -> String:
	return str(_read().get("app_version", ""))

## Android integer version code, or 0 when unavailable.
static func version_code() -> int:
	return int(_read().get("version_code", 0))

## "vMAJOR.MINOR.PATCH", or "" when unavailable.
static func tag() -> String:
	var v := app_version()
	return "v" + v if v != "" else ""

## A short label for the UI, e.g. "v0.2.0 (2)". Empty when the version is unknown.
static func display() -> String:
	var v := app_version()
	if v == "":
		return ""
	return "v%s (%d)" % [v, version_code()]

static func _read() -> Dictionary:
	if not FileAccess.file_exists(VERSION_PATH):
		return {}
	var f := FileAccess.open(VERSION_PATH, FileAccess.READ)
	if f == null:
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	return parsed if parsed is Dictionary else {}
