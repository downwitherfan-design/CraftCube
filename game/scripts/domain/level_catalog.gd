class_name LevelCatalog
extends RefCounted

## Canonical Chapter 01 ("First Light") vertical-slice level set, transcribed from
## AI-03's Phase 00 draft fixture `levels.slice.draft.json` and Chapter 01 signature
## (`chapters.draft.json`). IDs and objective families are AI-03 content; this file
## only binds them to the deterministic engine.
##
## RESOLVED CONTENT CONFLICT (AI-03 fixture vs. this binding):
## The AI-03 draft `rule.axis_lock {axes:[X,Z]}` on level.01.awaken is degenerate under
## the AI-03-documented semantics ("Moves on axis A are illegal", 03_LEVEL_GRAMMAR §1.3):
## locking X and Z leaves only Y-axis turns (U/D), which never move the U face, so the
## objective `objective.align{U}` is already satisfied at the scramble. Verified against
## the real engine: legal=["U","D"], solved_on_scramble=true, min_solve=0.
##
## Resolution (design intent preserved, minimal change):
##   * The draft's X/Z lock on level 1 is dropped. Chapter 01's Signature
##     (`05_CHAPTER_ANTI_REPETITION_STRATEGY.md` R1/R4) is the *topology* (`cube.2`) + the
##     `align` family + `tile.seed` — NOT a lock — so dropping an uninstructive, degenerate
##     lock does not violate the chapter signature.
##   * The chapter's single "introduce one constraint" moment is the `rule.axis_lock` on
##     level 3, where it is non-degenerate and necessary (verified: min_solve=6 under a Y
##     lock vs 4 with no lock).
## Level 2 keeps its draft Z lock removed for onboarding simplicity (draft min_solve=3 is
## trivial); its owned test asserts the level remains solvable and genuinely perturbed.
##
## Rule semantics implemented by the engine: `rule.axis_lock {axes:[...]}` marks the
## listed axes as ILLEGAL to turn (the documented meaning). See game/tests/run_tests.gd
## `_test_level_rule_semantics` for the regression proof.

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
			# Y-axis lock: Y-axis moves (U/D, the top/bottom faces) are illegal; bring both
			# required faces home using the side faces only. Non-degenerate and necessary
			# (verified min_solve: Y-lock=6, no lock=4) and it is the chapter's single
			# 'introduce one constraint' moment.
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
