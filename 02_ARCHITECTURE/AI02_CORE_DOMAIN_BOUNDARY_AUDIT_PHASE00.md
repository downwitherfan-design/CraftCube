# AI-02 — Core Domain Boundary Audit (Phase 00: Product/IP Lock)

- Owner: AI-02 (Core Simulation / Systems Architecture)
- Phase: 00 — Product/IP Lock
- Status: DRAFT (Phase 00 preparation artifact; nothing in this document is a released contract)
- Companion artifacts:
  - `02_ARCHITECTURE/AI02_DOMAIN_CONCEPT_REGISTER_PHASE00.json` (machine-readable register)
  - `02_ARCHITECTURE/AI02_DOMAIN_CONCEPT_REGISTER_VALIDATOR.py` (validator / evidence)

## 0. Purpose and evidence labels

This document audits the source GDD (as available in the repository) for simulation concepts and
defines the domain boundaries required for a clean, deterministic pure-C# core.

Every statement is labeled using the Anti-Hallucination Addendum vocabulary:

- **VERIFIED** — read directly from a repository file (path cited).
- **INFERRED** — derived from VERIFIED facts; flagged for confirmation in Phase 01.
- **ASSUMED** — a working assumption that must become a documented decision before implementation.
- **UNKNOWN / MISSING / CONFLICT** — recorded, not resolved by guessing.

Nothing here introduces a runtime ID, API, schema field, package or command as a fact.
Concept keys in the register are `concept.*` draft keys for cross-track discussion only.

## 1. Source material actually available

| Source | Status | Notes |
|---|---|---|
| Source GDD ZIP | **MISSING** | Not present in the repository. Only `10_SOURCE_REFERENCE/SOURCE_GDD_NOTES.md` summarises it. |
| `10_SOURCE_REFERENCE/SOURCE_GDD_NOTES.md` | VERIFIED | 13 concept bullets + IP warning (Minecraft-specific names/creatures/presentation must not be carried over). |
| `02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md` | VERIFIED | Layering, domain module list, determinism rule, save design outline. |
| `00_CONTROL/CRAFTCUBE_GAME_MASTER_BIBLE.md` | VERIFIED | Protected gameplay hierarchy, core loop, non-goals. |
| v7 bibles in `01_PREPRODUCTION/` | VERIFIED | World/biome tiers, equipment families/slots, progression layers, quest/discovery, companion bond. |
| `00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md` | VERIFIED | Quest state machine, item identity card, complexity budget, save/remote-content safety. |
| `06_CONTRACTS/*` | VERIFIED | Contract families and owners; **no contract has a version or FROZEN/RELEASED status yet**. |

Consequence: this audit covers the GDD *as represented by the repository*. If the original ZIP is
later added, this audit must be re-run against it (see §10, item U-01).

## 2. Source GDD simulation-concept audit

Each concept from `SOURCE_GDD_NOTES.md` is classified by whether it belongs inside the pure-C# domain.

| # | GDD concept (VERIFIED) | Domain classification | Domain module(s) | Notes |
|---|---|---|---|---|
| 1 | cube / twisting puzzle gameplay | **CORE DOMAIN** | PuzzleTopology, PuzzleState, MoveEngine, ScrambleGenerator, Replay (VERIFIED module names, `TECHNICAL_BLUEPRINT.md`) | The protected center. Puzzle truth lives only here. |
| 2 | biome-driven world | **DOMAIN STATE** (semantics) / presentation outside | WorldState, BiomeState | Domain owns tier/state transitions; AI-05 owns how they look. |
| 3 | Vitality and Bloom/Collapse | **CORE DOMAIN RULE** | Vitality, Bloom/Collapse (VERIFIED module names) | Must be deterministic; event IDs `game.bloom.*` / `game.collapse.*` exist only as *examples* in `CONTRACT_FIRST_RULES.md` (not released). |
| 4 | special pieces / tiles | **SPLIT** | MoveEngine (legality), content schema (AI-03) | AI-03 defines what a tile means mechanically; AI-02 implements deterministic evaluation. Boundary must be frozen in Phase 01 (§10, C-04). |
| 5 | companions | **SPLIT** | Companion rules (state + trigger evaluation) | Domain owns bond stage and deterministic reaction *triggers*; AI-06 owns reactions/VFX; AI-09 owns meaning. |
| 6 | environmental interactions | **DOMAIN QUERY** | Capability model (`CanPlayerInteractWith(target, state, loadout)`, VERIFIED in `NARRATIVE_EQUIPMENT_SYSTEM_ARCHITECTURE_V7.md`) | Domain answers; AI-04 executes runtime interaction. |
| 7 | Smart Assist | **DOMAIN QUERY + METRIC** | Assist/Hint query, MasteryMetrics | Assist must be a *read-only* query over PuzzleState plus a recorded usage counter (mastery metric "optional assist usage", VERIFIED in `PROGRESSION_AND_MASTERY_BIBLE_V7.md`). Assist must never mutate puzzle truth. |
| 8 | Cube Pulse / Golden Trail | **OUTSIDE DOMAIN** (presentation of a domain hint) | none; consumes Assist/Hint query | INFERRED: these are presentation forms of hint data. Exact semantics **UNKNOWN** (U-02). |
| 9 | multiple chapters / three-act progression | **DOMAIN STATE** | Progression (ChapterProgress, QuestState container) | Story meaning is AI-09; progression state semantics are AI-02. |
| 10 | Unity 6 + URP architectural direction | **OUTSIDE DOMAIN** | — | Dependency rule: domain has no UnityEngine reference (VERIFIED). |
| 11 | pure C# simulation as a target | **DOMAIN PRINCIPLE** | all | Confirms the boundary strategy of this document. |
| 12 | data-driven content | **BOUNDARY PRINCIPLE** | content schemas consumed by domain | Domain consumes validated definitions; it never hardcodes content. |
| 13 | mobile performance budgets | **CONSTRAINT** (AI-11 owner) | all | Domain must be allocation-conscious; budgets are hypotheses until measured (VERIFIED). |

### IP-safety implication for the domain (VERIFIED requirement, `SOURCE_GDD_NOTES.md`)

The domain must not encode Minecraft-specific names, creature types or block taxonomies in
identifiers, enums, type names or fixture data. Domain identifiers use CraftCube/v7 terminology
(Weaver, Axis Loom, biome names from `WORLD_BIOME_BIBLE_V7.md`) only via data, never via code
constants. Terminology ownership is AI-09; the domain refers to content by opaque stable IDs.

## 3. Additional simulation concepts introduced by v7 / v7.1 (VERIFIED sources)

These do not appear in the source GDD notes but are required by v7 documents and fall inside AI-02
state ownership per `04_AI_ACCOUNTS/AI-02_Track.md` and `00_CONTROL/13_AI_EXECUTION_MANUAL.md`.

| Concept | Source | Domain responsibility |
|---|---|---|
| World Memory / biome transformation tiers 0–4 | `WORLD_BIOME_BIBLE_V7.md` | Deterministic tier transitions; explicit, save-safe state. |
| Biome state set (restored, unstable, discovered, mastered, story, companion, optional secret) | `WORLD_BIOME_BIBLE_V7.md` | Explicit state flags per biome; no implicit/derived-only persistence. |
| Item ownership, equipped state, charges/durability, upgrades, item memory | `EQUIPMENT_ITEM_MASTER_BIBLE_V7.md`, `ITEM_EQUIPMENT_PROGRESSION.md` | Inventory & Equipment state; versioned and migration-safe. |
| Loadout slots (suggested: Core Resonator, Tool, Companion Module, Field Module) | `EQUIPMENT_ITEM_MASTER_BIBLE_V7.md` | Slot count is a **Product/UX decision** (VERIFIED) — domain must treat slot layout as data (D-02). |
| Upgrade branches (Precision, Versatility, Efficiency, Discovery) | `EQUIPMENT_ITEM_MASTER_BIBLE_V7.md` | Upgrade state as branch selections, not level integers. |
| Puzzle Affinity / Resonance | `ITEM_EQUIPMENT_PROGRESSION.md`, `EQUIPMENT_ITEM_MASTER_BIBLE_V7.md` | Deterministic evaluation of affinity conditions over (equipment, puzzle state, biome, world condition). Affinity unlocks interactions; it never alters puzzle truth (DD-002). |
| Capability query | `NARRATIVE_EQUIPMENT_SYSTEM_ARCHITECTURE_V7.md` | Pure function over (target, state, loadout). |
| Narrative flags / character memory (controlled flag set) | `V7_1_WORLDCLASS_UPGRADE.md` §3.1, DD-013 | AI-02 owns the deterministic **flag store semantics**; AI-09 owns flag IDs and meaning (C-01). |
| Quest state machine DISCOVERED→ACCEPTED→ACTIVE→BLOCKED(opt)→RESOLVED→CONSEQUENCE APPLIED | `V7_1_WORLDCLASS_UPGRADE.md` §4 | AI-02 owns the **state container/transition legality**; AI-03 owns quest definitions (C-02). |
| Discovery ledger | `DISCOVERY_AND_REPLAYABILITY.md` | Persisted discovery records; deterministic or controlled-seed only. |
| Reward application | `V7_MASTER_CONTRACT_REGISTER.md` (RewardDefinition owner AI-03, AI-02 consumer) | AI-02 applies rewards to state deterministically; AI-03 defines them. |
| Resource ledger | `WORLDCLASS_CONTRACTS_V7_1.md` (owner AI-02) | Readable sources/sinks; existence of any currency is **not assumed** (D-03). |
| Companion bond stages (Meet→Trust→Shared discovery→Capability→Memory→Choice) | `COMPANION_BOND_BIBLE_V7.md` | Bond stage as ordered state; reaction *trigger* evaluation deterministic. |
| Mastery metrics (completion, move efficiency, assist usage, consistency, challenge completion, discovery completion) | `PROGRESSION_AND_MASTERY_BIBLE_V7.md` | Recorded as separate dimensions; never collapsed into one score (VERIFIED rule). |
| Deterministic challenge seeds / daily seed | `TECHNICAL_BLUEPRINT.md`, `PROGRESSION_AND_MASTERY_BIBLE_V7.md` | Seed + move list + `rulesetVersion` ⇒ identical result. |
| Competitive result validation | `V7_1_WORLDCLASS_UPGRADE.md` §11 | Domain must expose legal-move/state validation so AI-13's CompetitiveResult can verify replays offline. |

## 4. Domain boundary definition

### 4.1 Layering (VERIFIED, `TECHNICAL_BLUEPRINT.md`)

`Presentation → Application → Domain/Simulation → Data → Platform Services`

The **Domain/Simulation** layer is AI-02's production path. Dependency rule (VERIFIED): the domain
knows nothing about Unity, Android, networking, input devices or UI.

### 4.2 Hard boundary rules for the pure-C# domain (INFERRED from VERIFIED rules; to be frozen in Phase 01)

1. **No engine references.** No `UnityEngine`, `UnityEditor` or platform SDK types in the domain assembly.
2. **No ambient nondeterminism.** No wall-clock reads, no unseeded random, no thread-timing dependence,
   no culture-dependent string/number formatting inside rules. Time and seeds are *inputs*.
3. **Integer/fixed-point rule state.** Puzzle truth and any rule that feeds an outcome (Vitality,
   Bloom/Collapse thresholds, affinity conditions) use integer or fixed-point arithmetic so results are
   bit-identical across devices. (ASSUMED — requires Phase 01 confirmation, D-05.)
4. **Commands in, state/events out.** The domain receives validated commands from the Application layer
   (VERIFIED command contract, `INTERACTION_CONTRACTS.md`) and returns results plus typed failure reasons
   (`InvalidMove`, `LockedAxis`, `ContentNotFound`, `SaveMigrationFailed` — VERIFIED list). Presentation
   never mutates domain state.
5. **Content by opaque ID.** The domain never contains content constants (biome names, item names, story
   text, localization keys). It consumes validated definitions supplied by data.
6. **Meaning stays outside.** Narrative meaning (AI-09), puzzle content usage (AI-03), reactions (AI-06),
   UX (AI-07), audio (AI-08) consume domain state; the domain never encodes what a flag *means*.
7. **Equipment cannot touch puzzle truth.** Equipment/affinity/capability produce *information, access,
   interaction, efficiency, risk management, exploration, companion synergy, puzzle strategy* effects
   (VERIFIED effect categories) but never modify permutation state outside the move contract (DD-002).
8. **Every persisted structure is versioned.** No unversioned live save data (VERIFIED, `SAVE_MIGRATION_POLICY.md`).

### 4.3 Bounded contexts inside the domain

The following bounded contexts are proposed. Each maps to one or more contract families already
listed in `06_CONTRACTS/V7_MASTER_CONTRACT_REGISTER.md` / `WORLDCLASS_CONTRACTS_V7_1.md`.
No new contract family is introduced.

| Bounded context | Responsibility | Contract families (VERIFIED names) | Determinism class | Persistence |
|---|---|---|---|---|
| **Puzzle Core** | topology, permutation state, move legality, scramble from seed, solve detection, undo/redo, replay | PuzzleState | STRICT (bit-identical) | replay metadata; in-progress puzzle state (D-06) |
| **Puzzle Rules** | Vitality, Bloom/Collapse thresholds, special-tile rule evaluation, assist/hint query, mastery metric recording | PuzzleState, WorldStateEvent (producer side) | STRICT | mastery records |
| **World Memory** | biome tier 0–4, explicit biome state flags, world-consequence records | WorldState, WorldStateEvent | STRICT | yes |
| **Progression** | chapter progress, quest state container + transition legality | QuestState (container semantics only — see C-02) | STRICT | yes |
| **Inventory & Equipment** | ownership, quantities, equipped loadout, charges/cooldowns, upgrade branch state, item memory | ItemIdentity, ItemDefinition (consumed), EquipmentDefinition (consumed), UpgradeDefinition, ResourceLedger | STRICT | yes |
| **Affinity & Capability** | affinity condition evaluation, capability query, effect eligibility | EquipmentEffect, CC.PUZZLE.AFFINITY | STRICT, pure functions | none (derived) |
| **Narrative State Store** | flag store semantics: set-once vs. counter vs. ordered, idempotency, save | NarrativeMemoryFlag / CharacterMemory (store semantics only — see C-01) | STRICT | yes |
| **Discovery Ledger** | discovery records, controlled-seed secret evaluation | DiscoveryDefinition (consumed) | STRICT or CONTROLLED-SEED | yes |
| **Companion State** | bond stage, deterministic reaction trigger evaluation | CompanionReaction (trigger side only) | STRICT | yes |
| **Persistence** | save schema versioning, atomic write contract, deterministic idempotent migrations, corruption classification | SaveSchema | STRICT | is the persistence |
| **Determinism Infrastructure** | seeded PRNG abstraction, `rulesetVersion`, state hashing for replay/competitive validation | PuzzleState, CompetitiveResult (validation input) | STRICT | rulesetVersion stored with replays (VERIFIED) |

### 4.4 Explicitly outside the domain (owned elsewhere)

| Concern | Owner | Domain touchpoint |
|---|---|---|
| Rendering, camera, cube view, animation | AI-04 / AI-05 / AI-06 | read-only presentation state |
| Touch/gesture → command translation | AI-04 | Application-layer command contract |
| HUD, inventory UI, equipment UX, accessibility preferences | AI-07 | state + commands; AccessibilityPreference is not domain state |
| Audio cues | AI-08 | domain events |
| Story text, dialogue, localization keys, flag meaning | AI-09 | opaque flag/event IDs |
| Puzzle content definitions, difficulty, rewards, discoveries, quest definitions | AI-03 | consumed definitions |
| Tests/validators (beyond domain unit tests) | AI-10 | domain fixtures |
| Performance budgets | AI-11 | measured, not guessed |
| Build, telemetry, remote content manifest | AI-12 | domain is offline-first; remote content is optional input |
| Contract governance, CompetitiveResult, integration | AI-13 | validation hooks |

## 5. Deterministic core: measurable boundaries (proposed acceptance criteria for Phase 01/03)

These are *proposals* for the Phase 01 freeze. They are measurable and do not presume any tool result.

| ID | Measurable boundary | How it will be evidenced |
|---|---|---|
| MB-01 | Same seed + same move list + same `rulesetVersion` ⇒ identical state hash on every run | golden replay test with stored hash fixture |
| MB-02 | Domain assembly contains zero references to `UnityEngine`/`UnityEditor`/platform SDKs | assembly reference check in CI (AI-12 executes, AI-02 supplies rule) |
| MB-03 | No domain rule reads wall-clock or unseeded random | static search rule + code review checklist |
| MB-04 | Every serialized domain structure carries `schemaVersion` | schema fixture validation |
| MB-05 | Save round-trip: serialize → deserialize → identical state hash | unit test with representative fixtures per released schema |
| MB-06 | Migration determinism: applying migration N twice equals applying once (idempotent) | migration unit test |
| MB-07 | Corrupted/truncated/missing-field/future-version saves yield typed `SaveMigrationFailed`, never silent default state | negative fixtures (VERIFIED requirement, `SAVE_MIGRATION_POLICY.md`) |
| MB-08 | No equipment/affinity/capability path can produce a permutation change outside `Apply(Move)` | property test: puzzle state hash invariant across all non-move operations |
| MB-09 | Quest transitions outside the allowed graph are rejected with a typed failure | state-machine unit test |
| MB-10 | Narrative flag set operations are idempotent for set-once flags | unit test |
| MB-11 | Mastery dimensions are stored separately (no single aggregate score field) | schema review |
| MB-12 | Core loop is playable with story/equipment/companion state disabled (DD-001) | fixture profile with empty v7 state; puzzle tests still pass |

## 6. Save-domain scope (audit of what must persist)

VERIFIED baseline (`TECHNICAL_BLUEPRINT.md`): `schemaVersion`, `profileId`, `chapterProgress`,
collection state, settings, economy, replay metadata when required.

VERIFIED v7/v7.1 additions (`NARRATIVE_ITEM_ARCHITECTURE.md`, `ITEM_EQUIPMENT_PROGRESSION.md`,
`V7_1_WORLDCLASS_UPGRADE.md`): narrative flags, discoveries, item ownership, equipped state,
charges/durability, upgrade state, world consequences, quest state (with replay behavior), item memory.

Observations for Phase 01:

- "economy" (baseline) vs. "a soft/hard/premium currency layer is not assumed" (v7.1 §6) is a
  **CONFLICT** to resolve as a Product decision (D-03). The domain should reserve a `ResourceLedger`
  slot whose *content* may legitimately be empty.
- "settings" is not domain state; it belongs to AI-07 (AccessibilityPreference) and platform services.
  The domain save contract should reference it as an opaque, separately versioned block (INFERRED).
- World Memory must be **bounded** ("Memory with restraint", v7.1 §2.4): the persisted world-consequence
  set must be a finite, enumerated flag/tier set, not an unbounded event log.

## 7. Complexity budget baseline (v7.1 §16)

Counts this audit establishes as the Phase 00 baseline for AI-02-owned state. All are ceilings
proposed for Phase 01, not implementation facts.

| Tracked quantity | Phase 00 baseline | Source |
|---|---|---|
| Biome transformation tiers | 5 (Tier 0–4) | VERIFIED, `WORLD_BIOME_BIBLE_V7.md` |
| Biome state flag kinds | 7 (restored, unstable, discovered, mastered, story, companion, optional secret) | VERIFIED |
| Quest states | 6 (BLOCKED optional) | VERIFIED, `V7_1_WORLDCLASS_UPGRADE.md` §4 |
| Equipment slots | 4 suggested — **Product decision pending** | VERIFIED as suggestion only |
| Upgrade branches | 4 named branches suggested | VERIFIED as suggestion only |
| Item families | 6 (Relics, Tools, Resonators, Companion Gear, Field Modules, Memory Collectibles) | VERIFIED, `EQUIPMENT_ITEM_MASTER_BIBLE_V7.md` — **CONFLICT** with the 6-family list in `ITEM_EQUIPMENT_PROGRESSION.md` (Story Relics, Tools, Resonance Equipment, Companion Items, Resources, Collectibles); see C-05 |
| Companion bond stages | 6 | VERIFIED, `COMPANION_BOND_BIBLE_V7.md` |
| Mastery metric dimensions | 6 candidates | VERIFIED |
| Currencies | 0 assumed | VERIFIED, v7.1 §6 |
| Bounded contexts in domain | 11 (this document) | INFERRED |

## 8. Duplicate-system check (SEARCH → REUSE → EXTEND → CREATE ONLY IF ABSENT)

Search performed over all `*.md` in the repository (excluding phase prompt copies) for:
`vitality|bloom|collapse|cube pulse|golden trail|smart assist|synergy|scramble|rulesetVersion|schemaVersion|seed`.

Result (VERIFIED):
- Module names already exist in `TECHNICAL_BLUEPRINT.md` and are **reused**, not renamed.
- Contract family names already exist in `06_CONTRACTS/` and are **reused**; this audit adds none.
- Two overlapping event naming examples exist: `event.bloom` (`MULTI_AI_OPERATING_MODEL.md`) and
  `game.bloom.started` (`CONTRACT_FIRST_RULES.md`). Both are labelled examples; neither is released.
  Recorded as C-03 for AI-13 to pick one convention in Phase 01. This audit creates **no** event IDs.
- Pre-v7 example IDs (`biome.overworld.meadow`, `chapter.01.meadow`) use terminology superseded by the
  v7 biome bible (Hearthwild etc.). Recorded as C-06; no action by AI-02.

## 9. Ownership split proposals requiring AI-13 confirmation

| Contract family | Registered primary owner (VERIFIED) | Proposed split (INFERRED) |
|---|---|---|
| QuestState | AI-03 | AI-03: quest definitions, prerequisites, rewards, consequences. AI-02: state container, transition legality, persistence, replay behavior. |
| NarrativeMemoryFlag / CharacterMemory | AI-09 | AI-09: flag IDs, meaning, scope, which events set them. AI-02: store semantics (set-once/counter/ordered), idempotency, save/migration. |
| DiscoveryDefinition | AI-03 | AI-03: what a discovery is and how it is signalled. AI-02: discovery ledger record semantics and controlled-seed evaluation. |
| RewardDefinition | AI-03 | AI-03: reward content. AI-02: deterministic application to inventory/world/progression state. |
| CompanionReaction | AI-06 | AI-06: reaction presentation. AI-02: deterministic trigger evaluation from state. |
| WorldStateEvent | AI-13 governance + AI-02 domain | unchanged; AI-02 is producer of event payload semantics, AI-13 governs ID registry. |

These splits follow the rule "Never embed narrative meaning directly into runtime domain logic"
(phase prompt) and "AI-09 owns narrative meaning and terminology; AI-02 owns deterministic state"
(`00_MASTER_CONTROL_PROMPT.md`). They are proposals until AI-13 records a decision.

## 10. UNKNOWN / MISSING / CONFLICT / DECISION register

### Unknown / Missing

| ID | Item | Impact | Safe handling |
|---|---|---|---|
| U-01 | Source GDD ZIP is not in the repository | Audit covers only the summary notes and derived bibles | Re-audit if the ZIP is added; no invention of GDD details. |
| U-02 | Exact semantics of "Cube Pulse" and "Golden Trail" | Cannot finalize assist/hint query shape | Treat as presentation of a hint query; AI-03/AI-04 to define in Phase 01. |
| U-03 | Puzzle topology set (which cube sizes/shapes are in scope) | PuzzleTopology contract shape | AI-03 Phase 00 output ("puzzle vocabulary, mechanic families") is the input; AI-02 waits for the definition, not the implementation. |
| U-04 | Whether in-progress puzzle state must survive app kill (interruption stability is a quality requirement) | SaveSchema scope | Recorded as D-06 for Product. |
| U-05 | `integration` branch does not exist (only `ai-13-integration`) | PR target of this phase | Report to AI-13; do not create governance branches from AI-02. |

### Conflicts

| ID | Conflict | Sources | Proposed resolution owner |
|---|---|---|---|
| C-01 | Narrative flag ownership: AI-09 (contract register) vs. "AI-02 defines deterministic semantics for narrative flags" (AI-02 track) | `WORLDCLASS_CONTRACTS_V7_1.md`, `04_AI_ACCOUNTS/AI-02_Track.md` | AI-13 (split in §9) |
| C-02 | QuestState ownership: AI-03 (contract register) vs. "quest state" in AI-02 v7.1 priority | `WORLDCLASS_CONTRACTS_V7_1.md`, phase prompt | AI-13 (split in §9) |
| C-03 | Event naming convention examples `event.bloom` vs `game.bloom.started` | `MULTI_AI_OPERATING_MODEL.md`, `CONTRACT_FIRST_RULES.md` | AI-13 |
| C-04 | Special-tile boundary: "mechanic schemas" (AI-03) vs "deterministic puzzle engine" (AI-02) | `PHASE_MATRIX.md`, tracks | AI-13 in Phase 01 freeze |
| C-05 | Two different six-item-family lists | `EQUIPMENT_ITEM_MASTER_BIBLE_V7.md` vs `ITEM_EQUIPMENT_PROGRESSION.md` | AI-01 / AI-09 (domain treats family as data; no code impact) |
| C-06 | Branch naming and CODEOWNERS numbering contradict the 13-account model | `GITHUB_MODEL.md`, `CODEOWNERS_EXAMPLE.txt`, `validate_ownership.py` vs actual branches and `13_AI_EXECUTION_MANUAL.md` | AI-12 / AI-13 |
| C-07 | Save baseline includes "economy"; v7.1 says currency layer not assumed | `TECHNICAL_BLUEPRINT.md` vs `V7_1_WORLDCLASS_UPGRADE.md` §6 | AI-01 (D-03) |

### Product / Human decisions needed (not guessed)

| ID | Decision | Why AI-02 needs it |
|---|---|---|
| D-01 | Confirm the 11 bounded contexts (§4.3) as the Phase 01 freeze scope | Determines contract set to freeze |
| D-02 | Equipment slot count and slot kinds | Loadout state shape (domain will treat as data regardless) |
| D-03 | Whether any resource/currency exists in the Vertical Slice | ResourceLedger content |
| D-04 | Ownership splits in §9 | Prevents duplicate state systems |
| D-05 | Integer/fixed-point mandate for all outcome-affecting rules | Cross-device determinism guarantee |
| D-06 | Must in-progress puzzle state be persisted across app kill | SaveSchema scope and size |
| D-07 | Which mastery dimensions are recorded in v1 | Persisted mastery record shape |

## 11. Downstream usability

- AI-03 can use §2 rows 4/7/8 and §9 to draft mechanic schemas against clear boundaries.
- AI-09 can use §9 and rule 4.2(6) to design the controlled flag set knowing the store semantics AI-02 will provide.
- AI-07 can rely on §4.4: UI consumes state/commands only; no rule logic in UI.
- AI-10 can seed its test plan from §5 (MB-01…MB-12) — each is a concrete, evidence-producing check.
- AI-12 can plan the assembly-reference CI rule (MB-02).
- AI-13 receives an explicit conflict/decision list (§10) instead of silent reconciliation.
- The JSON register lets any track script-check that a concept it references has an owner and a
  determinism/persistence class.

## 12. What this audit deliberately does NOT do

- Does not create C# code, assemblies, folders under `src/`, or tests (Phase 01 freezes contracts;
  Phase 02/03 bootstrap and implement).
- Does not create, rename or release any runtime ID, event ID, schema field or version number.
- Does not edit files owned by other accounts.
- Does not resolve conflicts by choosing a side; it routes them.

## 13. Rollback

Delete the three `02_ARCHITECTURE/AI02_*` files and revert the AI-02 section of `00_CONTROL/PROGRESS.md`.
No other file, contract or ID depends on them.
