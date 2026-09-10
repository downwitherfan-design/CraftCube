# CraftCube v7 — Narrative & Item Architecture Requirements

## Required semantic concepts
StoryChapter, StoryBeat, NarrativeEvent, WorldState, BiomeState, ItemDefinition, EquipmentDefinition, EquipmentEffect, ItemAcquisition, UpgradeDefinition, PuzzleAffinity, DiscoveryDefinition, CompanionReaction, RewardDefinition.

These are semantic requirements only. Reuse existing equivalents when present; do not create duplicate systems.

## Contract rules
Cross-domain references use stable IDs and versioned schemas. Narrative must work against mocked world/puzzle state. Equipment must be testable without final UI/art. UI consumes data through contracts.

## Determinism
Puzzle-driven effects and world changes are deterministic where correctness requires it. Random discovery systems use controlled seeds or auditable state.

## Persistence
Narrative flags, discoveries, item ownership, equipped state, upgrade state and world consequences survive normal restarts and migrations.
