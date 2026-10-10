# CraftCube — Companion Reaction Model & `CompanionReaction` Contract Outline (DRAFT)

| Field | Value |
|---|---|
| Owner | AI-06 — Characters / Creatures / Animation / VFX |
| Document ID | `CC.CHARVFX.REACTION_MODEL` |
| Version | 0.1.0-draft |
| Status | **DRAFT** — not consumable as a contract. Phase 01 freezes the `CompanionReaction` contract after AI-13 records decision D-04 / D6-03 (ownership split B6-01). |
| Phase | 00 — Product/IP Lock |
| Parent | `AI06_CHARACTER_CREATURE_VFX_LOCK_V1.md` §6–§7 |
| Contract family | `CompanionReaction` (`06_CONTRACTS/V7_MASTER_CONTRACT_REGISTER.md`: owner AI-06, consumers AI-04/08/09/10); narrative pack name `CC.COMPANION.REACTION` (`06_CONTRACTS/NARRATIVE_ITEM_CONTRACTS.md`) |

Per `06_CONTRACTS/CONTRACT_REGISTRY_TEMPLATE.md`, a contract is not consumable until FROZEN or RELEASED. Everything below is a *proposal* so that AI-02/04/08/09/10 can react to a concrete shape in Phase 00 instead of guessing in Phase 01. Field names are draft; no runtime ID here is released.

## 1. Purpose

Make puzzle and world consequences **legible** through the companion without ever revealing puzzle solutions, hiding puzzle state, or requiring the companion for progression. The player should learn Nox's "language" in the first session and be able to read purpose from motion alone, with audio and dialogue as redundant channels.

## 2. Pipeline (who does what)

```
[AI-02 domain]      PuzzleState / WorldState / EquipmentEffect / bond stage
       |  deterministic trigger evaluation (proposal B6-01)
       v
[trigger payload]   CompanionReactionTrigger  (draft §6.1)
       |
[AI-06 selection]   deterministic: (trigger, bondStage, memoryFlags, seed) -> ReactionDefinition
       |            arbitration: priority / cooldown / coalesce (§5)
       v
[ReactionDefinition] (draft §6.2)  -> channels: pose, locomotion, facet, vfx, audioHook, dialogueHook, feedbackCue
       |
[AI-04 runtime]     places Nox, plays channels, forwards feedbackCue under AI-07 AccessibilityPreference
[AI-08 audio]       resolves audioHook -> audio cue ID
[AI-09 narrative]   resolves dialogueHook -> localization key; supplies memoryFlags
[AI-10 QA]          validators: whitelist, reduced-motion, channels, determinism, no-ContentNotFound
```

AI-06 persists nothing. If a reaction should be remembered ("Nox already reacted to the first relic"), that is a `NarrativeMemoryFlag` (AI-09 meaning, AI-02 store semantics), consumed by selection as input.

## 3. Trigger classes (closed set — PD-005 whitelist)

| Trigger class | Verified source wording | Draft payload discriminator | Typical purposes |
|---|---|---|---|
| `puzzle_state` | "specific puzzle states" | puzzle state descriptor from AI-02 (e.g., alignment reached, axis locked, solve) — exact fields are AI-02's | confirm, warn, question |
| `biome_health` | "biome health" | biome ID + tier 0–4 + delta direction | celebrate, warn, comfort |
| `relic` | "important relics" | item ID (Relic family) + event kind (discovered / first_use / resonance) | point, question, celebrate |
| `story_revelation` | "story revelations" | `NarrativeEvent` ID | question, comfort, celebrate |
| `mastery_moment` | "successful mastery moments" | mastery signal from AI-03 (challenge type + outcome) | celebrate (only class allowed `peak` by default) |
| `player_choice` | "player choices" | choice ID + option ID (AI-09) | comfort, question, confirm |

Any other class (e.g., "timer", "idle_seconds", "gift", "damage") **fails validation**. Ambient idle behaviour is not a reaction; it is the `accompany` baseline and is authored separately without triggers.

## 4. Reaction anatomy

### 4.1 Purpose (closed set)
`confirm` · `warn` · `point` · `celebrate` · `comfort` · `question`

Each reaction declares exactly one purpose. Purpose drives (a) motion family, (b) priority in arbitration, (c) the audio/dialogue hook intent AI-08/AI-09 fulfil.

Priority order for interruption (higher interrupts lower): `warn` > `point` > `question` > `celebrate` > `confirm` > `comfort`. Rationale: safety/legibility of an unstable state beats celebration; comfort is never urgent.

### 4.2 Intensity (closed set)
`subtle` · `clear` · `peak`

- `subtle`: peripheral, ≤ ~0.6 s, no VFX beyond facet shift; allowed during active input if it does not occlude (VFX-R1).
- `clear`: readable at phone scale, ≤ ~1.5 s, may include companion VFX; must complete inside AI-01's ≤ 2 s world-reaction window when tied to a solve.
- `peak`: full-body + VFX, ≤ ~3 s; reserved for `mastery_moment` and `story_revelation`; ≤ 1 per chapter beat (HYPOTHESIS CVX-M10). Never during active input.

Durations are HYPOTHESES to be tuned in Phases 04–06; they are recorded so AI-04 and AI-08 have a starting envelope.

### 4.3 Channels (each reaction lists which it uses; ≥ 2 meaning channels required — VFX-R2)
| Channel | Content | Fulfilled by |
|---|---|---|
| `pose` | animation state / clip reference (asset ID) | AI-06 |
| `locomotion` | approach / orbit / retreat / hold, relative to a target anchor supplied by AI-04 | AI-06 authors, AI-04 resolves anchor |
| `facet` | Loom-facet parameter set (pattern, pulse rate ≤ 3 Hz, luminance band) — *shape and rhythm*, never color-only | AI-06 |
| `vfx` | transient VFX asset ID with §11 metadata | AI-06 |
| `audioHook` | opaque hook ID slot; AI-08 maps to a cue | AI-08 |
| `dialogueHook` | opaque hook ID slot; AI-09 maps to a localization key (or none) | AI-09 |
| `feedbackCue` | request `{ shake: none|low|mid, haptic: none|light|medium }` — applied by AI-04 under AI-07 preferences (B6-04) | AI-04 / AI-07 |

### 4.4 Accessibility fields (mandatory)
- `reducedMotion`: a variant that removes locomotion and large pose motion and keeps facet + audioHook + dialogueHook. Never empty (VFX-R4).
- `meaningChannels`: the subset of channels that independently carry the purpose; length ≥ 2 and not `["facet"]` alone if facet is color-only (VFX-R2).

## 5. Arbitration rules (deterministic)

1. At most one active reaction. An incoming reaction with strictly higher purpose priority interrupts; equal or lower waits or is dropped per `onBusy: queue|drop`.
2. `cooldownMs` per definition; identical `(definitionId)` within cooldown is coalesced (counted, not replayed).
3. Reactions targeting a `puzzle_state` during active input are clamped to `subtle`.
4. Selection is a pure function: `select(trigger, bondStage, memoryFlags, seed) -> definitionId | ContentNotFound`. Same inputs → same output. The `seed` comes from the domain (AI-02) so replays reproduce reactions; AI-06 never calls engine RNG.
5. If no definition matches, return typed `ContentNotFound` (verified failure reason list, `INTERACTION_CONTRACTS.md`); QA tooling must surface it; the runtime shows no reaction and logs — it never substitutes a random one.

## 6. Draft schema outline

### 6.1 `CompanionReactionTrigger` (input; produced by AI-02 per B6-01 — draft for discussion)
```json
{
  "schemaVersion": "0.1.0-draft",
  "companionId": "<companion id, e.g. companion.nox — AI-09/AI-13 issue the released ID>",
  "triggerClass": "puzzle_state | biome_health | relic | story_revelation | mastery_moment | player_choice",
  "triggerRef": "<opaque domain/content reference owned by the emitting track>",
  "bondStage": "meet | trust | shared_discovery | capability | memory | choice",
  "memoryFlags": ["<NarrativeMemoryFlag ids — AI-09>"],
  "inputActive": true,
  "seed": 0
}
```

### 6.2 `CompanionReactionDefinition` (content; owned by AI-06)
```json
{
  "schemaVersion": "0.1.0-draft",
  "definitionId": "<stable id, dotted lowercase, e.g. reaction.nox.biome_health.tier_up.clear>",
  "companionId": "<companion id>",
  "triggerClass": "<one of the six>",
  "match": { "<class-specific selectors, e.g. tierDelta: +1, minBondStage: trust>": "..." },
  "purpose": "confirm | warn | point | celebrate | comfort | question",
  "intensity": "subtle | clear | peak",
  "durationMsMax": 1500,
  "cooldownMs": 4000,
  "onBusy": "queue | drop",
  "channels": {
    "pose": "<asset id>",
    "locomotion": "approach | orbit | retreat | hold | none",
    "facet": { "pattern": "<pattern id>", "pulseHz": 1.0, "luminanceBand": "low | mid | high" },
    "vfx": "<asset id or null>",
    "audioHook": "<hook id>",
    "dialogueHook": "<hook id or null>",
    "feedbackCue": { "shake": "none | low | mid", "haptic": "none | light | medium" }
  },
  "meaningChannels": ["pose", "audioHook"],
  "reducedMotion": { "pose": "<asset id>", "locomotion": "none", "facet": { "...": "..." } },
  "occludesPuzzleDuringInput": false,
  "flashRateMaxHz": 3,
  "localizationKeys": [],
  "placeholder": false
}
```

### 6.3 Versioning and compatibility
- `schemaVersion` on every serialized object (verified schema rule).
- Additive fields → MINOR; consumers tolerate unknown fields. Removing/renaming a field or a closed-set value → MAJOR with migration plan.
- Closed sets (`triggerClass`, `purpose`, `intensity`) grow only by MINOR bump **and** a Product decision, because `triggerClass` growth changes PD-005.

## 7. Validation rules (what `tools/ai06_validate_phase00.py` checks today on the fixture; AI-10 extends for production content)

| Rule | Check |
|---|---|
| V-01 | `triggerClass` ∈ six PD-005 classes |
| V-02 | `purpose` and `intensity` ∈ closed sets |
| V-03 | `peak` only with `mastery_moment` or `story_revelation` |
| V-04 | `meaningChannels` length ≥ 2, all present in `channels` |
| V-05 | `reducedMotion` present and non-empty |
| V-06 | `occludesPuzzleDuringInput == false` |
| V-07 | `flashRateMaxHz ≤ 3` and `facet.pulseHz ≤ 3` |
| V-08 | `definitionId` unique across the file; dotted lowercase |
| V-09 | no embedded player-facing strings (only key/hook references) |
| V-10 | fixture is labeled `"fixture": true` and `"production": false` |
| V-11 | forbidden IP terms absent (register `ipForbiddenTerms`) |

## 8. Fixture

`fixtures/AI06_companion_reaction_fixture_DRAFT.json` contains six labeled example definitions (one per trigger class) plus one trigger example so AI-04/08/09/10 can wire mocks. **It is not production content**, contains no released IDs, and is replaced when the contract freezes.

## 9. Open items specific to this model

| ID | Item | Owner |
|---|---|---|
| U6-06 | `memoryFlags` and `localizationKeys` formats | AI-09 |
| U6-07 | Exact `puzzle_state` descriptor fields and the `seed` source | AI-02 |
| U6-08 | Mastery signal shape for `mastery_moment` | AI-03 |
| U6-09 | Anchor/target model for `locomotion` (where is "the thing Nox points at" in world space) | AI-04 |
| D6-03 | Confirm split B6-01 (AI-02 triggers, AI-06 definitions/selection) | AI-13 |
| D6-05 | Whether reaction selection lives in the pure C# domain assembly (deterministic, testable without Unity) or in the presentation layer with a pure-function core — AI-06 proposes the latter with the selection function unit-tested outside Unity | AI-02 / AI-13 |
