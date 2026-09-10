# 11_NARRATIVE — AI-09 Narrative / Lore / Localization Pack

**Owner:** AI-09 (Narrative / Lore / Localization)
**Phase introduced:** Phase 00 — Product/IP Lock
**Status of everything in this folder:** `DRAFT` (Phase 00). Nothing here is FROZEN or RELEASED.
Canon becomes consumable only after the Phase 01 contract freeze and Product (AI-01) + Human approval of the Story Promise.

## Why this folder exists

The repository baseline contains design-intent documents (`01_PREPRODUCTION/STORY_BIBLE_V7.md` etc.) but no
narrative registers, no stable narrative IDs, no localization keys and no fixtures. Downstream tracks
(AI-03 puzzle content, AI-05 world, AI-06 companions, AI-07 UX, AI-08 audio, AI-10 QA) cannot reference
"the first chapter" or "Nox" in data without stable identifiers. This pack provides them.

A folder-ownership map does not yet exist in the repo (Phase 01 deliverable). `11_NARRATIVE/` is the
proposed AI-09-owned path. If AI-13 assigns a different path in Phase 01, the folder can be moved without
breaking anything: **IDs in this pack are semantic identifiers, never file paths** (see `06_CONTRACTS/EVENT_AND_ID_POLICY.md`).

## Contents

| File | Purpose | Consumers |
|---|---|---|
| `../01_PREPRODUCTION/STORY_BIBLE_V7.md` | Canonical Story Bible (premise, tone, world rules, three-act spine, cast). Refined in place by AI-09. | all |
| `FIRST_TEN_MINUTES.md` | Beat-by-beat first-session narrative experience mapped to the six first-session requirements. | AI-01, AI-03, AI-04, AI-06, AI-07, AI-08 |
| `CHAPTER_BEAT_MAP.md` | Chapter purpose, emotional/gameplay objective, question introduced/advanced, per chapter. Not a content tree. | AI-03, AI-05, AI-08, AI-10 |
| `CHARACTER_ARC_REGISTER.md` | Setup / conflict / turning point / payoff for each major character and companion, plus scoped memory flags. | AI-06, AI-07, AI-08, AI-10 |
| `MYSTERY_PAYOFF_REGISTER.md` | Every major mystery with setup clue, reinforcement, false lead, partial payoff, final reinterpretation. | AI-03, AI-05, AI-10 |
| `NARRATIVE_ITEM_LEDGER.md` | Lore, provenance and gameplay purpose of story-significant items/relics. Narrative meaning only; item state/definition is AI-02. | AI-02, AI-03, AI-07 |
| `ENVIRONMENTAL_STORYTELLING_VOCABULARY.md` | Recurring symbols, motifs, visual clue grammar, audio motif intent. Meaning only; assets are AI-05/06/08. | AI-05, AI-06, AI-08 |
| `LOCALIZATION_TERMINOLOGY_BIBLE.md` | Canon terms as stable keys, localization rules, key grammar, do-not-translate list. | AI-07, AI-08, AI-12 |
| `OPEN_DECISIONS_AI09.md` | Unresolved Product/Human decisions. Not guessed. | AI-01, AI-13 |
| `fixtures/narrative_canon_registry.v0.1.0.json` | Machine-readable DRAFT registry of all narrative IDs in this pack. Mock/fixture for downstream tracks. | AI-02, AI-03, AI-07, AI-10 |
| `fixtures/loc/en.v0.1.0.json` | DRAFT English source strings keyed by localization key. Fixture only. | AI-07, AI-08, AI-10, AI-12 |
| `tools/validate_narrative_registry.py` | Track-local self-check: ID grammar, uniqueness, cross-reference integrity between registry, loc keys and the markdown registers. Not CI. | AI-09, AI-10 |
| `HANDOFF_PHASE00_AI09.md` | Phase 00 handoff in the mandatory template. | AI-13 |

## Stable ID grammar (DRAFT v0.1.0)

All narrative IDs are lowercase, dot-separated, ASCII `[a-z0-9_.]`, and start with the `nar.` namespace so they
cannot collide with runtime/event IDs owned by other tracks (`game.*`, `companion.*` precedent in
`06_CONTRACTS/CONTRACT_FIRST_RULES.md`).

| Prefix | Meaning | Example |
|---|---|---|
| `nar.act.<n>` | Act | `nar.act.1` |
| `nar.chapter.<nn>_<slug>` | Chapter | `nar.chapter.01_first_light` |
| `nar.beat.<chapter_nn>.<slug>` | Narrative beat within a chapter | `nar.beat.01.cube_answers` |
| `nar.character.<slug>` | Character or companion | `nar.character.nox` |
| `nar.mystery.<slug>` | Major mystery | `nar.mystery.why_the_weaver` |
| `nar.item_lore.<slug>` | Lore entry for an item (item *definition* is AI-02) | `nar.item_lore.memory_lens` |
| `nar.motif.<slug>` | Environmental / audio motif meaning | `nar.motif.three_notch_mark` |
| `nar.flag.<slug>` | Narrative memory flag (CharacterMemory / NarrativeMemoryFlag contract, AI-09 owner) | `nar.flag.orin_told_of_architect` |
| `nar.term.<slug>` | Canon terminology entry | `nar.term.axis_loom` |

Localization keys use a separate `loc.` namespace (grammar in `LOCALIZATION_TERMINOLOGY_BIBLE.md`).

## Rules for consumers

1. Reference narrative entities **only** by `nar.*` ID, never by display name.
2. Display names come **only** from `loc.*` keys, never hard-coded.
3. Anything marked `PROPOSED` in a register is a candidate, not a released fact.
4. Item lore IDs (`nar.item_lore.*`) are not item definition IDs. AI-02 owns `ItemDefinition`/`ItemIdentity`.
   Until AI-02 releases item IDs, the ledger cross-references items by a `proposed_item_slug` only.
5. Do not add fields to fixtures under `fixtures/` without a version bump; they are consumed as golden data.

## What AI-09 does NOT own here

Runtime narrative-event dispatch (AI-04), dialogue UI (AI-07), voice/audio files (AI-08), companion animation
(AI-06), environment assets (AI-05), CI validation (AI-12), deterministic state storage (AI-02).
This pack only defines *meaning, canon, terminology and keys*.
