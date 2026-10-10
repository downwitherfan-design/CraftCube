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

## Chapter 01 optional discoveries (chapter-level, non-blocking), keyed by ID so any
## level's `discovery_id` resolves without hard-coding a single one in the controller.
const DISCOVERIES := {
	"discovery.01.first_pulse": {
		"id": "discovery.01.first_pulse",
		"name": "The First Pulse",
		"text": "You notice the cube answers near-solutions with a soft pulse — a rhythm you can learn to read.",
	},
	"discovery.01.stone_mark": {
		"id": "discovery.01.stone_mark",
		"name": "The Stone Mark",
		"text": "A pale groove runs along the sealed stone. It is not decoration — it is a tally of every layer you have brought home.",
	},
}

static func reaction_for(hook: String) -> String:
	return str(WORLD_REACTIONS.get(hook, ""))

static func discovery_for(id: String) -> Dictionary:
	return DISCOVERIES.get(id, {})

static func reward_for(reward_id: String) -> Dictionary:
	return REWARDS.get(reward_id, {})

## Equipment record by its own id (id -> {name, purpose, effect}).
static func equipment_by_id(id: String) -> Dictionary:
	return EQUIPMENT.get(id, {})

## A capability slot is the category after the last dot of an effect id, so
## "perceive.resonance" -> "resonance". Owners and consumers key off the slot, never the
## equipment id, so future equipment can grant the same capability.
static func effect_slot(effect: String) -> String:
	var parts := effect.split(".")
	return parts[parts.size() - 1] if parts.size() >= 2 else effect

## The equipment id granted by a reward ("" if none). Single source of truth so callers
## never hard-code a reward->equipment mapping.
static func equipment_id_for(reward_id: String) -> String:
	return str(REWARDS.get(reward_id, {}).get("equipment", ""))

static func equipment_for(reward_id: String) -> Dictionary:
	return EQUIPMENT.get(equipment_id_for(reward_id), {})
