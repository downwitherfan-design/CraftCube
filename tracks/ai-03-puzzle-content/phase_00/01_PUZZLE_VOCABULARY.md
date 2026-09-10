# AI-03 Phase 00 — Puzzle Vocabulary & IP-Safe Terminology

**Status:** PROPOSED (Phase 00 design lock candidate). Terminology ownership is AI-09; this document proposes the
*mechanical* vocabulary AI-03 needs and flags every term AI-09 should confirm, rename or reject.
**Inputs (VERIFIED):** `00_CONTROL/CRAFTCUBE_GAME_MASTER_BIBLE.md`, `01_PREPRODUCTION/STORY_BIBLE_V7.md`,
`01_PREPRODUCTION/WORLD_BIOME_BIBLE_V7.md`, `02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md`,
`06_CONTRACTS/INTERACTION_CONTRACTS.md`, `10_SOURCE_REFERENCE/SOURCE_GDD_NOTES.md`.

## 1. Purpose

Thirteen tracks will name the same puzzle concepts in code, UI, audio cues, narrative and tests. If the vocabulary is not
locked in Phase 00, duplicate semantic systems appear in Phase 01. This document gives every puzzle concept one
canonical name, one meaning and one owner, and separates **mechanical truth terms** (AI-02/AI-03) from
**player-facing fiction terms** (AI-09).

## 2. IP-safety rule applied

`10_SOURCE_REFERENCE/SOURCE_GDD_NOTES.md` (VERIFIED) records that the source GDD used Minecraft-specific names and
presentation. AI-03 keeps the *mechanical ideas* (twisting cube, Bloom/Collapse, special tiles, assist, pulse/trail)
and never uses proprietary block, creature, item or UI names. The vocabulary below contains no term from any
third-party game. Standard twisting-puzzle mathematics terms (face, layer, slice, permutation, orientation, parity,
scramble) are generic and unowned.

## 3. Core mechanical vocabulary (truth layer — AI-02 owns semantics, AI-03 owns content usage)

| Term | Canonical meaning | Notes |
|---|---|---|
| **Cube** | The twisting puzzle object the player manipulates. Topology is defined per level (`topology_id`). | Fiction name proposed for AI-09: "Loom Cube" (derived from Axis Loom, Game Master Bible §6). |
| **Face** | One of the six outer sides of the cube. Stable face keys: `U`, `D`, `L`, `R`, `F`, `B`. | Standard notation; generic. |
| **Layer** | A rotatable slab of the cube parallel to a face. | Depth index from the face (0 = outer). |
| **Move** | One quarter-turn (or half-turn where the topology allows) of one layer around one axis. | The atomic unit of `Move` in `IPuzzleEngine.Apply(Move)` (`06_CONTRACTS/CONTRACT_FIRST_RULES.md`, VERIFIED example interface). |
| **Axis** | One of three rotation axes: `X`, `Y`, `Z`. | `LockedAxis` is an existing stable error reason (`INTERACTION_CONTRACTS.md`, VERIFIED). |
| **Tile** | One coloured/typed sticker on one cubie face. Carries `tile_type`. | The Technical Blueprint calls the view `Sticker/TileView`; "Tile" is the domain word. |
| **Tile Type** | The class of a tile: `standard`, `anchor`, `resonant`, `veiled`, `fractured`, `seed`. | Special tiles from the source GDD, renamed IP-safe. See §5. |
| **Configuration** | The complete permutation+orientation state of all tiles at an instant. | Equivalent to `PuzzleState` in the register. |
| **Pattern** | A named target predicate over a configuration (e.g. "face U solid", "ring on F"). | Patterns are the vocabulary of objectives; never a hard-coded switch. |
| **Scramble** | Deterministic initial configuration produced by `ScrambleGenerator(seed, ruleset_version)`. | Same seed + same ruleset + same moves ⇒ same result (Technical Blueprint §Determinism, VERIFIED). |
| **Ruleset Version** | The version of move/topology/tile rules. Stored with every replay and seeded challenge. | `rulesetVersion` already named in Technical Blueprint (VERIFIED). |
| **Legal Move** | A move permitted by the current level rules (axis locks, layer locks, fractured tiles). | Returned by `GetLegalMoves()`. |
| **Solve Predicate** | The deterministic function `is_satisfied(configuration, objective)`. | Puzzle truth. Equipment never alters it (DD-002). |
| **Parity** | Mathematical solvability class of a configuration. | Every scramble must be reachable-to-solved under the level rules; validator concern. |

## 4. Content vocabulary (AI-03 owns)

| Term | Meaning |
|---|---|
| **Objective** | What the player must make true. Belongs to exactly one **Objective Family** (see `02_OBJECTIVE_FAMILIES_AND_MASTERY.md`). |
| **Level** | One authored puzzle instance: topology + scramble seed + objective(s) + level rules + challenge conditions + reward/discovery references. Stable ID `level.<chapter>.<slug>`. |
| **Level Rule** | A constraint on legal moves or information (axis lock, layer lock, fog, fracture, move budget). Rules change *what is legal*, never *what is true*. |
| **Challenge Condition** | An optional performance constraint evaluated after solve (move efficiency, time, assist-free, world-state, resonance, discovery, companion). Mirrors the eight challenge types in `PROGRESSION_AND_MASTERY_BIBLE_V7.md` (VERIFIED). |
| **Mastery Dimension** | A measurable axis of player skill (`03_LEVEL_GRAMMAR_AND_DIFFICULTY.md`). Never collapsed into one score (Progression Bible §Mastery metrics, VERIFIED). |
| **Chapter** | An authored sequence of levels with one **Signature** (mechanical reason to exist), one biome and one narrative theme. Stable ID `chapter.<nn>.<slug>`. |
| **Signature** | The single new puzzle idea a chapter introduces. A chapter without a signature is rejected (anti-repetition rule). |
| **Assist** | Optional, player-invoked help (highlight, undo, ghost preview, hint step). Assist usage is a mastery dimension; it is never silent. Source-GDD term "Smart Assist" is retained only as a design reference, not as a player-facing name. |
| **Pulse** | A rhythmic world/cube feedback signal tied to puzzle state proximity (source-GDD "Cube Pulse"). Presentation is AI-04/05/06/08; the *condition* that fires it is AI-03 content. |
| **Trail** | An optional visual hint path (source-GDD "Golden Trail"). Player-facing name is AI-09's; mechanically it is an assist with cost. |
| **Discovery** | An optional, deterministic, save-persisted find with an explicit `trigger_condition`. Stable ID `discovery.<chapter>.<slug>`. |
| **Reward** | A deterministic grant issued when a `reward_condition` becomes true. Stable ID `reward.<chapter>.<slug>`. Reward classes follow the Progression Bible hierarchy. |
| **World Hook** | The event the puzzle emits so the world can respond (`WorldStateEvent`, owner AI-13 governance + AI-02 domain). AI-03 names the *trigger*, not the presentation. |

## 5. Tile types (special pieces) — IP-safe renaming

The source GDD includes "special pieces/tiles" (VERIFIED in `SOURCE_GDD_NOTES.md`; specifics UNKNOWN because the
source ZIP is not in the repository). AI-03 proposes the following minimal, mechanically distinct set. Each one changes
*legality or information*, never the solve predicate.

| Tile type ID | Mechanical effect | Why it exists (player-facing purpose) | Introduced in chapter |
|---|---|---|---|
| `standard` | None. | Baseline. | 01 |
| `anchor` | The layer containing this tile cannot rotate while the anchor is not on its home face. | Teaches planning order; makes "which layer first" a decision. | 02 |
| `resonant` | Emits a Pulse when its layer is within N moves of a pattern; participates in Resonance challenge conditions. | Makes proximity legible; links puzzle to world/equipment resonance without solving. | 03 |
| `veiled` | Colour is hidden until the tile has been moved once or a Memory-class equipment reveals it. | Information puzzle; equipment can reveal but not solve. | 04 |
| `fractured` | The tile's layer costs 2 move-budget instead of 1 while the tile is off-home; on-home it heals. | Risk/reward; Ember Hollow identity. | 06 |
| `seed` | When its face pattern completes, emits a World Hook that grows a biome node. | Direct puzzle→world causality; reward vehicle. | 01 (single seed), expanded later |

**Rule:** No tile type may change the mathematical solvability of a configuration. Validators reject any level whose
tile-type placement makes the objective unreachable under its own level rules.

## 6. Terms proposed to AI-09 for confirmation (player-facing layer)

| Mechanical term | Proposed fiction name | Rationale |
|---|---|---|
| Cube | Loom Cube | Ties to Axis Loom (Game Master Bible §6) |
| Solve Predicate satisfied | Alignment | Echoes Great Misalignment; opposite state |
| Pattern | Weave | Player is a Weaver (Story Bible) |
| Seed tile | Lumen tile | Aligns with "Lumen Seed" relic candidate in `ITEM_CATALOG_STARTER_SET.md` |
| World Hook fired | The world answers | Game Master Bible §2 core fantasy |
| Discovery | Echo | World-memory theme, Glassroot |

AI-03 uses the **mechanical** column in all IDs and fixtures. AI-09 may change the fiction column without breaking any
AI-03 artifact — which is the reason the two layers are separated.

## 7. Terms explicitly NOT used

- Any proprietary block, mob, biome, tool or UI name from third-party games.
- "Level number" as a player-facing identity — chapters are named places, not numbers (Game Master Bible §12 non-goals: not a menu-heavy collection game).
- "XP", "DPS", "loot", "grind" — excluded by the Progression Bible and DD-005/DD-014.

## 8. Conflicts recorded (for AI-09/AI-13, not resolved here)

- `STORY_BIBLE_V7.md` chapter 7 is "The Silent Engine"; `WORLD_BIOME_BIBLE_V7.md` biome 6 is "The Quiet Engine";
  `ITEM_CATALOG_STARTER_SET.md` references "the Quiet Engine". **CONFLICT** — AI-03 fixtures use the neutral slug
  `engine` until AI-09 decides.
- Story Bible has 10 chapters; World Bible has 6 biomes; chapters 8–10 have no biome. **UNKNOWN** — AI-03 maps
  chapters 1–7 only in Phase 00 and proposes candidates for 8–10 without asserting them.
