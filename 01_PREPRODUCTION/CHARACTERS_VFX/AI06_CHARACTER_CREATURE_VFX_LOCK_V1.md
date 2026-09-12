# CraftCube — Characters / Creatures / Animation / VFX Direction Lock v1.0.0 (Phase 00)

| Field | Value |
|---|---|
| Owner | AI-06 — Characters / Creatures / Animation / VFX |
| Document ID | `CC.CHARVFX.LOCK` (document identifier in the AI-06 namespace; to be registered by AI-13 when the governance ID registry exists) |
| Version | 1.0.0 |
| Status | READY_FOR_REVIEW — becomes LOCKED only after (a) AI-01 `CC.PRODUCT.LOCK` 1.0.0 is approved by the Human Product Authority and (b) AI-13 records the ownership splits listed in §13 |
| Phase | 00 — Product/IP Lock |
| Supersedes | nothing (first AI-06 lock) |
| Canonical intent sources | `00_CONTROL/CRAFTCUBE_GAME_MASTER_BIBLE.md`, `01_PREPRODUCTION/COMPANION_BOND_BIBLE_V7.md`, `01_PREPRODUCTION/COMPANION_AND_CHARACTER_SYSTEM.md`, `01_PREPRODUCTION/STORY_BIBLE_V7.md` (cast), `00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md` |

This document locks **how creatures, characters, animation and VFX serve CraftCube** and the measurable boundaries AI-06 will hold. It does not define narrative canon (AI-09), puzzle rules (AI-03), deterministic state (AI-02), UI layout (AI-07), audio (AI-08) or release signing (AI-12). Where this document and the Game Master Bible disagree, that is a defect: file a conflict, do not guess.

Companion documents (same folder):
- `AI06_COMPANION_REACTION_MODEL_DRAFT.md` — reaction grammar and the DRAFT `CompanionReaction` contract outline.
- `AI06_CHARACTERS_VFX_REGISTER_PHASE00.json` — machine-readable draft register (vocabulary, trigger classes, channels, boundaries, asset metadata spec).
- `fixtures/AI06_companion_reaction_fixture_DRAFT.json` — labeled non-production fixture for downstream tracks.
- `tools/ai06_validate_phase00.py` — validator that checks the register, fixture and these documents.

## 0. Evidence legend

Per `05_PROMPTS/ANTI_HALLUCINATION_ADDENDUM.md`: **VERIFIED** = read in the repository; **INFERRED** = derived from verified sources; **ASSUMED / HYPOTHESIS** = a starting value that must be measured or approved; **UNKNOWN / MISSING / CONFLICT** = recorded in §14, never guessed.

## 1. What this lock covers

| In this lock (AI-06 owns) | Not in this lock (owner) |
|---|---|
| Purpose of creatures/characters/VFX in the product | Who the characters *are*, what they *believe*, what they *say* (AI-09) |
| IP-safe creature/character/VFX presentation direction | Public title, monetization, scope MUST/SHOULD (AI-01) |
| Companion **presentation role** for Nox | Bond-stage state, trigger evaluation, persistence (AI-02) |
| Reaction grammar, channels, intensity, arbitration, accessibility fallbacks | Which puzzle states count as "mastery" (AI-03) |
| VFX readability rules and measurable boundaries | Environment materials, lighting, biome kits (AI-05) |
| Animation/VFX runtime feasibility **hypotheses** | Measured budgets and device matrix (AI-11) |
| Technical asset metadata fields for AI-06 assets | Build/CI/asset-bundle pipeline (AI-12) |
| AI-06 domain cut list and decision register | Contract registration, ID registry, merge order (AI-13) |

## 2. Inputs consumed

| Input | Location | Status |
|---|---|---|
| Game Master Bible §3 hierarchy, §5 emotional targets, §12 non-goals | `00_CONTROL/CRAFTCUBE_GAME_MASTER_BIBLE.md` | VERIFIED |
| Companion philosophy, bond stages (6), reaction trigger list (6) | `01_PREPRODUCTION/COMPANION_BOND_BIBLE_V7.md` | VERIFIED |
| Companion roles, reaction model (puzzle result + world state + story state + equipped context) | `01_PREPRODUCTION/COMPANION_AND_CHARACTER_SYSTEM.md` | VERIFIED |
| Cast: Weaver, Mira, Orin, Nox, the Quiet Architect; Nox = "small biome-native creature formed from residual Loom energy… useful, expressive and emotionally readable rather than combat-centric" | `01_PREPRODUCTION/STORY_BIBLE_V7.md` | VERIFIED |
| Biome list and transformation tiers 0–4 | `01_PREPRODUCTION/WORLD_BIOME_BIBLE_V7.md` | VERIFIED |
| DD-007 (companions add meaning, not combat), DD-010 (Android-first), DD-013 (selective memory) | `00_CONTROL/V7_DESIGN_DECISION_REGISTER.md` | VERIFIED |
| V7.1 §3.1 character memory, §3.2 relationship quality, §9 accessibility list, §16 complexity budget | `00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md` | VERIFIED |
| Asset naming `<type>_<system>_<semantic>_<variant>_<lod/version>` and required metadata list | `09_ART_AUDIO/ASSET_PIPELINE.md` | VERIFIED |
| Presentation layer modules `CreatureView`, `VFX controllers`, `Animation orchestration`; data `CreatureSpec`, `CompanionSpec`; engine Unity 6 + URP | `02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md` | VERIFIED (stated; no Unity project exists in the repo yet) |
| `CompanionReaction` owner AI-06, consumers AI-04/08/09/10; `CharacterMemory` owner AI-09, consumer AI-06 | `06_CONTRACTS/V7_MASTER_CONTRACT_REGISTER.md`, `06_CONTRACTS/WORLDCLASS_CONTRACTS_V7_1.md` | VERIFIED |
| Typed failure reasons incl. `ContentNotFound` | `06_CONTRACTS/INTERACTION_CONTRACTS.md` | VERIFIED |
| Gate C "VFX readability on mobile", "animation transitions clean"; Gate B "reduced-motion option respected" | `08_QA_RELEASE/QUALITY_AND_RELEASE.md` | VERIFIED |
| IP warning: keep the source GDD's mechanical ideas, drop its franchise-specific names/creatures/presentation | `10_SOURCE_REFERENCE/SOURCE_GDD_NOTES.md` | VERIFIED |
| AI-01 Product Lock v1.0.0: one companion (CUT-004), no combat (CUT-005), no gift-grinding (CUT-011), PD-005 acceptance validators, PD-011 accessibility constraints, IGM-005c recall ≥ 50 % (owner AI-06/AI-09), earned cosmetics LATER (CUT-031) | branch `origin/ai-01-product`, `01_PREPRODUCTION/PRODUCT/*` | VERIFIED on that branch; **not merged**, status READY_FOR_REVIEW |
| AI-02 boundary audit: `concept.companion_state.reaction_trigger` = SPLIT (state AI-02, meaning AI-06), decision D-04; U-05 no `integration` branch | branch `origin/ai-02-core`, `02_ARCHITECTURE/AI02_*` | VERIFIED on that branch; **not merged**, DRAFT |

## 3. Why creatures and VFX exist in CraftCube

Creatures, characters and VFX have exactly three jobs. Any asset or behavior that does none of them is cut.

| Job | Player-facing effect | Bible anchor |
|---|---|---|
| **Legibility** | The player can *see* that a solve, a world change, a discovery or an item activation happened, and roughly what it meant — before reading anything. | §3 (2) puzzle/world causality; §5 "visible consequence"; V7.1 §14 |
| **Aliveness** | The world reads as living and remembering: creatures behave differently in dormant vs. restored places; transformations are witnessed, not just swapped. | §10 world philosophy; DD-004 |
| **Attachment** | The player cares about at least one non-human presence (Nox) because it notices, reacts and remembers in a way that is consistent and readable. | §5 "attachment"; §11 companion progression; IGM-005c |

**Non-goals for this domain** (restating Bible §12 for AI-06): no combat animation sets, no damage/health VFX, no hostile-creature ecology, no creature collection grid, no cosmetic shop, no VFX spectacle that hides puzzle state. Companion presence must never be required to progress the critical path (PD-005).

## 4. IP-safe presentation direction

### 4.1 Non-negotiable rule
All creature, character and VFX presentation is **original**. No silhouette, palette, motion signature, naming or sound-alike may evoke Minecraft or any other proprietary franchise creature/character. Cube-derived *puzzle* geometry is part of CraftCube's identity; **block/voxel creature language is not** (a cube-headed humanoid, a boxy quadruped, an exploding green creature, etc. are all forbidden). The source GDD's mechanical ideas (companions, Bloom/Collapse feedback, reactive creatures) are retained; their proprietary dressing is discarded.

### 4.2 Visual grammar: "Loom-formed" (PROPOSAL to AI-09/AI-05 for coherence; presentation interpretation of verified canon)
- Loom-native creatures (Nox and any ambient creature) read as **soft organic bodies carrying a small amount of faceted, luminous Loom geometry** — the geometry is where they visibly react to puzzle/world state. Organic = attachment; facet = causal link to the cube. Neither part alone.
- Facets echo the puzzle's *state language* (alignment, orientation, resonance) but **never display the solution** or replicate the cube's tile layout.
- Motion signature: weight-light, curious, "listening" postures; anticipation → reaction → settle, always readable at phone scale (target: readable at ~5 % of screen height — HYPOTHESIS, validate in Phase 04/06).
- Human characters (Mira, Orin) are stylized, non-photoreal, culturally non-specific in costume iconography; no real-world uniform, flag or brand cues.

### 4.3 Terminology policy for this domain
AI-09 owns canon names and localization keys; AI-01 approved top-level nouns (Product Lock §6.3). The terms below are **design vocabulary for AI-06 artifacts**, not player-facing strings and not stable IDs.

| Concept | Use | Avoid |
|---|---|---|
| Nox | **Companion** | "pet", "familiar", "summon", "buddy" |
| Non-companion living things | **Ambient creature** | "mob", "monster", "enemy", "NPC creature", "spawn" |
| A companion's response to a trigger | **Reaction** (with a **Reaction Channel**: pose, locomotion, facet, VFX, audio hook, dialogue hook) | "emote", "buff", "proc" |
| Visual response to puzzle input | **Puzzle feedback cue** | "hit", "combo", "juice" (informal) |
| World changing after a solve | **Restoration / Transformation VFX**; degradation is **Instability VFX** | "loot burst", "level-up", "explosion" |
| Item/equipment activation visual | **Resonance cue** (Equipment Bible "Resonance") | "cast", "spell", "ability FX" |
| Hint presentation forms from source GDD | **Cube Pulse**, **Golden Trail** (names retained as mechanic names; semantics UNKNOWN — see U6-03) | "auto-solve", "cheat trail" |
| Companion visual change with bond/biome | **Companion transformation** | "evolution", "skin", "form" |

Any term not covered here uses a `TBD_<concept>` placeholder and a request to AI-09.

## 5. Roster scope for v1

| Entity | v1 status | AI-06 responsibility | Source |
|---|---|---|---|
| **Nox** — companion | MUST (never cut) | full presentation: rig, animation, reactions, facet/VFX, transformations | Story Bible; PD-005; CUT list §4 "never cut" |
| **Mira**, **Orin** — human characters | MUST as *presence*; presentation fidelity is a decision (D6-01) | animation and visual presentation only; canon/dialogue AI-09 | Story Bible main cast |
| **The Weaver** — player | lightly defined, no avatar creator (CUT-014) | hands/interaction presentation only if AI-04 requires; no full body at v1 (PROPOSAL) | Story Bible; CUT-014 |
| **The Quiet Architect** | no creature/character asset at v1; revealed via relics/architecture (AI-05/AI-09) | none | Story Bible |
| **Ambient creatures** — biome-state indicators | PROPOSAL (D6-02): ≤ 2 species per shipped biome, non-interactive or observe-only, no combat | design, rig, behaviour presentation | Biome Bible "safe creature habitats"; Story Bible "creature behavior" as environmental storytelling |
| Second companion | REJECT for v1 | none | CUT-004 |

Ambient creature *existence* is not on the AI-01 cut list and is not in the complexity budget table; it therefore needs an explicit Product decision before any asset is produced (D6-02). Until then AI-06 plans for Nox only.

## 6. Companion presentation role lock (Nox)

Nox's presentation has five jobs. Each maps to a bond-bible contribution and is testable.

| Job | What the player sees | Must never |
|---|---|---|
| **Sense** | Attention shifts (head/facet turn, approach, hover) toward something the player has not yet noticed: a discovery, an unstable node, a compatible resonance. | Point at the *puzzle solution* or a specific move. Smart Assist is a separate, player-controlled system. |
| **React** | A readable reaction to puzzle states, biome health, relics, story revelations, mastery moments and player choices — the exact PD-005 whitelist. | React to anything outside the whitelist; react during active touch input in a way that occludes the cube. |
| **Accompany** | Idle presence during a solve: quiet, low-motion, peripheral; breathes, glances, settles. | Compete with the cube for attention; loop a distracting idle. |
| **Remember** | Selected memory-flag-driven variants (a different greeting after a specific chapter event) using AI-09's `CharacterMemory` / `NarrativeMemoryFlag`. | Branch into per-flag bespoke animation sets; memory changes *selection*, not asset count (DD-013). |
| **Transform** | Visible change at bond-stage transitions (6 stages: Meet → Trust → Shared discovery → Capability → Memory → Choice) and per-biome accent when a biome reaches a new tier. | Change on a grind counter; block progression; require a menu. |

Nox is **non-combat** and has **no health, damage or defeat state** (CUT-005, DD-007). Nox does not carry inventory UI (AI-07 owns any companion screen; CUT-011 forbids gift-grinding).

## 7. Reaction principles (grammar detail in `AI06_COMPANION_REACTION_MODEL_DRAFT.md`)

1. **Whitelisted triggers only.** Trigger classes are exactly: `puzzle_state`, `biome_health`, `relic`, `story_revelation`, `mastery_moment`, `player_choice` (PD-005; Bond Bible list). The validator fails on anything else.
2. **One grammar, learnable.** The same trigger class always uses the same *family* of motion so the player learns Nox's language within the first session (F10 clarity).
3. **Purpose before spectacle.** Every reaction declares a purpose: `confirm`, `warn`, `point`, `celebrate`, `comfort`, `question`. No purpose → no reaction.
4. **Intensity tiers** `subtle / clear / peak`, with `peak` reserved for mastery moments and story revelations; at most one `peak` per chapter beat (HYPOTHESIS, validate in Phase 06).
5. **Arbitration.** One companion reaction at a time; higher purpose priority interrupts lower; identical trigger within a cooldown window is coalesced. Never stack.
6. **Deterministic selection.** Given the same trigger payload, bond stage, memory flags and seed, the same reaction definition is chosen. No engine RNG in selection.
7. **Accessibility redundancy.** Every reaction has a reduced-motion variant and exposes an audio-hook slot (AI-08) and a dialogue-hook slot (AI-09) so meaning is never carried by motion alone.
8. **No text in assets.** Reactions reference localization keys (AI-09) by ID; they never embed strings.
9. **No silent fallback.** A missing reaction definition is a typed `ContentNotFound` failure surfaced to QA tooling, never an invisible no-op.
10. **Derived, not persisted.** Reactions are derived from domain state each time. AI-06 persists nothing; "has Nox reacted to X" is a narrative memory flag owned by AI-09 with store semantics from AI-02.

## 8. VFX direction and readability rules

### 8.1 VFX roles
| Role | Trigger owner | Examples (design-level) |
|---|---|---|
| Puzzle feedback cue | AI-04 (input) / AI-02 (state) | move confirm, axis lock indication, alignment achieved, solve |
| Restoration / transformation VFX | AI-02 `WorldStateEvent` | Tier 0→1 awakening, path/water/plant restoration witnessed |
| Instability VFX | AI-02 `WorldStateEvent` | collapse warning, unstable node, contained anomaly |
| Companion expression VFX | AI-06 reaction | facet glow shifts, trace when Nox senses |
| Discovery cue | AI-03 `DiscoveryDefinition` via AI-04 | a "something is here" shimmer that rewards observation, never a waypoint |
| Resonance cue (item/equipment) | AI-02 `EquipmentEffect` via AI-04 | item activation, affinity match, set synergy |

### 8.2 Hard rules (all mechanically checkable; see register `hardRules`)
| ID | Rule | Why |
|---|---|---|
| VFX-R1 | No VFX may occlude any interactive puzzle tile while the puzzle is in an input-accepting state. Metadata `occludesPuzzleDuringInput` must be `false`. | P1/P2; "VFX must not hide puzzle state" (phase prompt) |
| VFX-R2 | Every VFX and reaction carries meaning in ≥ 2 channels (e.g., shape/motion + color; motion + audio hook). Color alone is forbidden. | PD-011 color-independence |
| VFX-R3 | No element flashes more than 3 times per second; no full-screen luminance flash. Guidance: WCAG 2.1 SC 2.3.1 "Three Flashes or Below Threshold". | Photosensitivity safety |
| VFX-R4 | Every VFX and reaction definition declares a `reducedMotion` variant (which may be "static cue" but never "nothing"). | V7.1 §9; Gate B |
| VFX-R5 | Screen shake and haptics are *requested* via a feedback cue with an intensity class; AI-06 never moves the camera or fires haptics directly. User intensity settings (PD-011) scale or zero them. | Camera = AI-04; settings = AI-07 |
| VFX-R6 | No VFX asset ships without complete metadata (§11). Placeholders carry `placeholder: true` and are mechanically detectable. | ASSET_PIPELINE "No placeholder leakage" |
| VFX-R7 | A world transformation must be *witnessed*: the player sees before → transition → after in one continuous view; no hidden state swap. | P2 "I did that"; §3 Aliveness |
| VFX-R8 | Total simultaneous transient VFX during an interactive puzzle state ≤ 3 systems on screen (HYPOTHESIS until AI-11 budgets exist). | Readability; performance |

## 9. Animation and runtime feasibility (HYPOTHESES — owners AI-11/AI-12 measure and confirm in Phases 02–04)

| Topic | Starting hypothesis | Owner to verify | Status |
|---|---|---|---|
| Nox rig | Single skinned mesh, ≤ 32 bones, no blendshapes at v1; facial/facet expression via shader parameters and bone-driven facets | AI-06 authors; AI-11 measures | HYPOTHESIS |
| Nox LOD | 2 LODs (near/far); reactions authored for near LOD, degrade gracefully | AI-06 / AI-11 | HYPOTHESIS |
| Human characters | Fidelity tier is a Product/Art decision (D6-01): full 3D rig vs. limited-motion 3D vs. 2D portrait presence | AI-01 / AI-05 / AI-06 | DECISION NEEDED |
| Particle approach | Decide in Phase 02 between Unity's built-in particle system and VFX Graph. VFX Graph depends on compute-shader support, which cannot be assumed on the low device tier; the choice must follow AI-11's device matrix. | AI-06 proposes; AI-11 / AI-12 confirm | UNKNOWN until matrix exists (U6-01) |
| Particle budget | Per-tier caps (low/mid/high) for live particles and VFX draw calls | AI-11 | MISSING — numbers must be measured, not invented |
| Animation transitions | All state transitions blend; no pops (Gate C) | AI-06 | requirement |
| Frame budget share | AI-06 systems fit within AI-11's `PerformanceBudget` contract; no fixed ms share is claimed here | AI-11 | MISSING |
| Ambient creatures | Instanced or shared-rig where used; count per visible scene capped by AI-11 | AI-06 / AI-11 | depends on D6-02 |

No performance number in this document is a measurement. Every one is replaced when AI-11 publishes evidence.

## 10. Success criteria and measurable boundaries

| ID | Criterion | Limit / threshold | Measurement | Phase | Status |
|---|---|---|---|---|---|
| CVX-M01 | Companion recall | ≥ 50 % of Gold Slice players mention Nox unprompted (IGM-005c) | AI-10 playtest protocol | 06 | VERIFIED target (AI-01) |
| CVX-M02 | Reaction legibility | ≥ 70 % of playtesters correctly name the *purpose* (confirm/warn/point/celebrate/comfort/question) of a shown reaction without text | playtest card sort | 06 | HYPOTHESIS threshold |
| CVX-M03 | Companion reaction onset | visible onset ≤ 250 ms after trigger event; completes within AI-01's ≤ 2 s world-reaction boundary | frame-timed capture | 04–06 | HYPOTHESIS |
| CVX-M04 | Puzzle occlusion | 0 interactive tiles occluded by VFX/companion during input state | automated overlap check + review | 04 | requirement |
| CVX-M05 | Trigger whitelist compliance | 100 % of reaction definitions use the six PD-005 trigger classes | `tools/ai06_validate_phase00.py` (Phase 00 on fixture; later on production content) | 00+ | requirement |
| CVX-M06 | Reduced-motion coverage | 100 % of reaction and VFX definitions declare a reduced-motion variant | validator | 00+ | requirement |
| CVX-M07 | Color independence | 100 % of definitions declare ≥ 2 meaning channels | validator | 00+ | requirement |
| CVX-M08 | Flash safety | 0 assets exceeding 3 flashes/s | metadata + review | 04+ | requirement |
| CVX-M09 | Asset metadata completeness | 100 % of AI-06 assets carry all §11 fields; 0 `placeholder: true` in release | validator (Phase 02+) | 02+ | requirement |
| CVX-M10 | Reaction density | ≤ 1 active companion reaction at any time; ≤ 1 `peak` per chapter beat | runtime assertion + content lint | 05+ | HYPOTHESIS |
| CVX-M11 | Performance | within AI-11 `PerformanceBudget` on low/mid/high tiers | AI-11 profiling | 12 | depends on missing budgets |
| CVX-M12 | IP safety | 0 forbidden franchise terms in AI-06 artifacts; 0 review flags for franchise resemblance | validator term scan + human art review | 00+ | requirement |

## 11. Technical asset metadata (AI-06 assets)

Base fields are the verified `ASSET_PIPELINE.md` list; AI-06 adds the fields needed to enforce §8. Field names are DRAFT until Phase 01 freeze.

| Field | Source | Notes |
|---|---|---|
| `assetId` | ASSET_PIPELINE | naming `<type>_<system>_<semantic>_<variant>_<lod/version>`, e.g. `vfx_restoration_hearthwild_a_v01`, `char_companion_nox_base_v01` (examples, not released IDs) |
| `type`, `owner`, `source`, `license`, `version`, `targetPlatform`, `memoryEstimate`, `dependencies` | ASSET_PIPELINE | `owner` = `AI-06`; `license` must be explicit — no unlicensed third-party content |
| `placeholder` | AI-06 | boolean; must be `false` in release (VFX-R6) |
| `reducedMotionVariant` | AI-06 | assetId of the variant or `static_cue` descriptor (VFX-R4) |
| `occludesPuzzleDuringInput` | AI-06 | must be `false` for anything active in an input state (VFX-R1) |
| `meaningChannels` | AI-06 | list, length ≥ 2 (VFX-R2) |
| `flashRateMaxHz` | AI-06 | ≤ 3 (VFX-R3) |
| `applicability` | AI-06 | biome IDs / bond stages / tiers where valid (references AI-02/AI-09 IDs once released) |

## 12. AI-06 domain cut list (`CVX-CUT-###`, immutable once released)

| ID | Item | Status | Reason / gate |
|---|---|---|---|
| CVX-CUT-001 | Combat, damage, hit-reaction, death animation sets for any creature | REJECT | CUT-005, DD-007 |
| CVX-CUT-002 | Damage/health/attack VFX categories | REJECT | PD-002 effect categories exclude them |
| CVX-CUT-003 | Second companion presentation | REJECT | CUT-004 |
| CVX-CUT-004 | Companion cosmetics / accents (earned) | LATER | CUT-031 |
| CVX-CUT-005 | Facial blendshape rig for Nox | LATER | §9 hypothesis; shader/bone facets first |
| CVX-CUT-006 | Physics ragdoll / cloth on creatures | REJECT (v1) | mobile cost; no player value evidence |
| CVX-CUT-007 | Procedural creature generation / variation systems | REJECT | CUT-019 spirit (authored coherence) |
| CVX-CUT-008 | Emote wheel / gesture menu for the companion | REJECT | menu bloat; reactions are state-driven, not commanded |
| CVX-CUT-009 | Weather/atmosphere VFX systems | OUT OF SCOPE | AI-05 environment; AI-06 only layers transient transformation VFX |
| CVX-CUT-010 | Heavy screen-space post-processing as a VFX carrier on low tier | LATER / AI-11 decision | budget first |
| CVX-CUT-011 | Voice performance for creature/character reactions | LATER | AI-08/AI-09; vocalization hooks are reserved as slots only |
| CVX-CUT-012 | Ambient creatures beyond D6-02 approved count | BLOCKED on D6-02 | no asset until Product decision |

Cut order if AI-06 capacity is exceeded: CVX-CUT-012 ambient creatures → human-character fidelity tier (D6-01) → Nox biome accents → Nox bond-stage transformations beyond stage 3. **Never cut:** Nox base presentation, whitelisted reactions for puzzle_state/biome_health, restoration/instability VFX, reduced-motion variants.

## 13. Ownership boundaries and interfaces

### 13.1 Consumed (read-only)
`PuzzleState`, `WorldState`, `WorldStateEvent`, `EquipmentEffect` (AI-02); `NarrativeEvent`, `CharacterMemory`, `NarrativeMemoryFlag`, `LocalizationKey` (AI-09); `DiscoveryDefinition` (AI-03); `AccessibilityPreference` (AI-07); `PerformanceBudget` (AI-11). All are `TBD 1.0.0` in `PROGRESS.md`; AI-06 will work against fixtures until frozen.

### 13.2 Produced
`CompanionReaction` (presentation side) for AI-04 (runtime placement/orchestration), AI-08 (audio hook IDs), AI-09 (dialogue hook slots, memory-driven variants), AI-10 (validators, fixtures). Draft outline in `AI06_COMPANION_REACTION_MODEL_DRAFT.md`.

### 13.3 Boundary proposals requiring AI-13 confirmation (INFERRED, not decided)
| ID | Proposal |
|---|---|
| B6-01 | `CompanionReaction` split: AI-02 evaluates triggers deterministically from state and emits a trigger payload; AI-06 owns the reaction definitions and deterministic selection/presentation. (Matches AI-02 audit §9; decision D-04.) |
| B6-02 | Cube Pulse / Golden Trail: AI-06 authors the VFX assets and readability rules; AI-04 owns when/where they appear; AI-03 owns what hint data they present. (AI-02 register marks `hint_presentation` stateOwner AI-04, meaningOwner AI-03 — no VFX owner named: U6-03.) |
| B6-03 | Biome transformation: AI-05 owns persistent environment state visuals (materials, kits, lighting); AI-06 owns the *transient* restoration/instability VFX layered during the transition. |
| B6-04 | Camera shake / haptics: AI-06 emits a feedback cue with intensity class; AI-04 applies it under AI-07's accessibility preference. |

## 14. UNKNOWN / MISSING / CONFLICT / DECISION register

### Unknown / Missing
| ID | Item | Impact | Safe handling |
|---|---|---|---|
| U6-01 | AI-11 device matrix and `PerformanceBudget` do not exist | Cannot size particle/rig budgets | All numbers in §9 marked HYPOTHESIS; no asset production before matrix |
| U6-02 | No `integration` branch on the remote (only `ai-13-integration`) | PR target for this phase | Report to AI-13; AI-06 does not create governance branches |
| U6-03 | Exact semantics and VFX ownership of Cube Pulse / Golden Trail | Hint-cue authoring boundary | Proposal B6-02; no asset until AI-03/AI-04 define semantics (AI-02 U-02) |
| U6-04 | Source GDD ZIP not in repo | Cannot audit original creature/VFX concepts | Work from `SOURCE_GDD_NOTES.md` only; re-audit if added |
| U6-05 | Whether the Weaver's hands/body are ever rendered | Character asset scope | PROPOSAL §5: none at v1 unless AI-04 requires hands |
| U6-06 | Localization key format and `CharacterMemory` flag shape | Hook slot field types | Draft uses opaque string references; freeze in Phase 01 |

### Conflicts (reported, not resolved here)
| ID | Conflict | Sources | Resolution owner |
|---|---|---|---|
| C6-01 | Biome 6 "The Quiet Engine" vs Chapter 7 "The Silent Engine" (affects `applicability` biome references) | `WORLD_BIOME_BIBLE_V7.md` vs `STORY_BIBLE_V7.md`; already flagged by AI-01 §6.4 | AI-09 |
| C6-02 | Example CODEOWNERS/validator map `Assets/VFX/` to AI-04 and `Assets/Audio/` to AI-06, contradicting the 13-account model where AI-06 = VFX and AI-08 = audio | `07_GITHUB/CODEOWNERS_EXAMPLE.txt`, `07_GITHUB/scripts/validate_ownership.py` vs `00_CONTROL/13_AI_EXECUTION_MANUAL.md`; AI-02 C-06 overlaps | AI-12 / AI-13 |
| C6-03 | ID style: `creature.pollinator.bee` / `event.bloom` vs `game.bloom.started` / `companion.ability.used` | `MULTI_AI_OPERATING_MODEL.md` vs `CONTRACT_FIRST_RULES.md`; AI-02 C-03 | AI-13 (AI-06 draft keys follow dotted lowercase and will adopt the ruling) |

### Product / Human decisions needed (not guessed)
| ID | Decision | Why AI-06 needs it |
|---|---|---|
| D6-01 | Human character (Mira/Orin) presentation fidelity tier | Rig/animation scope and budget |
| D6-02 | Whether ambient creatures exist in v1 and their per-biome cap | Asset scope; complexity budget row does not exist yet |
| D6-03 | Confirm boundary proposals B6-01…B6-04 | Prevents duplicate presentation systems |
| D6-04 | Confirm `CVX-`, `CVX-CUT-`, `U6-/C6-/D6-/B6-` as AI-06 document-ID families in the governance registry | Stable referencing by other tracks |

## 15. Downstream usability

- **AI-02:** B6-01 defines what AI-06 expects in a trigger payload (see model doc §6); trigger classes are the six PD-005 names.
- **AI-03:** discovery/mastery signals should be expressible as `mastery_moment` / `puzzle_state` triggers; AI-06 will not infer mastery itself.
- **AI-04:** reactions expose `intensity`, `purpose`, `channels` and a feedback-cue request; AI-04 places Nox and applies shake/haptics (B6-04).
- **AI-05:** transformation VFX layers over AI-05 state visuals (B6-03); tier vocabulary 0–4 is shared.
- **AI-07:** `AccessibilityPreference` must include reduced motion, shake intensity, haptic intensity; AI-06 assets are built to respect them (VFX-R4/R5).
- **AI-08:** every reaction has an `audioHook` slot; AI-08 assigns cue IDs.
- **AI-09:** every reaction has a `dialogueHook` slot and optional `memoryFlags` selector; AI-06 needs the flag ID format (U6-06).
- **AI-10:** CVX-M05…M09 and CVX-M12 are validator-backed today via `tools/ai06_validate_phase00.py`; CVX-M01…M03 are playtest targets.
- **AI-11:** every §9 row is a measurement request.
- **AI-13:** D6-03/D6-04, U6-02, C6-02/C6-03 need governance rulings.

## 16. Change control

Additive clarification → patch. Changing a §8 hard rule, a §10 threshold, the roster in §5 or a cut status → minor version plus a decision entry. Adding combat, a second companion or franchise-evocative presentation → human approval gate (identity change). Follow `01_GOVERNANCE/CHANGE_CONTROL_AND_DECISION_LOG.md`.
