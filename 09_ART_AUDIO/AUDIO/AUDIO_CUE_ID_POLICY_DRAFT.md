# CraftCube v7 — Audio Cue ID Policy (DRAFT 0.1.0)

- Owner: AI-08
- Contract family: **Audio cue IDs** (listed in `06_CONTRACTS/CONTRACT_FIRST_RULES.md` under "Contract families").
- Status: **DRAFT** — per `06_CONTRACTS/CONTRACT_REGISTRY_TEMPLATE.md` a contract is not consumable until FROZEN or RELEASED. Freeze is a Phase 01 deliverable. Consumers may build against the fixture in `fixtures/` as a mock only.
- Registry entry (template fields):
  - Contract ID: `CC.AUDIO.CUE`
  - Owner: AI-08
  - Version: 0.1.0 (DRAFT)
  - Status: DRAFT
  - Consumers (intended): AI-04 (runtime trigger), AI-06 (companion/VFX sync), AI-07 (settings, redundancy UX), AI-09 (narrative event → cue mapping), AI-10 (validation), AI-11 (budgets), AI-12 (asset packaging), AI-13 (governance)
  - Compatibility promise: once RELEASED, cue IDs are immutable; additive fields only in MINOR; removals/renames require MAJOR + migration (per `EVENT_AND_ID_POLICY.md`).
  - Breaking-change policy: `01_GOVERNANCE/CHANGE_CONTROL_AND_DECISION_LOG.md`.
  - Test suite: `scripts/validate_audio_cue_registry.py` (structural validation, Python 3).
  - Fixture set: `fixtures/audio_cue_registry_draft.v0.1.0.json`
  - Migration required: NO (nothing released)
  - Change decision ID: none yet

The contract ID prefix `CC.` follows the existing family naming in `06_CONTRACTS/NARRATIVE_ITEM_CONTRACTS.md` (e.g. `CC.NARRATIVE.EVENT`). `CC.AUDIO.CUE` was searched for and does not exist elsewhere in the repository (VERIFIED at creation).

---

## 1. Why a separate cue ID layer

`CONTRACT_FIRST_RULES.md` requires every asset reference to be ID-based and lists "Audio cue IDs" as a distinct contract family from "Asset IDs". The cue layer is the **semantic** request ("the player committed a move") and the asset layer is the **realisation** (which clip, which variation). Gameplay, narrative and UI tracks reference **cue IDs only**; they never reference audio asset IDs or files. This lets AI-08 re-author sound without touching other owners' data.

## 2. Cue ID grammar

Reuses the existing dotted-lowercase event convention from `CONTRACT_FIRST_RULES.md` (`game.bloom.started`, `companion.ability.used`) with a fixed `audio.` root so cue IDs can never collide with gameplay/narrative event IDs.

```
audio.<domain>.<subject>.<action>[.<qualifier>]
```

- Allowed characters: `[a-z0-9_]` per segment, segments separated by `.`; 4–5 segments.
- `<domain>` is one of: `puzzle`, `world`, `story`, `item`, `companion`, `discovery`, `ui`, `music`, `system`.
- `<subject>` names the thing (e.g. `move`, `axis`, `biome`, `nox`, `relic`, `secret`).
- `<action>` is a past-tense or state word (e.g. `committed`, `rejected`, `entered`, `revealed`, `exhausted`).
- Optional `<qualifier>` distinguishes variants that are semantically different (not asset variations): e.g. `audio.puzzle.move.rejected.locked_axis`.
- IDs are semantic, never file names (`EVENT_AND_ID_POLICY.md`).

Non-goals: cue IDs do not encode biome, item name, chapter or asset variant. Those arrive as **context parameters** at trigger time (`biomeId`, `tierIndex`, `itemBehaviorClass`, `bondStage`, ...), defined by the producing contracts once frozen.

## 3. Registry record schema (DRAFT 0.1.0)

Each record in the registry fixture:

| Field | Type | Required | Meaning |
|---|---|---|---|
| `cueId` | string | yes | Stable ID per §2 |
| `priorityClass` | enum | yes | `P0_PUZZLE_CRITICAL` \| `P1_NARRATIVE` \| `P2_WORLD_REACTION` \| `P3_COMPANION_ITEM` \| `P4_AMBIENT_MUSIC` \| `P5_UI` |
| `bus` | enum | yes | `PuzzleCritical` \| `Narrative` \| `Companion` \| `Item` \| `World` \| `Music` \| `UI` |
| `layerRole` | enum | yes | `one_shot` \| `continuous` \| `layer` \| `stinger` |
| `triggerSource` | string | yes | Contract family expected to emit the trigger (`PuzzleState`, `WorldStateEvent`, `NarrativeEvent`, `CompanionReaction`, `DiscoveryDefinition`, `EquipmentEffect`, `AccessibilityPreference`, `Runtime` for AI-04 input adapters, `AudioInternal` for music logic) |
| `variationStrategy` | enum | yes | `none` \| `round_robin` \| `micro_variation` \| `intensity_ladder` \| `motif_form` |
| `maxRatePerSecondHint` | number | yes | Design hint for fatigue review; cues > 1.0 must not use `none` |
| `requiresNonAudioEquivalent` | boolean | yes | Must be `true` for all `P0_*` and `P1_*` cues (accessibility redundancy) |
| `motifRef` | string \| null | yes | One of the motif IDs in §4 or `null` |
| `description` | string | yes | Human-readable intent, engine-agnostic |
| `status` | enum | yes | `draft` \| `frozen` \| `released` \| `deprecated` |

Registry envelope: `{ "schemaVersion": "0.1.0", "contractId": "CC.AUDIO.CUE", "status": "DRAFT", "owner": "AI-08", "motifs": [...], "cues": [...] }`.

## 4. Motif IDs (audio-owned identifiers)

Format `motif.<name>`; the *meaning* attached to each motif is canon owned by AI-09 (see `AUDIO_IDENTITY_AND_DIRECTION_V7.md` §5).

| motifId | Audio name |
|---|---|
| `motif.loom` | Loom Motif |
| `motif.weaver` | Weaver Motif |
| `motif.nox` | Nox Motif |
| `motif.misalignment_texture` | Misalignment Texture |
| `motif.architect_fragment` | Architect Fragment |

## 5. Validation rules (enforced by `scripts/validate_audio_cue_registry.py`)

1. Envelope fields present; `schemaVersion` is semver.
2. Every `cueId` matches the grammar regex and uses an allowed domain.
3. No duplicate `cueId`; no duplicate `motifId` (collision prevention, `EVENT_AND_ID_POLICY.md`).
4. Every record has all required fields with allowed enum values.
5. `P0_*`/`P1_*` ⇒ `requiresNonAudioEquivalent == true`.
6. `maxRatePerSecondHint > 1.0` ⇒ `variationStrategy != none`.
7. `motifRef` is `null` or references a declared motif.
8. `priorityClass` ↔ `bus` consistency: `P0_PUZZLE_CRITICAL` ⇒ `PuzzleCritical`; `P5_UI` ⇒ `UI`; `P4_AMBIENT_MUSIC` ⇒ `Music` or `World`.
9. Exit code non-zero with a listed reason on any violation (no silent pass).

## 6. Asset ID convention for audio (reuse of `ASSET_PIPELINE.md`)

Audio assets use the existing shared grammar `<type>_<system>_<semantic>_<variant>_<version>` with `type ∈ {sfx, mus, amb, vox}`, e.g. `sfx_puzzle_move_committed_a_v01`, `mus_hearthwild_tier2_layer_pad_v01`. Asset IDs are not part of the cue contract; they are AI-08-internal and mapped cue→asset in Phase 01+ tooling. Every asset carries the mandatory pipeline metadata including `license`.

## 7. Trigger context (to be bound in Phase 01)

Cues are triggered with a context object. Field names below are **AI-08 proposals** that must be reconciled with the frozen producer contracts; they are deliberately not asserted as final:

- `biomeId`, `biomeTier` (from `WorldState` / `BiomeState`, owner AI-02)
- `puzzleProgress01`, `failureReason` (from `PuzzleState`, owner AI-02; typed failures per `INTERACTION_CONTRACTS.md`)
- `narrativeEventId`, `mysteryId` (from `NarrativeEvent`, owner AI-09)
- `companionId`, `bondStage`, `reactionId` (from `CompanionReaction`, owner AI-06)
- `itemBehaviorClass`, `effectId` (from `EquipmentEffect`, owner AI-02)
- `discoveryId` (from `DiscoveryDefinition`, owner AI-03)
- `accessibility` (from `AccessibilityPreference`, owner AI-07)

## 8. Mock / fixture policy

`fixtures/audio_cue_registry_draft.v0.1.0.json` is the minimal test fixture required by `V7_MASTER_CONTRACT_REGISTER.md` ("for every contract, a minimal test fixture must exist"). It is **not production data**: it lives under `09_ART_AUDIO/AUDIO/fixtures/`, is named `*_draft*`, and every record has `status: "draft"`. Consumers wiring audio triggers may code against these IDs knowing they are candidates until Phase 01 freeze.

## 9. What this draft does not do

- Does not define audio-engine APIs, C# interfaces or Unity settings (Phase 01/02, after middleware decision AUD-OD-02).
- Does not define localization keys (AI-09).
- Does not define the haptic/caption payload of redundancy events (needs `AccessibilityPreference` from AI-07).
- Does not assert any asset exists.
