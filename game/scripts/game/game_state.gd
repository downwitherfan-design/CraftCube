class_name GameState
extends RefCounted

## Player progression: which levels are solved, discoveries found, equipment owned
## and the currently equipped loadout (<= 4 slots, PD-002). Serialisable to a
## versioned dictionary for save/load.
##
## SAVE_VERSION history:
##   1 — solved_levels, discoveries, owned_equipment, loadout, world_flags, current_level_index.
##   2 — adds `level_records`: per-level best mastery (best_moves / best_stars) plus minimal
##       attempt and hint statistics. A version-1 save loads unchanged (no records) and is
##       upgraded in place; nothing from version 1 is dropped.

const SAVE_VERSION := 2
const MAX_SLOTS := 4

var solved_levels: Array = []          # ordered level_ids
var discoveries: Array = []            # discovery_ids found
var owned_equipment: Array = []        # equipment ids
var loadout: Array = []                # equipped equipment ids (<= MAX_SLOTS)
var world_flags: Dictionary = {}       # world_hook -> true
var current_level_index: int = 0
# level_id -> {"best_moves": int, "best_stars": int, "attempts": int, "hints": int}
var level_records: Dictionary = {}

func is_solved(level_id: String) -> bool:
	return solved_levels.has(level_id)

func mark_solved(level_id: String) -> void:
	if not solved_levels.has(level_id):
		solved_levels.append(level_id)

## Deterministic mastery rating from the actual move count and the level's par target:
##   * 3 stars — moves <= par.
##   * 2 stars — moves <= floor(1.5 * par) (above par, within 150%).
##   * 1 star  — anything worse.
## Integer arithmetic only, so the rule is exact and testable. par <= 0 is treated as a
## free level (3 stars for any completion) rather than an impossible target.
static func stars_for(moves: int, par: int) -> int:
	if par <= 0:
		return 3
	if moves <= par:
		return 3
	if moves <= (par * 3) / 2:
		return 2
	return 1

## Best record for a level ({} when never completed). Never mutates the stored record.
func best_for(level_id: String) -> Dictionary:
	return level_records.get(level_id, {})

func best_stars(level_id: String) -> int:
	return int(best_for(level_id).get("best_stars", 0))

func best_moves(level_id: String) -> int:
	return int(best_for(level_id).get("best_moves", -1))

## Record a completed attempt. Returns {"is_best": bool, "improved": bool, "record": dict}.
## A weaker replay never overwrites a stronger record: best_stars is the maximum, and fewer
## moves only break a tie on equal stars. Attempt/hint counters accumulate for feedback.
func record_attempt(level_id: String, moves: int, stars: int, hints: int = 0) -> Dictionary:
	var rec: Dictionary = level_records.get(level_id, {})
	var had := not rec.is_empty()
	var prev_stars := int(rec.get("best_stars", 0))
	var prev_moves := int(rec.get("best_moves", -1))
	var is_best := false
	if not had:
		is_best = true
	elif stars > prev_stars:
		is_best = true
	elif stars == prev_stars and moves < prev_moves:
		is_best = true
	var out := {
		"best_moves": moves if is_best else prev_moves,
		"best_stars": stars if is_best else prev_stars,
		"attempts": int(rec.get("attempts", 0)) + 1,
		"hints": int(rec.get("hints", 0)) + maxi(0, hints),
	}
	level_records[level_id] = out
	return {"is_best": is_best, "improved": had and is_best, "record": out.duplicate()}

## Sequential campaign rule: the first level is always open; every later level unlocks only
## when its immediate predecessor is solved. This is the single gate the UI and the
## controller's entry path both consult, so a locked level cannot be entered by any action.
func is_level_unlocked(levels: Array, index: int) -> bool:
	if index <= 0:
		return index == 0
	if index >= levels.size():
		return false
	return is_solved(str(levels[index - 1]["level_id"]))

## Index of the furthest level the player may currently enter (0 when nothing is solved).
func highest_unlocked_index(levels: Array) -> int:
	var out := 0
	for i in range(levels.size()):
		if is_level_unlocked(levels, i):
			out = i
	return out

## True when every level in the campaign has been solved.
func campaign_complete(levels: Array) -> bool:
	if levels.is_empty():
		return false
	return first_unsolved_index(levels) == -1

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

## True when an equipped item provides `slot` (e.g. "resonance"). Keyed off the effect
## category, not the equipment id, so any future item granting the same capability counts.
## The owning class is resolved through StoryContent, not hard-coded here.
func has_capability(slot: String) -> bool:
	if slot == "":
		return false
	for id in loadout:
		var eff := str(StoryContent.equipment_by_id(str(id)).get("effect", ""))
		if eff != "" and StoryContent.effect_slot(eff) == slot:
			return true
	return false

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
		"level_records": level_records.duplicate(true),
	}

## Rebuild a GameState from save data, defensively: a malformed field must never
## silently corrupt progression (wrong types are coerced; non-string IDs dropped).
##
## Schema migration is additive and lossless: a version-1 save has no `level_records`, so it
## loads with an empty mastery table while every v1 field is preserved exactly. Unknown
## future fields are ignored rather than rejected, so a newer save degrades safely.
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
	g.level_records = _records_dict(d.get("level_records", {}))
	return g

## Coerce the persisted mastery table: only string keys, only the known numeric fields,
## and only non-negative values. A malformed record is dropped, never trusted.
static func _records_dict(value) -> Dictionary:
	var out := {}
	if typeof(value) != TYPE_DICTIONARY:
		return out
	for k in value.keys():
		if typeof(k) != TYPE_STRING:
			continue
		var rec = value[k]
		if typeof(rec) != TYPE_DICTIONARY:
			continue
		var best_moves := int(rec.get("best_moves", -1))
		var best_stars := int(rec.get("best_stars", 0))
		if best_moves < 0 or best_stars < 0 or best_stars > 3:
			continue
		out[k] = {
			"best_moves": best_moves,
			"best_stars": best_stars,
			"attempts": maxi(0, int(rec.get("attempts", 0))),
			"hints": maxi(0, int(rec.get("hints", 0))),
		}
	return out

static func _string_list(value) -> Array:
	var out := []
	if typeof(value) != TYPE_ARRAY:
		return out
	for v in value:
		if typeof(v) == TYPE_STRING and not out.has(v):
			out.append(v)
	return out
