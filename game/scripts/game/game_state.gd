class_name GameState
extends RefCounted

## Player progression: which levels are solved, discoveries found, equipment owned
## and the currently equipped loadout (<= 4 slots, PD-002). Serialisable to a
## versioned dictionary for save/load.

const SAVE_VERSION := 1
const MAX_SLOTS := 4

var solved_levels: Array = []          # ordered level_ids
var discoveries: Array = []            # discovery_ids found
var owned_equipment: Array = []        # equipment ids
var loadout: Array = []                # equipped equipment ids (<= MAX_SLOTS)
var world_flags: Dictionary = {}       # world_hook -> true
var current_level_index: int = 0

func is_solved(level_id: String) -> bool:
	return solved_levels.has(level_id)

func mark_solved(level_id: String) -> void:
	if not solved_levels.has(level_id):
		solved_levels.append(level_id)

func add_discovery(id: String) -> bool:
	if id == "" or discoveries.has(id):
		return false
	discoveries.append(id)
	return true

func set_world_flag(flag: String) -> void:
	world_flags[flag] = true

func grant_equipment(id: String) -> bool:
	if id == "" or owned_equipment.has(id):
		return false
	owned_equipment.append(id)
	if loadout.size() < MAX_SLOTS:
		loadout.append(id)
	return true

func owns(id: String) -> bool:
	return owned_equipment.has(id)

func is_equipped(id: String) -> bool:
	return loadout.has(id)

func equip(id: String) -> bool:
	if not owns(id):
		return false
	if loadout.has(id):
		return true
	if loadout.size() >= MAX_SLOTS:
		return false
	loadout.append(id)
	return true

func unequip(id: String) -> void:
	loadout.erase(id)

## Index of the first level in `levels` not yet solved, or -1 when all are solved.
func first_unsolved_index(levels: Array) -> int:
	for i in range(levels.size()):
		if not is_solved(str(levels[i]["level_id"])):
			return i
	return -1

func to_dict() -> Dictionary:
	return {
		"save_version": SAVE_VERSION,
		"solved_levels": solved_levels.duplicate(),
		"discoveries": discoveries.duplicate(),
		"owned_equipment": owned_equipment.duplicate(),
		"loadout": loadout.duplicate(),
		"world_flags": world_flags.duplicate(),
		"current_level_index": current_level_index,
	}

## Rebuild a GameState from save data, defensively: a malformed field must never
## silently corrupt progression (wrong types are coerced; non-string IDs dropped).
static func from_dict(d: Dictionary) -> GameState:
	var g := GameState.new()
	g.solved_levels = _string_list(d.get("solved_levels", []))
	g.discoveries = _string_list(d.get("discoveries", []))
	g.owned_equipment = _string_list(d.get("owned_equipment", []))
	g.loadout = _string_list(d.get("loadout", []))
	# Never trust a persisted loadout beyond the slot cap.
	if g.loadout.size() > MAX_SLOTS:
		g.loadout = g.loadout.slice(0, MAX_SLOTS)
	var flags = d.get("world_flags", {})
	if typeof(flags) == TYPE_DICTIONARY:
		for k in flags.keys():
			if typeof(k) == TYPE_STRING:
				g.world_flags[k] = true
	g.current_level_index = maxi(0, int(d.get("current_level_index", 0)))
	return g

static func _string_list(value) -> Array:
	var out := []
	if typeof(value) != TYPE_ARRAY:
		return out
	for v in value:
		if typeof(v) == TYPE_STRING and not out.has(v):
			out.append(v)
	return out
