class_name LevelCatalog
extends RefCounted

## Canonical Chapter 01 ("First Light") vertical-slice level set, transcribed from
## AI-03's Phase 00 draft fixture `levels.slice.draft.json` and Chapter 01 signature
## (`chapters.draft.json`). IDs and objective families are AI-03 content; this file
## only binds them to the deterministic engine.
##
## DEVIATION FROM THE DRAFT FIXTURE (needs AI-03 confirmation): the draft's
## `rule.axis_lock {axes:[X,Z]}` combined with `objective.align{U}` is degenerate —
## locking X and Z leaves only Y-axis turns (U/D), which never disturb the U face, so
## the level is solved before the player moves. The rules below are the minimal change
## that keeps each level genuinely playable while preserving the objective and the
## "introduce one constraint" chapter signature (see game/docs/ENGINE_AND_BUILD.md).

const CHAPTER_ID := "chapter.01.first_light"

static func chapter_one() -> Array:
	return [
		{
			"level_id": "level.01.awaken",
			"ordinal": 1,
			"topology_id": "topology.cube.2",
			"scramble": {"seed": 101, "depth_hint": 3},
			"objective": {"family": "objective.align", "params": {"faces": ["U"]}},
			"level_rules": [],
			"par_moves": 3,
			"title": "Awaken",
			"hint": "Twist any face until one side is a single colour.",
			"world_hook": "mechanism_awakens",
			"reward_id": "reward.01.first_alignment",
			"discovery_id": "",
		},
		{
			"level_id": "level.01.seed_bed",
			"ordinal": 2,
			"topology_id": "topology.cube.2",
			"scramble": {"seed": 102, "depth_hint": 5},
			"objective": {"family": "objective.align", "params": {"faces": ["U"]}},
			"level_rules": [],
			"par_moves": 5,
			"title": "Seed Bed",
			"hint": "Align the top, then watch for the first pulse.",
			"world_hook": "seed_grows",
			"reward_id": "reward.01.seed_knowledge",
			"discovery_id": "discovery.01.first_pulse",
		},
		{
			"level_id": "level.01.hollow_stone",
			"ordinal": 3,
			"topology_id": "topology.cube.2",
			"scramble": {"seed": 103, "depth_hint": 7},
			"objective": {"family": "objective.align", "params": {"faces": ["U", "F"]}},
			# Y-axis lock: you may not twist the top/bottom faces directly; you must bring
			# both required faces home using the side faces. Non-degenerate (X/Z turns
			# disturb U and F), and it introduces the first constraint of the chapter.
			"level_rules": [{"rule_id": "rule.axis_lock", "params": {"axes": ["Y"]}, "relaxable": false}],
			"par_moves": 7,
			"title": "Hollow Stone",
			"hint": "The top and bottom are sealed. Turn the sides until two faces sing together.",
			"world_hook": "stone_marks_awaken",
			"reward_id": "reward.01.nox_meets",
			"discovery_id": "discovery.01.stone_mark",
		},
	]

static func by_id(level_id: String) -> Dictionary:
	for l in chapter_one():
		if str(l["level_id"]) == level_id:
			return l
	return {}
