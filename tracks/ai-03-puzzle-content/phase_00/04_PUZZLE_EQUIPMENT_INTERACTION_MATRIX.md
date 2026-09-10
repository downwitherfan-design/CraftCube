# AI-03 Phase 00 — Puzzle-to-Equipment Interaction Matrix

**Status:** PROPOSED (Phase 00 required deliverable: "how equipment may alter strategy without altering puzzle truth";
track deliverable: "Puzzle-to-Equipment Interaction Matrix").
**Inputs (VERIFIED):** `01_PREPRODUCTION/EQUIPMENT_ITEM_MASTER_BIBLE_V7.md` (families, effect classes, balance rule),
`01_PREPRODUCTION/ITEM_CATALOG_STARTER_SET.md` (12 candidates — design seed, not approved content),
`00_CONTROL/V7_DESIGN_DECISION_REGISTER.md` (DD-002, DD-012), `02_ARCHITECTURE/NARRATIVE_EQUIPMENT_SYSTEM_ARCHITECTURE_V7.md`
(effect model: ID, trigger, condition, effect type, parameters, cooldown), `06_CONTRACTS/NARRATIVE_ITEM_CONTRACTS.md`
(`CC.PUZZLE.AFFINITY`, `CC.EQUIPMENT.EFFECT`).

## 1. The one rule

**Invariant P-1 (from `03_LEVEL_GRAMMAR_AND_DIFFICULTY.md`):** `is_satisfied(configuration, objective)` never reads
loadout. Equipment can only act on the four *strategy surfaces* below.

| Surface | What equipment may change | What it may NOT change |
|---|---|---|
| **Information** | what the player can see/know about the configuration or the world | the configuration itself |
| **Legality** | which moves are legal (unlock an axis/layer earlier), *only by relaxing an authored level rule the level explicitly marks as `relaxable`* | the solve predicate; rules marked non-relaxable |
| **Cost** | move-budget cost of specific moves, assist cost | move count as recorded for `mastery.efficiency` (raw moves are always recorded) |
| **World/Discovery** | what world hooks or discoveries become reachable | main-path progression gates |

Everything else — auto-solving, auto-rotating, "skip level", altering tile permutation directly — is forbidden by the
Equipment Bible §Balance rule (VERIFIED) and by this matrix.

## 2. Effect classes mapped to strategy surfaces

Effect classes are the eight listed in `EQUIPMENT_ITEM_MASTER_BIBLE_V7.md` §Equipment effects (VERIFIED). AI-03 assigns
each to permitted surfaces so AI-02 can encode the constraint in `CC.EQUIPMENT.EFFECT` validation.

| Bible effect class | Permitted surfaces | Example (mechanical) | Forbidden form |
|---|---|---|---|
| information | Information | reveal one `veiled` tile's colour per charge | reveal the solution sequence |
| access | Legality, World | unlock a `relaxable` axis lock after the anchor sub-goal | unlock non-relaxable locks |
| interaction | World | make a `seed` tile's world hook fire a secondary node | fire hooks without the objective being true |
| efficiency | Cost | first fracture-cost move per attempt costs 1 instead of 2 | reduce recorded move count |
| risk management | Cost | one budget-exhaustion per attempt does not reset (instead: warning) | unlimited budget |
| exploration | World, Discovery | show Pulse direction toward an undiscovered discovery | mark discovery as found |
| companion synergy | Information, Discovery | companion highlights a tile that participates in the nearest pattern | companion performs moves |
| puzzle strategy | Information, Cost | show move count distance to the *nearest sub-goal* (not the solution) | show optimal move |

## 3. Puzzle-to-Equipment Interaction Matrix (starter candidates)

Rows: the 12 candidates from `ITEM_CATALOG_STARTER_SET.md` (VERIFIED as *design seeds*; AI-01/AI-09 may rename or
reject). Columns: which puzzle element the item touches, which surface it uses, its cost/tension and the P-1 test.
Item IDs shown are **PROPOSED** slugs for fixture use only; canonical `ItemDefinition` IDs are AI-02's.

| Candidate | Puzzle element touched | Strategy surface | Deterministic condition (trigger → effect) | Tension / cost | P-1 holds? | Recorded in solve record as |
|---|---|---|---|---|---|---|
| Memory Lens | `veiled` tiles, `rule.fog` | Information | on activation → reveal colour of up to N veiled tiles for the current attempt | charges per level (N authored, default 3) | Yes — colours were always true; only visibility changes | `equipment_reveals += N` (not an assist) |
| Tuning Fork | `resonant` tiles, `challenge.resonance` | Information | passive → Pulse fires at distance 3 instead of 2 from a pattern | none (passive); occupies Tool slot | Yes — proximity signal only | `pulse_range_bonus = 1` |
| Rootweave Gauntlet | `rule.layer_lock` (relaxable only) | Legality | when anchor sub-goal is ≥ 50 % satisfied → lock relaxes one layer early | one use per attempt | Yes — solve predicate untouched; only legality timing | `rule_relaxations += 1` |
| Ember Dial | `fractured` tiles, `rule.fracture_cost` | Cost | on activation → next 3 fractured-layer moves cost 1 | 1 charge per attempt; Ember Hollow only via affinity | Yes — costs only | `budget_saved += k` |
| Wayfinder Shard | discoveries | World/Discovery | passive → Pulse indicates direction of nearest un-found discovery within the level | occupies Resonator slot (tension with Memory Lens) | Yes — never marks found | `discovery_hint_active = true` |
| Prism Key | `rule.axis_lock` on `relaxable` gates | Legality/World | when a Glassroot `objective.pattern` is satisfied → a world geometry gate unlocks | one-time relic; story-acquired (deterministic) | Yes — access to *world*, not puzzle | world hook only |
| Echo Compass | `objective.sequence` | Information | on activation → shows which completed steps are still holding (green/broken) | charges | Yes — information about the player's own state | `equipment_reveals += 1` |
| Quiet Coil | `rule.move_budget` | Cost/Risk | on budget hitting 0 → one grace reset to last sub-goal instead of full scramble | once per level | Yes — attempt state only | `grace_used = true` |
| Nox Harness | companion, `challenge.companion` | Information/Discovery | companion sense radius +1; highlights a tile in the nearest pattern | Companion Module slot | Yes — highlight ≠ move | `companion_hints += 1` |
| Archive Thread | none (Memory Collectible) | — | none in puzzle | — | N/A | — |
| Lumen Seed | `seed` tile world hook | World | when objective satisfied → grows an *additional* biome node (reward vehicle) | consumed on use | Yes — post-solve only | world hook only |
| Fracture Seal | `rule.fracture_cost` | Risk | on activation → fractured tiles stop costing 2 for 5 moves; afterward 3 for 5 moves | risk/reward swing | Yes — costs only | `budget_saved`, `budget_penalty` |

**Loadout tension check (V7.1 §5.4):** Memory Lens and Wayfinder Shard both target the Resonator slot (per Bible slot
structure, which is itself a Product/UX decision — UNKNOWN final count). Ember Dial and Fracture Seal both target Field
Module. Tuning Fork, Rootweave Gauntlet and Echo Compass compete for Tool. This creates real decisions for the Slice
without needing more items (DD-005 fewer, stronger items).

## 4. Puzzle Affinity (data layer, `CC.PUZZLE.AFFINITY`)

Affinity is *where an effect is allowed to be active*, expressed as data so AI-02 can evaluate it without AI-03 code.
AI-03 proposes the affinity key set:

| Affinity key | Values (from AI-03 vocabulary) | Example |
|---|---|---|
| `objective_family` | `align, pattern, sequence, stabilize, plan, compose` | Echo Compass: `sequence` only |
| `tile_type` | `anchor, resonant, veiled, fractured, seed` | Memory Lens: `veiled` |
| `level_rule` | `axis_lock, layer_lock, fog, fracture_cost, move_budget` | Quiet Coil: `move_budget` |
| `biome` | biome IDs (AI-05/AI-09 canonical; slugs proposed in `05_CHAPTER_ANTI_REPETITION_STRATEGY.md`) | Ember Dial: `ember_hollow` |
| `challenge` | challenge condition IDs | Tuning Fork: `resonance` |

An effect with no matching affinity in the current level is **inert and visibly so** (UX: AI-07). This is the
"Resonance should unlock interactions, not multiply stats" rule from the Equipment Bible (VERIFIED) made testable.

## 5. Mastery interaction (anti-power-creep, V7.1 §7)

- Raw `move_count`, `assist_count` and `solve_duration` are recorded **before** equipment adjustments. Equipment usage
  is recorded alongside, in separate fields (see column "Recorded as").
- `mastery.efficiency` uses raw `move_count`. Equipment cannot inflate it. It *can* help a player *find* an efficient
  solve, which is exactly "changes how I think", not "makes my number bigger".
- `mastery.independence` counts puzzle assists only. Equipment reveals are **not** assists (they are earned
  capabilities), but a T4 mastery variant may declare `equipment_allowed: false`, making it a pure-skill check.
  This is the one place equipment is *excluded*, and it is opt-in per level, never global.
- **Protected mastery levels:** any level tagged `protected_mastery: true` (all T4 variants; the final Test level of each
  chapter) ignores Legality and Cost surfaces entirely. Information and World surfaces remain. This is the concrete
  meaning of "equipment must not remove protected puzzle mastery" (phase prompt).

## 6. Test strategy handed to AI-10 / AI-02

1. **P-1 property test:** for random configurations and all objective instances in fixtures, `is_satisfied` result is
   identical with empty loadout and with every fixture loadout.
2. **Relaxable-only test:** an effect of class `access` applied to a rule with `relaxable: false` must be rejected with a
   stable failure reason (proposed `EffectNotApplicable`; AI-02 to confirm — UNKNOWN whether the error contract will
   accept a new reason).
3. **Raw record test:** `move_count` in the solve record equals the number of `Apply(Move)` calls regardless of loadout.
4. **Protected mastery test:** on `protected_mastery: true` levels, Legality/Cost effects are inert and reported inert.
5. **Determinism test:** identical seed + ruleset + moves + loadout activations ⇒ identical solve record.

## 7. Open items (not guessed)

- Final slot count and slot names — Product/UX decision (Bible states this explicitly). Matrix uses Bible's *suggested*
  four slots as a working assumption, labelled ASSUMED.
- Whether `LockedAxis` covers layer locks or a new reason is needed — AI-02 (UNKNOWN).
- Whether "reveal" should be presented as distinct from "assist" — AI-07 UX; mechanically AI-03 keeps them distinct.
