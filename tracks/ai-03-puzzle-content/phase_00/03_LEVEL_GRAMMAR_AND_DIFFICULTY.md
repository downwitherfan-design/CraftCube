# AI-03 Phase 00 — Level Grammar & Difficulty Model

**Status:** PROPOSED. Defines *how a level is composed* and *how difficulty is reasoned about* so that Phase 01 can
freeze a level schema and Phase 07 can build authoring tools without inventing structure later.
**Inputs (VERIFIED):** `02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md` (Domain modules, determinism, `rulesetVersion`),
`06_CONTRACTS/CONTRACT_FIRST_RULES.md` (`IPuzzleEngine`, schema versioning), `06_CONTRACTS/INTERACTION_CONTRACTS.md`
(`InvalidMove`, `LockedAxis`, `ContentNotFound`), `01_PREPRODUCTION/PROGRESSION_AND_MASTERY_BIBLE_V7.md` (difficulty
curve), `00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md` §9 (accessibility), §14 (first-session target).

## 1. Level grammar (what a level *is*)

A level is data, never code (`INTERACTION_CONTRACTS.md` §Content contract). Grammar in EBNF-style prose:

```
Level        := Identity Topology Scramble Objective LevelRule* ChallengeCondition* Hooks Difficulty
Identity     := level_id chapter_id ordinal signature_ref
Topology     := topology_id                      (e.g. cube 2x2x2 / 3x3x3; owner AI-02 PuzzleTopology)
Scramble     := seed ruleset_version              (deterministic; ScrambleGenerator owner AI-02)
Objective    := one objective family instance     (see 02_OBJECTIVE_FAMILIES_AND_MASTERY.md)
LevelRule    := axis_lock | layer_lock | fog | fracture_cost | move_budget | tile_placement
Challenge    := condition_id + parameters         (optional; never gates story)
Hooks        := world_hook* reward_ref* discovery_ref*
Difficulty   := authored tier + derived metrics   (see §3)
```

### 1.1 Identity

- `level_id`: `level.<chapter_nn>.<slug>` — semantic, immutable once RELEASED (`EVENT_AND_ID_POLICY.md`).
- `chapter_id`: `chapter.<nn>.<slug>` — style matches the existing example `chapter.01.meadow` in
  `01_GOVERNANCE/MULTI_AI_OPERATING_MODEL.md` (VERIFIED). AI-03 does **not** reuse `meadow`; that was an illustrative
  example, and the Story Bible's chapter 1 is "First Light" in the Hearthwild.
- `ordinal`: position inside the chapter (authoring aid; not an identity).
- `signature_ref`: the chapter signature this level teaches, practices or tests (`introduce | practice | twist | test`).

### 1.2 Topology

Phase 00 names only two topologies and requests AI-02 to own their definition:

| topology_id | Use | Rationale |
|---|---|---|
| `topology.cube.2` | Chapter 01 onboarding, first 10 minutes | V7.1 §14 first-session target: minimal state, maximal legibility on a phone. |
| `topology.cube.3` | Chapters 02+ | Standard depth; enough state for all six objective families. |

Larger or non-cubic topologies are **Later** on the cut list until the Vertical Slice proves the 3-layer cube on touch.

### 1.3 Level rules (change legality/information, never truth)

| Rule ID | Effect on `GetLegalMoves()` / information | Existing error reason it produces | Teaches |
|---|---|---|---|
| `rule.axis_lock` | Moves on axis A are illegal for the level (or until a sub-goal holds). | `LockedAxis` (VERIFIED existing) | Working within constraints |
| `rule.layer_lock` | Moves on layer L are illegal while an `anchor` tile is off-home. | `LockedAxis` (proposed reuse — AI-02 to confirm or add `LockedLayer`; **UNKNOWN**) | Ordering |
| `rule.fog` | `veiled` tiles hide colour until moved once or revealed by Memory-class equipment. | none (information only) | Inference under uncertainty |
| `rule.fracture_cost` | Layers containing off-home `fractured` tiles cost 2 budget per move. | none (budget) | Risk management |
| `rule.move_budget` | Solve must complete within N budget units or the attempt resets to scramble (no punishment beyond retry). | none (attempt state) | Planning under pressure |
| `rule.tile_placement` | Declares positions of non-standard tile types. | validator-only | (enabler for the above) |

**Invariant P-1 (puzzle truth):** For any configuration `c` and objective `o`, `is_satisfied(c, o)` is independent of
every level rule, every equipment effect and every assist. Rules and effects may only change the set of legal moves,
the cost of moves, or what information the player sees. This invariant is testable and is the contract AI-03 hands to
AI-02 and AI-10.

**Invariant P-2 (reachability):** Every authored level must be solvable from its scramble using only legal moves under
its own rules, without any equipment, with `assist_count = 0`. Validators enforce this in Phase 03 via solver; in
Phase 00 the fixture field `reachability_verified` is `false` and clearly labelled.

### 1.4 Hooks

- `world_hook`: `WorldStateEvent` trigger emitted on objective satisfaction or on sub-goal satisfaction. AI-03 names the
  trigger (`on_objective_satisfied`, `on_step_satisfied`, `on_seed_tile_home`); AI-02/AI-13 own the event contract.
- `reward_ref`: `reward.<chapter>.<slug>` with a `reward_condition` (see `06_PUZZLE_REWARD_AND_DISCOVERY_MATRIX.md`).
- `discovery_ref`: `discovery.<chapter>.<slug>` with a `trigger_condition`.

## 2. Difficulty philosophy

`PROGRESSION_AND_MASTERY_BIBLE_V7.md` §Difficulty curve (VERIFIED): "Difficulty should primarily increase through
understanding and decision quality before raw speed." AI-03 therefore models difficulty on **four independent
pressures**, ordered by the sequence in which they are allowed to appear:

| Pressure | Source | First allowed chapter | Never used for |
|---|---|---|---|
| **Understanding** | new objective family, new tile type, new rule | 01 | — |
| **Decision** | ordering constraints (anchor/layer lock, sequence), composite objectives | 02 | — |
| **Information** | fog/veiled tiles, hidden patterns | 04 | onboarding |
| **Pressure** | move budget, fracture cost, time challenge | 06 (budget), never mandatory (time) | main story gating |

A level may combine pressures; a chapter may not introduce more than **one new pressure source** and **one new
signature** at once (V7.1 §16 complexity budget).

## 3. Difficulty tiers and metrics

### 3.1 Authored tier (design intent)

| Tier | Name | Intended solve for a player who has completed prior chapter | Signature role |
|---|---|---|---|
| T0 | Teach | ≤ 2 minutes, no failure state | `introduce` |
| T1 | Practice | 2–5 minutes, ≤ 1 retry expected | `practice` |
| T2 | Twist | 5–10 minutes, decision-heavy | `twist` |
| T3 | Test | 10+ minutes or challenge-gated; optional | `test` |
| T4 | Mastery variant | seeded, deterministic, optional; `mastery.*` rewards | endgame layer (Progression Bible §Endgame) |

Tier is an authored *claim*. Playtest data in Phase 06/15 replaces claims with measurements; the field stays so the
authoring tool can compare intent vs. evidence.

### 3.2 Derived metrics (computed, never hand-typed)

| Metric | Derivation | Owner of computation |
|---|---|---|
| `scramble_depth` | minimal move count from solved to scramble under ruleset | AI-02 solver (Phase 03); UNKNOWN in Phase 00 |
| `par_moves` | optimal or near-optimal solve length under level rules | AI-02 solver; authored placeholder in Phase 00 marked `par_source: "authored_unverified"` |
| `rule_load` | count of active level rules | validator (trivial, Phase 00) |
| `information_ratio` | veiled tiles / total tiles | validator (trivial, Phase 00) |
| `composite_depth` | nesting depth of objective references | validator (trivial, Phase 00) |

The Phase 00 validator computes the three trivial metrics so downstream tracks have real numbers, and refuses to
fabricate the two solver-dependent ones.

## 4. Chapter difficulty shape (anti-frustration, anti-grind)

Within a chapter, tiers must follow the grammar `T0 T1+ T2+ [T3] [T4*]` — every chapter opens with a Teach level, has at
least one Practice and one Twist, and Test/Mastery are optional. Validators enforce the shape.

Across chapters, the *first* level of chapter N+1 must be no harder than the *last Practice* level of chapter N
(understanding pressure resets when a new signature is introduced). This prevents difficulty cliffs at biome
transitions — the moment the World Bible says a new "expression of the puzzle/world relationship" begins.

## 5. Accessibility, localization, performance, recovery implications

- **Accessibility:** colour is never the *only* channel for a tile type or pattern — every tile type has a shape/glyph
  identity requirement passed to AI-05/AI-06/AI-07 (V7.1 §9 "optional visual indicators for color-dependent mechanics").
  `rule.fog` must remain legible under colour-blind modes because veiled state is shape-based, not colour-based.
- **Localization:** levels carry no player-facing strings. Names come from `LocalizationKey` (AI-09) via
  `title_key`/`hint_key` fields that reference keys; AI-03 never embeds text.
- **Performance:** a 3x3x3 configuration is 54 tiles; objective predicates are O(tiles). No level rule requires search at
  runtime. Solver-backed metrics are offline/authoring-time only (AI-11 budget note).
- **Recovery:** `rule.move_budget` exhaustion resets the *attempt*, never chapter/world state. Interruption mid-solve
  resumes from the last committed move (save-safe: solve record is append-only).

## 6. Cut list (Phase 00 scope discipline)

| Item | Decision | Reason |
|---|---|---|
| Non-cubic topologies | Later | unproven on touch; Slice first |
| Real-time timed main-path levels | Reject | DD-006 / Progression Bible: speed is optional mastery |
| Randomised objectives at runtime | Reject | determinism; QUEST_DISCOVERY_BIBLE §Replayability |
| Procedural infinite levels | Later (seeded T4 only) | Progression Bible §Endgame "deterministic challenge seeds" |
| Adversarial Collapse as objective family | Deferred → challenge/rule | avoid duplicate semantic system pending AI-02 domain decision |
