# CraftCube v7 — Equipment & Item Master Bible

## Design target

The ideal item causes the player to say:

**"This lets me think/play differently."**

not:

**"My number is bigger."**

## Item families

### 1. Relics
Story-important objects tied to the history of the Loom.

### 2. Tools
Direct interaction utilities for traversal, scanning, stabilizing or manipulating the environment.

### 3. Resonators
Items that interact with puzzle states, biome states or special world conditions.

### 4. Companion Gear
Items that change what a companion can sense, reveal or interact with.

### 5. Field Modules
Limited-use tools for exploration and controlled world manipulation.

### 6. Memory Collectibles
Lore-rich objects primarily for collection and world history.

## Item rarity philosophy

Use narrative/functional rarity, not arbitrary color inflation.

Suggested tiers:
- Utility
- Named
- Relic
- Mastery

## Equipment slots

Keep the active loadout small enough for mobile clarity.

Suggested structure:
- Core Resonator
- Tool
- Companion Module
- Field Module

Exact slot count is a Product/UX decision and must be validated in the Vertical Slice.

## Equipment effects

Effects should fall into one or more of:
- information,
- access,
- interaction,
- efficiency,
- risk management,
- exploration,
- companion synergy,
- puzzle strategy.

## Upgrade system

Avoid endless level numbers.

Use **meaningful branches** such as:
- Precision
- Versatility
- Efficiency
- Discovery

A branch must create a real behavioral difference.

## Resonance system

Certain equipment can resonate with compatible:
- puzzle states,
- biomes,
- companion traits,
- world conditions.

Resonance should unlock interactions, not simply multiply damage/stat values.

## Set synergy

A small number of named combinations may produce a special interaction.

Example design pattern:
`Crystal Resonator + Memory Lens -> reconstruct a hidden prior state`

This is an example pattern, not locked content.

## Durability

Do not use durability merely to punish the player.
Use charge/cooldown/resource limits only when they create interesting decisions.

## Crafting

Crafting is optional and should remain lightweight.

Material collection must come from meaningful play, not repetitive farming.

## Item acquisition

Preferred sources:
- story milestone,
- puzzle mastery,
- exploration,
- optional secret,
- companion event,
- deterministic challenge reward.

Avoid mandatory progression that depends on random drops.

## Item memory

Important items may remember contextual data such as:
- first discovery location,
- first use,
- related world event,
- companion reaction,
- chapter of acquisition.

This data exists primarily to increase attachment and collection value.

## Example item concepts

### Memory Lens
Reveals echoes of previous world states.

### Tuning Fork
Responds to compatible resonance patterns and identifies hidden interactions.

### Rootweave Gauntlet
Allows controlled interaction with living structures.

### Ember Dial
Temporarily stabilizes or redirects unstable heat channels.

### Wayfinder Shard
Reveals a short route toward an unresolved discovery without directly solving the puzzle.

These are canonical design candidates and may be changed by AI-01/AI-09 during Phase 00.

## Balance rule

No item may:
- directly auto-solve a core puzzle,
- erase the need for observation,
- trivialize mastery challenges,
- become a mandatory equipment check,
- create runaway stat scaling.
