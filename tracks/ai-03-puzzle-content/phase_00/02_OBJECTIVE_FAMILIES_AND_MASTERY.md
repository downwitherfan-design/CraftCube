# AI-03 Phase 00 — Objective Families, Challenge Conditions & Mastery Dimensions

**Status:** PROPOSED (Phase 00 required deliverable: "first set of puzzle objective families, challenge conditions and
mastery dimensions").
**Inputs (VERIFIED):** `01_PREPRODUCTION/PROGRESSION_AND_MASTERY_BIBLE_V7.md` (challenge types, mastery metrics),
`00_CONTROL/V7_DESIGN_DECISION_REGISTER.md` (DD-001, DD-002, DD-006, DD-012), `01_PREPRODUCTION/WORLD_BIOME_BIBLE_V7.md`
(per-biome puzzle relationship), `01_PREPRODUCTION/QUEST_AND_ACTIVITY_FRAMEWORK.md` (activity quality rule).

## 1. Design principle

An **objective** is a deterministic predicate over a cube configuration. A **challenge condition** is a deterministic
predicate over the *solve record* (moves, time, assists, world state, loadout). A **mastery dimension** is a measured
axis derived from solve records over time.

Three layers, three owners of truth:

```
Objective        -> is_satisfied(configuration)            -> puzzle truth   (AI-02 semantics, AI-03 content)
Challenge        -> is_met(solve_record)                   -> performance    (AI-03 content, AI-02 evaluation)
Mastery          -> aggregate(solve_records) per dimension -> progression    (AI-03 tuning, AI-02 state)
```

Equipment may influence the *solve record* (fewer wasted moves, more information) but can never influence
`is_satisfied` — see `04_PUZZLE_EQUIPMENT_INTERACTION_MATRIX.md` (DD-002).

## 2. Objective families (first set — six)

Each family is one *kind of truth the player must create*. Families are chosen so that each biome's stated puzzle
relationship in the World Bible has a native family, and so that the set stays small enough for mobile legibility
(DD-011 coherence over quantity).

| Family ID | Name | Predicate (informal) | Skill it isolates | Native biome (World Bible, VERIFIED) | Parameters |
|---|---|---|---|---|---|
| `objective.align` | Align | Every tile on the target face(s) matches the face key. | Orientation, basic alignment | Hearthwild | `faces[]` |
| `objective.pattern` | Pattern | The target face(s) match a named pattern mask (ring, cross, checker, diagonal). | Pattern recognition | Glassroot | `faces[]`, `pattern_id` |
| `objective.sequence` | Sequence | Sub-goals must become true in a fixed order; earlier sub-goals must still hold when later ones complete. | Sequencing, controlled restoration | Sunken Grid | `steps[]` (each an objective ref) |
| `objective.stabilize` | Stabilize | All `fractured` tiles are on home faces AND the configuration satisfies a nested objective within a move budget. | Risk/reward under instability | Ember Hollow | `inner` (objective ref), `move_budget` |
| `objective.plan` | Plan | Multiple faces must satisfy patterns *simultaneously* (no intermediate lock-in allowed). | Long-range planning | Verdant Archive | `targets[]` (face+pattern pairs) |
| `objective.compose` | Compose | Two or more prior families must hold on the same configuration, with at least one `anchor` constraint active. | Advanced multi-state interaction | The Quiet/Silent Engine (CONFLICT on name — see vocabulary §8) | `parts[]` (objective refs) |

**Coverage check:** each of the six biomes in `WORLD_BIOME_BIBLE_V7.md` has exactly one native family. No family is
"a harder version of another" — each isolates a different cognitive skill. This is the anti-repetition contract at the
objective level (see `05_CHAPTER_ANTI_REPETITION_STRATEGY.md`).

**Composition rule:** `sequence`, `stabilize`, `plan` and `compose` reference other objectives. Validators must reject
reference cycles and must reject any composite whose parts are jointly unsatisfiable under the level's rules.

**Deferred (not in first set):** timed-decay objectives, adversarial/"collapse pressure" objectives. Source GDD
mentions Bloom/Collapse (VERIFIED in `SOURCE_GDD_NOTES.md` and `TECHNICAL_BLUEPRINT.md`); AI-03 models Collapse as a
**challenge condition / level rule** (move budget, fracture cost), not as a separate objective family, to avoid a
duplicate semantic system. If Product/AI-02 decides Collapse is a first-class domain state, AI-03 will map to it.

## 3. Challenge conditions (first set — eight)

Mapped one-to-one onto the eight challenge types in `PROGRESSION_AND_MASTERY_BIBLE_V7.md` §Challenge types (VERIFIED)
so no second taxonomy is created.

| Condition ID | Bible challenge type | Deterministic predicate over solve record | Inputs required | Notes |
|---|---|---|---|---|
| `challenge.standard` | Standard solve | `objective_satisfied == true` | configuration | Always present; the baseline. |
| `challenge.limited_assist` | Limited assistance | `assist_count <= max_assists` | assist log | `max_assists` = 0 is "assist-free". |
| `challenge.move_efficiency` | Move efficiency | `move_count <= par_moves + tolerance` | move log | `par_moves` authored per level; validator checks par is achievable (solver-verified in Phase 03; in Phase 00 it is an authored claim marked UNVERIFIED). |
| `challenge.time` | Time challenge | `solve_duration_ms <= time_budget_ms` | timestamps | Uses simulation ticks, not wall-clock, for determinism/replay. Never mandatory for story progression (DD-006). |
| `challenge.world_state` | World-state challenge | `world_state[flag] == expected` at solve time | WorldState (AI-02) | e.g. "solve while the channel is flooded". |
| `challenge.resonance` | Resonance challenge | `resonant_tiles_home_at_solve >= n` OR `pulse_streak >= n` | tile states, pulse log | Connects to `CC.PUZZLE.AFFINITY`; equipment can make resonance *visible*, not *true*. |
| `challenge.discovery` | Discovery challenge | `discovery_id in discoveries_unlocked_during_solve` | discovery ledger | Solve *and* find. |
| `challenge.companion` | Companion challenge | `companion_reaction_id fired during solve` AND objective satisfied | CompanionReaction (AI-06) | Companion presence/bond may gate; never blocks main path. |

**Rule:** A level's *primary* objective must be completable with `challenge.standard` alone. Every other condition is
optional and rewards mastery; none gates critical story progression (DD-006, Progression Bible §Revisit design).

## 4. Mastery dimensions (first set — six)

Mapped onto the six mastery metrics in `PROGRESSION_AND_MASTERY_BIBLE_V7.md` §Mastery metrics (VERIFIED). Each is a
separately stored, separately presented measure; the Bible forbids collapsing them into one score.

| Dimension ID | Bible metric | Unit | Aggregation | Player-facing intent |
|---|---|---|---|---|
| `mastery.completion` | completion | count of levels solved / total | per chapter | "I finished it." |
| `mastery.efficiency` | move efficiency | best `move_count / par_moves` ratio | best-of per level, mean per chapter | "I solved it elegantly." |
| `mastery.independence` | optional assist usage | best solve `assist_count` | min per level | "I did it myself." |
| `mastery.consistency` | solve consistency | rolling success rate on seeded variants | last N seeded attempts | "I can do it again." |
| `mastery.challenge` | challenge completion | challenge conditions met / available | per chapter | "I beat the hard version." |
| `mastery.discovery` | discovery completion | discoveries found / available | per chapter | "I found what was hidden." |

**Anti-grind rule (V7.1 §6, DD-014):** no dimension is ever *required* to advance the main story. Dimensions unlock
optional content: challenge variants, discovery routes, cosmetic/expression rewards, and Tier 4 "mastered" biome states
(World Bible §Biome transformation tiers).

**Accessibility note (V7.1 §9):** `mastery.efficiency` and `mastery.independence` must not penalise accessibility
assists (larger targets, motion reduction, colour indicators). Only *puzzle* assists (hint step, ghost preview, trail,
undo) count toward `assist_count`. AI-07 owns the assist UI; AI-03 owns which assists are puzzle-assists.

## 5. Save/persistence implications (for AI-02 SaveSchema)

AI-03 requires the following to be persisted per profile (fields are *requested*, names are DRAFT):

- per level: best `move_count`, min `assist_count`, challenge conditions met (set of IDs), solved flag
- per chapter: discoveries unlocked (set of IDs), rewards granted (set of IDs — idempotency guard)
- per seeded challenge: `seed`, `ruleset_version`, result (for `mastery.consistency`)

All are additive, append-only sets or monotone bests — no destructive migration is implied.

## 6. Acceptance checks for this deliverable

- [x] Every biome in the World Bible has exactly one native objective family.
- [x] Every challenge type in the Progression Bible has exactly one challenge condition ID (no orphan, no duplicate).
- [x] Every mastery metric in the Progression Bible has exactly one mastery dimension ID.
- [x] No condition or dimension gates critical progression.
- [x] Every predicate is deterministic and depends only on simulation data (no wall-clock, no randomness).
- [ ] `par_moves` achievability — **UNVERIFIED until Phase 03 solver exists** (recorded as a known limitation).
