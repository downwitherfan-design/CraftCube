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
##
## EPIC 0.3 PROTOTYPE EXTENSION (levels 4–6): the first three levels above are AI-03's
## canonical authored slice and are unchanged. Levels 4–6 are implementation-level prototype
## content authored for this task under the "Level 4–6" design intentions, and are NOT yet
## ratified canonical content. They are routed for ratification via the change-request
## workflow (see 11_INTEGRATION/CHANGE_REQUESTS.md, CR-0017). The chapter signature
## (topology + objective.align + deterministic scramble) is preserved; the newly exposed
## topology.cube.3 and the axis_lock constraints were verified against the real engine
## (see game/tests/run_tests.gd `_test_chapter_campaign_levels`).

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
		# --- Prototype levels 4–6 (EPIC 0.3; see header). Difficulty rises by topology and
		# constraint rather than scramble length alone: level 4 moves to a 3x3 with a
		# three-face objective, level 5 constrains one axis, level 6 combines both.
		{
			"level_id": "level.01.deeper_resonance",
			"ordinal": 4,
			"topology_id": "topology.cube.3",
			"scramble": {"seed": 104, "depth_hint": 10},
			"objective": {"family": "objective.align", "params": {"faces": ["U", "F", "R"]}},
			"level_rules": [],
			"par_moves": 10,
			"title": "Deeper Resonance",
			"hint": "A larger loom. Bring three faces home: top, front and right.",
			"world_hook": "resonance_deepens",
			"reward_id": "reward.01.deeper_resonance",
			"discovery_id": "discovery.01.deeper_resonance",
		},
		{
			"level_id": "level.01.constrained_paths",
			"ordinal": 5,
			"topology_id": "topology.cube.3",
			# X-axis lock: the left/right faces (L/R) are sealed. Only U/D/F/B are legal, so
			# the required top face must be brought home through the front and back turns.
			# Verified: legal faces = U,D,F,B; objective not auto-satisfied; solvable.
			"scramble": {"seed": 105, "depth_hint": 8},
			"objective": {"family": "objective.align", "params": {"faces": ["U"]}},
			"level_rules": [{"rule_id": "rule.axis_lock", "params": {"axes": ["X"]}, "relaxable": false}],
			"par_moves": 8,
			"title": "Constrained Paths",
			"hint": "The sides are sealed. Only the front and back will turn — reason before you twist.",
			"world_hook": "paths_converge",
			"reward_id": "reward.01.paths",
			"discovery_id": "",
		},
		{
			"level_id": "level.01.closing_trial",
			"ordinal": 6,
			"topology_id": "topology.cube.3",
			# Z-axis lock: the front/back faces (F/B) are sealed, so the front objective must be
			# reached without turning F or B directly. The chapter's closing trial combines a
			# multi-face objective with a constraint. Verified: legal = U,D,L,R; solvable.
			"scramble": {"seed": 106, "depth_hint": 12},
			"objective": {"family": "objective.align", "params": {"faces": ["U", "F"]}},
			"level_rules": [{"rule_id": "rule.axis_lock", "params": {"axes": ["Z"]}, "relaxable": false}],
			"par_moves": 12,
			"title": "The Closing Trial",
			"hint": "Front and back are sealed. Settle the top and the front together to close the chapter.",
			"world_hook": "chapter_sealed",
			"reward_id": "reward.01.chapter_seal",
			"discovery_id": "discovery.01.chapter_seal",
		},
	]

static func by_id(level_id: String) -> Dictionary:
	for l in chapter_one():
		if str(l["level_id"]) == level_id:
			return l
	return {}
