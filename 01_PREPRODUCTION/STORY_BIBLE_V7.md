# CraftCube v7 — Story Bible

**Owner:** AI-09 · **Status:** DRAFT v0.1.0 (Phase 00) · **Canon approval:** pending AI-01 (Story Promise) + Human review (canon is a human approval gate per `00_CONTROL/13_AI_EXECUTION_MANUAL.md`).
Stable IDs referenced here are defined in `11_NARRATIVE/fixtures/narrative_canon_registry.v0.1.0.json`. Display names are DRAFT English source text; production uses `loc.*` keys only.

## Working title inside the narrative

**The Loom of Asterra**

The public game title remains CraftCube unless Product changes it later. The internal world name may be used during development.

## Tone

Wonder + mystery + warmth + quiet danger.

The world should feel ancient but not grim, magical but governed by understandable rules, and hopeful without becoming childish.

Tone guardrails for writers:
- No character explains a rule the player has already felt through play.
- Danger is quiet: a channel that goes dark, a creature that stops singing, a path that no longer aligns. Never gore, never horror.
- Humor is warm and situational (Nox's misfires, Mira's over-annotation), never sarcastic toward the player.
- Wonder is expressed by the world answering, not by characters saying "amazing".

## The premise

Asterra was once connected by a hidden geometric network called the Axis Loom. Each region was stabilized by a different expression of the Loom's spatial rules. When the Loom suffered the Great Misalignment, the world split into unstable regions.

The player awakens in the **Hearthwild**, where a small damaged cube-like device responds to their touch.

The player's first successful sequence is not merely a puzzle tutorial: it restarts a dormant local mechanism and causes the first visible restoration of the world.

## Player role

The player is a **Weaver** (`nar.character.weaver`): one of very few people who can read the Loom's pattern-language by touch. The Weaver is deliberately lightly characterised — no spoken name, no fixed gender, no voiced lines — so identity stays personal. The Weaver's competence is the player's own puzzle mastery; the fiction never claims skill the player has not demonstrated.

The Weaver is not a chosen hero. The Loom answers anyone who can hear it. The mystery is why so few can.

## Story promise (for AI-01 approval)

> *Every time you master the cube, the world visibly answers — and the more you understand it, the less certain you become that putting it back the way it was is the right thing to do.*

The promise commits us to three things the player must be able to verify in play:
1. Puzzle mastery causes visible, persistent world change (world memory).
2. Story is learned by acting and looking, not by reading.
3. The ending is a choice the player understands, seeded from Chapter 1, resolved without a lore dump.

## World rules (canon constraints all tracks can rely on)

These are narrative rules, not runtime rules. Runtime truth is AI-02's domain; this list exists so no track writes content that contradicts the fiction.

| Rule | Statement | Why it matters downstream |
|---|---|---|
| WR-1 | The Loom is spatial, not magical. It stores state as arrangement; a "solved" arrangement is one the Loom recognises. | Puzzle = literal language of the world; no spell-casting fiction. |
| WR-2 | Restoration is local first. A solved cube re-aligns the nearest Loom node; effects radiate outward and can be seen. | Justifies biome tiers 0–4 in `WORLD_BIOME_BIBLE_V7.md` and small visible consequences. |
| WR-3 | The Loom remembers. Prior states leave echoes in matter — crystal, root, stone, water. | Foundation for Glassroot world memory and Memory Lens fiction. |
| WR-4 | Misalignment is not destruction. A misaligned region is dormant or unstable, never annihilated. Nothing living was "killed by the Misalignment". | Keeps tone; instability can be useful (Ember Hollow). |
| WR-5 | Loom-born creatures (Nox's kind) are residual pattern energy. They sense alignment but cannot perform it. | Companions sense/react; they never auto-solve (DD-002, DD-007). |
| WR-6 | Nobody alive remembers the Misalignment first-hand. All history is record, ruin and inference. | Enables contradictory records (Sunken Grid) and the false-lead structure. |
| WR-7 | The Loom's builders left no names, only marks. The "Quiet Architect" is a title the cast invent. | IP-safe, no proper-noun lore dump; the mystery is reconstructed, not told. |
| WR-8 | The Loom was designed to change. "Restoration" and "the old order" are the cast's assumption, not the Loom's purpose. | Core Act III turn; must be foreshadowed from Ch.1 (see Mystery Register). |

## Main cast

Full arcs (setup / conflict / turning point / payoff / memory flags) live in `11_NARRATIVE/CHARACTER_ARC_REGISTER.md`.

### The Weaver — player character (`nar.character.weaver`)

The player is intentionally lightly defined so identity can remain personal. Their central mystery is why they can hear/read the Loom's patterns when almost nobody else can.

### Mira — the Cartographer (`nar.character.mira`)

A curious field researcher who documents changes in the world. She provides context without becoming a constant exposition machine. Her arc is learning that mapping a system is not the same as understanding it.

### Orin — the Keeper (`nar.character.orin`)

An older guardian who remembers fragments of pre-Misalignment traditions. He begins convinced that restoration means returning everything to the old order. His arc questions whether stability and freedom are always the same thing.

### Nox — first companion (`nar.character.nox`)

A small biome-native creature formed from residual Loom energy. It reacts strongly to puzzle states and world conditions. It is useful, expressive and emotionally readable rather than combat-centric.

### The Quiet Architect (`nar.character.quiet_architect`)

A mostly unseen historical presence revealed through relics, architectural clues and late-game discoveries. The player gradually learns that the Loom was designed to evolve, not merely preserve the world. Per WR-7 this is a title, not a person's name; whether it was one builder or many is itself a mystery (`nar.mystery.who_built_the_loom`).

### Cast size rule

Phase 00 canon fixes **four** speaking/reacting characters (Mira, Orin, Nox, and the Architect-as-absence). Additional biome-local characters are PROPOSED only and require a Product decision before any content is written (see `11_NARRATIVE/OPEN_DECISIONS_AI09.md`). Fewer, stronger characters (DD-011).

## Three-act spine

Chapter titles below are the seeded canon from the v7 baseline and are kept. Per-chapter purpose, objectives and questions are in `11_NARRATIVE/CHAPTER_BEAT_MAP.md`. This bible intentionally does **not** contain beat-level content (no giant content tree).

### Act I — Awakening (`nar.act.1`)

The player restores the first local mechanism, meets Nox, learns the basic puzzle language and sees that solved patterns have physical consequences.

Core narrative question:
**Why does the world react to my hands?**

Act purpose: teach causality and earn attachment. By the end of Act I the player must have (a) changed the world and been able to walk back and look at it, (b) formed a bond with Nox through a shared discovery, (c) noticed one thing that does not fit the "broken machine" story.

#### Chapter themes
1. First Light — awaken the mechanism. (`nar.chapter.01_first_light`)
2. The Broken Path — restore a route through the Hearthwild. (`nar.chapter.02_broken_path`)
3. Echoes in Stone — discover the first artifact record. (`nar.chapter.03_echoes_in_stone`)

### Act II — Fracture (`nar.act.2`)

The player reaches distinct biomes, discovers incompatible world states and begins using equipment to interact with specialized Loom phenomena.

Core narrative question:
**Was the Great Misalignment an accident?**

Act purpose: complicate. Each biome contradicts something the player believed after Act I. Equipment arrives as *new ways of listening to the Loom*, never as power. Orin and Mira begin to disagree in front of the player.

#### Chapter themes
4. Glassroot — a crystalline biome remembers old states. (`nar.chapter.04_glassroot`)
5. The Sunken Grid — flooded ruins expose contradictory history. (`nar.chapter.05_sunken_grid`)
6. Ember Hollow — instability becomes useful as well as dangerous. (`nar.chapter.06_ember_hollow`)
7. The Silent Engine — first direct evidence of deliberate design. (`nar.chapter.07_silent_engine`)

### Act III — Reconciliation (`nar.act.3`)

The player learns the true purpose of the Loom and must choose what kind of future to create.

Core narrative question:
**Should the world be restored exactly as it was?**

Act purpose: resolve without exposition. The final choice must be answerable from evidence the player has already handled. Mastery challenges in Act III test *understanding* of the Loom's language (multi-state, long-range), mirroring the thematic turn from "restore" to "compose".

#### Chapter themes
8. The Unfinished Pattern — mastery without certainty. (`nar.chapter.08_unfinished_pattern`)
9. The Last Alignment — consequences of prior discoveries. (`nar.chapter.09_last_alignment`)
10. A World Rewritten — final decision and epilogue states. (`nar.chapter.10_world_rewritten`)

## Chapter cadence

Ten chapters, three acts, cadence 3 / 4 / 3. Not every chapter carries every beat type; the deliberate rhythm is:

| Chapter | Weight | Dominant beat |
|---|---|---|
| 1 | light | causality + wonder |
| 2 | light | traversal + companion trust |
| 3 | medium | first mystery evidence |
| 4 | medium | world memory revealed |
| 5 | heavy | contradiction, Mira/Orin split begins |
| 6 | medium | reframing (instability is a tool) |
| 7 | heavy | deliberate-design evidence, act climax |
| 8 | medium | mastery + doubt |
| 9 | heavy | consequences of scoped choices land |
| 10 | resolution | choice + epilogue states |

## Narrative choice philosophy

Do not create giant branching content trees.

Use **scoped persistent consequences**:
- which local restoration the player prioritizes,
- which companion memory is unlocked,
- which artifact interpretation is believed first,
- which optional region state is preserved.

Consequences should mainly change dialogue, presentation, optional routes, collectible records and finale nuance.

Implementation constraint (for AI-02/AI-07 consumers): all scoped consequences are expressed as a **closed set of boolean/enum narrative flags** (`nar.flag.*`, enumerated in `CHARACTER_ARC_REGISTER.md` and the canon registry). Phase 00 budget: **≤ 12 flags for the whole game**. New flags require a decision record (DD-013).

## Mystery/payoff design

Every major mystery must have:
- setup clue,
- reinforcement clue,
- false interpretation or uncertainty,
- partial payoff,
- final reinterpretation.

Do not make the story depend on one late exposition dump.

The register that enforces this is `11_NARRATIVE/MYSTERY_PAYOFF_REGISTER.md`. A mystery may not appear in content until its row is complete or explicitly marked `INTENTIONALLY_UNRESOLVED`.

## Item storytelling

Important relics should have:
- physical identity,
- provenance,
- first discovery scene,
- functional use,
- lore entry,
- at least one world connection,
- optional companion reaction.

Philosophy for story-linked relics: a relic is **a way of listening to the Loom that someone before you invented**. Every relic therefore carries evidence about its maker — which is how the Architect mystery is delivered without narration. Relics never *do* the puzzle; they change what the player can perceive, reach or risk (DD-002). See `11_NARRATIVE/NARRATIVE_ITEM_LEDGER.md`.

## Environmental storytelling

Use:
- damaged structures,
- restored architecture,
- recurring symbols,
- sound motifs,
- color/material changes,
- abandoned tools,
- creature behavior,
- visual before/after states.

Shared vocabulary of symbols and motifs: `11_NARRATIVE/ENVIRONMENTAL_STORYTELLING_VOCABULARY.md`.

## Localization principle

No canon term, name or line of dialogue is ever hard-coded. All player-facing narrative text is addressed by `loc.*` key; canon terminology (`nar.term.*`) defines meaning, casing, gender/plural behaviour and do-not-translate status. See `11_NARRATIVE/LOCALIZATION_TERMINOLOGY_BIBLE.md`.

## Narrative fail-safe

If a player skips optional lore, the main story remains understandable.
If a player seeks deep lore, there should be enough evidence to reconstruct a richer interpretation.

Test for every chapter (consumable by AI-10): a player who reads **zero** optional records and skips all optional dialogue can still state, in one sentence, what they did to the world and what question is now open.

## IP-safety statement

All names (Asterra, Axis Loom, Great Misalignment, Weaver, Hearthwild, Glassroot, Sunken Grid, Ember Hollow, Verdant Archive, Quiet Engine, Mira, Orin, Nox, Quiet Architect) are original to this project. No creature, block, item, faction or UI term from any third-party property is used. Source-GDD Minecraft-specific names noted in `10_SOURCE_REFERENCE/SOURCE_GDD_NOTES.md` are **excluded** from canon. Trademark clearance of the working titles is a Product/legal task, not asserted here (see `OPEN_DECISIONS_AI09.md`).
