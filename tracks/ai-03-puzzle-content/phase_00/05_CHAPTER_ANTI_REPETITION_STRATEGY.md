# AI-03 Phase 00 — Chapter Anti-Repetition Strategy & Chapter Signature Matrix

**Status:** PROPOSED (Phase 00 required deliverable: "anti-repetition strategy for chapters"; phase rule: "Every puzzle
chapter must have a distinct gameplay reason to exist").
**Inputs (VERIFIED):** `01_PREPRODUCTION/STORY_BIBLE_V7.md` (10 chapter themes in 3 acts), `01_PREPRODUCTION/WORLD_BIOME_BIBLE_V7.md`
(6 biomes with puzzle relationships), `01_PREPRODUCTION/CRAFTCUBE_WORLDCLASS_CONTENT_RULES.md` ("fewer but memorable"),
`00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md` §3 (every chapter: emotional objective, gameplay objective, visual
transformation, question introduced/advanced, memorable scene), §16 (complexity budget).

## 1. The anti-repetition rule (enforceable)

A chapter is accepted only if **all five** hold, and the validator can check the first four mechanically:

| # | Rule | Mechanical check |
|---|---|---|
| R1 | **One new Signature.** The chapter introduces exactly one puzzle idea (objective family, tile type, or level rule) not present in any earlier chapter. | `signature.introduces` ∉ union of earlier chapters' signatures |
| R2 | **No family monoculture.** No two consecutive chapters share the same *primary* objective family. | `primary_family[n] != primary_family[n-1]` |
| R3 | **Recombination, not repetition.** Each chapter after the first must *reuse* at least one earlier signature in a new combination (so the language grows rather than resets). | `signature.recombines` ⊆ earlier signatures, non-empty for n>1 |
| R4 | **Bounded novelty.** A chapter introduces ≤ 1 new objective family, ≤ 1 new tile type, ≤ 1 new level rule (complexity budget). | counts on `introduces` |
| R5 | **Distinct world verb.** The chapter's world response is a different *verb* from the previous chapter (grow, remember, reconnect, redirect, encode, rearrange, …). | authored; AI-05/AI-09 review (not machine-checkable in Phase 00) |

And the world-class question (V7.1 §18) is asked per chapter in the matrix column "Why the player remembers it".

## 2. Chapter Signature Matrix — Act I & Act II (chapters 1–7, biome-mapped)

Chapter and biome names are from the Story/World Bibles (VERIFIED). Slugs are AI-03 PROPOSED IDs for fixtures.
Signatures reference the AI-03 vocabulary (`01_PUZZLE_VOCABULARY.md`, `02_OBJECTIVE_FAMILIES_AND_MASTERY.md`).

| Ch | Story Bible theme | Biome (World Bible) | Chapter ID (PROPOSED) | Primary family | Signature INTRODUCES | RECOMBINES | World verb | Story question it serves | Why the player remembers it |
|---|---|---|---|---|---|---|---|---|---|
| 01 | First Light | Hearthwild | `chapter.01.first_light` | `align` | topology `cube.2`, tile `seed`, family `align` (baseline set — R4 exempt as the origin chapter) | — | **grow** (paths, water, plants) | "Why does the world react to my hands?" (setup) | The very first solve visibly wakes a dead mechanism; the cube is small enough to *understand* in 10 minutes (V7.1 §14). |
| 02 | The Broken Path | Hearthwild | `chapter.02.broken_path` | `align` → `sequence`-lite via anchors | tile `anchor` + `rule.layer_lock` | `align`, `seed` | **reconnect** (a route) | reinforcement: solving *orders* the world | First time the *order* of actions matters; the path assembles segment by segment as anchors go home. |
| 03 | Echoes in Stone | Hearthwild edge → Glassroot threshold | `chapter.03.echoes_in_stone` | `pattern` | family `pattern`, tile `resonant` (Pulse) | `align`, `anchor` | **remember** (first artifact record) | "What happened?" (first artifact) | The cube hums when close to a shape you have not yet seen — the Pulse teaches "I am near". |
| 04 | Glassroot | Glassroot | `chapter.04.glassroot` | `pattern` | tile `veiled` + `rule.fog` | `pattern`, `resonant` | **reveal** (crystal shows prior states, hidden routes) | "Was the Misalignment an accident?" (world memory) | Solving in the dark by inference; Memory Lens becomes a *choice*, not a crutch. |
| 05 | The Sunken Grid | Sunken Grid | `chapter.05.sunken_grid` | `sequence` | family `sequence` | `anchor`, `veiled` | **reconnect** (pumps, bridges, light networks) — R5 vs ch.04 OK; note ch.02 also "reconnect" but non-consecutive | contradictions in records | Earlier steps must *stay* true — the flooded ruin punishes undoing your own work. |
| 06 | Ember Hollow | Ember Hollow | `chapter.06.ember_hollow` | `stabilize` | family `stabilize`, tile `fractured`, `rule.fracture_cost`, `rule.move_budget` — **R4 breach: 1 family + 1 tile + 2 rules** → resolved by introducing `move_budget` as a *challenge condition only* in ch.06 and as a level rule in ch.07 | `sequence`, `resonant` | **redirect** (heat channels, temporary routes) | instability is useful | The first level where a wrong move *costs* something and the world briefly opens because of it. |
| 07 | The Silent/Quiet Engine (**CONFLICT** name — AI-09) | The Quiet Engine | `chapter.07.engine` | `compose` | family `compose`, `rule.move_budget` as level rule | `pattern`, `stabilize`, `anchor` | **rearrange** (architecture moves around solved configurations) | "first direct evidence of deliberate design" | Architecture literally re-forms around your solution — the strongest puzzle→world causality beat in Act II. |

**R2 check:** align, align→(anchored), pattern, pattern, sequence, stabilize, compose. Chapters 01–02 share `align` and
03–04 share `pattern`. R2 is therefore **satisfied only if** the "primary family" of ch.02 is recorded as `align+anchor`
and of ch.04 as `pattern+fog`. AI-03 makes this explicit rather than hide it: R2 is refined to *"no two consecutive
chapters share the same (primary family, signature) pair"*, which the validator implements. This is a deliberate
design choice — Act I teaches by *deepening* one family before switching — and it is recorded as **DECISION REQUEST
AI03-D1** for Product (see `08_OPEN_DECISIONS_AND_CONFLICTS.md`).

## 3. Act III (chapters 8–10) — proposed, NOT mapped

`STORY_BIBLE_V7.md` gives themes for chapters 8–10 (The Unfinished Pattern, The Last Alignment, A World Rewritten).
`WORLD_BIOME_BIBLE_V7.md` lists Verdant Archive (`plan` family native) as biome 5 but **no chapter is assigned to it**,
and no biome is assigned to chapters 8–10. **UNKNOWN.** AI-03 records candidates only:

| Ch | Theme | Candidate signature | Candidate biome | Status |
|---|---|---|---|---|
| 08 | The Unfinished Pattern | family `plan` (simultaneous multi-face) | Verdant Archive | PROPOSED — fits "mastery without certainty" and the Archive's "long-range pattern planning" |
| 09 | The Last Alignment | no new family; recombination-only chapter (`compose` + `plan` + `stabilize`), T3/T4-heavy | revisits across biomes (world-memory payoff) | PROPOSED — R1 would be satisfied by a new *level rule* (`rule.axis_lock` conditional on world state) rather than a family |
| 10 | A World Rewritten | finale; player-chosen objective family for the last solve (scoped choice, DD-008) | The Quiet Engine / Loom core | PROPOSED — mechanical form of "should the world be restored exactly as it was?" |

These are not fixtures and carry no IDs until AI-01/AI-09 map biomes to Act III.

## 4. Within-chapter anti-repetition (level level)

Each chapter follows the tier grammar `T0 T1+ T2+ [T3] [T4*]` (`03_LEVEL_GRAMMAR_AND_DIFFICULTY.md` §4) with these
additional rules:

- No two levels in a chapter share the identical tuple (objective instance, rule set, tile placement). Validator check.
- At least one level per chapter has `signature_ref: "twist"` — the signature used in an unexpected way (e.g. ch.02: an
  anchor that must be *moved away* first).
- Optional T3/T4 levels never duplicate a T0–T2 scramble seed (seeded variants use a distinct seed range per tier).

## 5. Replayability without repetition (V7.1 role priority: replayability, anti-grind)

Replay value comes from **state-based** and **seed-based** sources, never from replaying the same level for currency:

| Source | Mechanism | Deterministic? | Gated by |
|---|---|---|---|
| Challenge variants | same level, extra challenge condition(s) | Yes | none (optional) |
| Seeded mastery variants (T4) | same objective/rules, `seed` from a per-level deterministic range | Yes (`seed`, `ruleset_version`) | chapter completion |
| World-state revisit | a level's `challenge.world_state` becomes satisfiable only after a later chapter changes the world | Yes | world flag |
| Equipment-revealed discovery | `veiled`/Pulse discoveries reachable with Memory/Wayfinder class equipment | Yes | equipment (optional) |
| Companion revisit | `challenge.companion` after bond unlock | Yes | bond flag (optional) |

**Forbidden:** repeat-to-farm, daily-login-gated puzzle content, RNG loot on replay (Quest/Discovery Bible §Replayability,
DD-009, DD-014 — all VERIFIED).

## 6. Acceptance for this deliverable

- [x] Every chapter 1–7 has exactly one Signature and a distinct "why it exists".
- [x] R1–R4 are machine-checkable and encoded in the Phase 00 validator against the chapter fixture.
- [x] R2 refinement is recorded as a Product decision request, not silently adopted.
- [x] Act III is explicitly UNKNOWN/PROPOSED, not asserted.
- [x] Replay sources are deterministic and none is a grind loop.
