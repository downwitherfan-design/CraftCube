class_name StoryContent
extends RefCounted

## Chapter 01 story/content bindings: world hooks, rewards, equipment and the
## optional discovery. Text is original CraftCube prose (IP-safe; no third-party
## names). IDs follow AI-03's `reward.<ch>.<slug>` / `discovery.<ch>.<slug>` scheme.

## World reaction shown when a level's world_hook fires (puzzle mastery -> world).
const WORLD_REACTIONS := {
	"mechanism_awakens": "The Loom shivers awake. Light crawls across the stone.",
	"seed_grows": "A seed of light takes root where the cube settled.",
	"stone_marks_awaken": "Old marks glow along the hollowed stone.",
}

## Equipment granted by rewards. Each declares a player-facing purpose (PD-002:
## equipment changes what you can perceive/reach/attempt, never puzzle truth).
const EQUIPMENT := {
	"equipment.rootweave_gauntlet": {
		"name": "Rootweave Gauntlet",
		"purpose": "Reads faint resonance in nearby tiles — shows where a layer is close to settling.",
		"effect": "perceive.resonance",
	},
	"equipment.stone_lens": {
		"name": "Stone Lens",
		"purpose": "Reveals hidden marks on veiled tiles.",
		"effect": "perceive.veiled",
	},
}

## Rewards: reward_id -> {class, equipment, narrative}.
const REWARDS := {
	"reward.01.first_alignment": {
		"class": "world_change", "equipment": "", "narrative": "",
	},
	"reward.01.seed_knowledge": {
		"class": "knowledge", "equipment": "", "narrative": "",
	},
	"reward.01.nox_meets": {
		"class": "narrative", "equipment": "equipment.rootweave_gauntlet",
		"narrative": "Nox, a small stone companion, wakes and presses close to the cube. It offers the Rootweave Gauntlet it has carried.",
	},
}

## The optional Chapter 01 discovery (chapter-level, non-blocking).
const DISCOVERY_FIRST_PULSE := {
	"id": "discovery.01.first_pulse",
	"name": "The First Pulse",
	"text": "You notice the cube answers near-solutions with a soft pulse — a rhythm you can learn to read.",
}

static func reaction_for(hook: String) -> String:
	return str(WORLD_REACTIONS.get(hook, ""))

static func reward_for(reward_id: String) -> Dictionary:
	return REWARDS.get(reward_id, {})

## The equipment id granted by a reward ("" if none). Single source of truth so callers
## never hard-code a reward->equipment mapping.
static func equipment_id_for(reward_id: String) -> String:
	return str(REWARDS.get(reward_id, {}).get("equipment", ""))

static func equipment_for(reward_id: String) -> Dictionary:
	return EQUIPMENT.get(equipment_id_for(reward_id), {})
