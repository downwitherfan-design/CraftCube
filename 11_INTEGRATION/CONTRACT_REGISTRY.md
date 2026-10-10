# Contract Registry (rendered view)

**GENERATED FILE — do not hand-edit.** Source of truth: `11_INTEGRATION/registry/contract_registry.json`. Regenerate with `python3 11_INTEGRATION/scripts/validate_registry.py --render`.

Registry schema `1.0.0` · owner `AI-13` · phase `00` · baseline `584141c` · 27 contracts · statuses consumable by downstream tracks: `FROZEN`, `RELEASED`

## Contracts

| ID | Display name | Owner | Evidence | Consumers | Status | Version | Freeze target | Aliases | Linked CR/OD |
|---|---|---|---|---|---|---|---|---|---|
| `CC.ACCESSIBILITY.PREFERENCE` | AccessibilityPreference | AI-07 | VERIFIED | AI-04, AI-08, AI-10, AI-11 | DRAFT | — | Phase 01 | AccessibilityPreference | — |
| `CC.BIOME.STATE` | BiomeState | AI-02 | INFERRED | UNKNOWN | DRAFT | — | Phase 01 | BiomeState | CR-0006 |
| `CC.COMPANION.REACTION` | CompanionReaction | AI-06 | VERIFIED | AI-04, AI-08, AI-09, AI-10 | DRAFT | — | Phase 01 | CompanionReaction | — |
| `CC.COMPETITIVE.RESULT` | CompetitiveResult | AI-13 | VERIFIED | AI-10, AI-12, AI-13 | DRAFT | — | Phase 13 | CompetitiveResult | — |
| `CC.DISCOVERY.DEFINITION` | DiscoveryDefinition | AI-03 | VERIFIED | AI-04, AI-07, AI-09, AI-10, AI-12 | DRAFT | — | Phase 01 | DiscoveryDefinition | CR-0005 |
| `CC.EQUIPMENT.DEFINITION` | EquipmentDefinition | AI-02 | VERIFIED | AI-03, AI-04, AI-07, AI-09, AI-10, AI-11, AI-12 | DRAFT | — | Phase 01 | EquipmentDefinition | — |
| `CC.EQUIPMENT.EFFECT` | EquipmentEffect | AI-02 | VERIFIED | AI-03, AI-04, AI-05, AI-06, AI-07, AI-10 | DRAFT | — | Phase 01 | EquipmentEffect | — |
| `CC.ITEM.ACQUISITION` | ItemAcquisition | AI-02 | INFERRED | UNKNOWN | DRAFT | — | Phase 01 | ItemAcquisition | CR-0006 |
| `CC.ITEM.DEFINITION` | ItemDefinition | AI-02 | VERIFIED | AI-03, AI-07, AI-09, AI-10, AI-11, AI-12 | DRAFT | — | Phase 01 | ItemDefinition | — |
| `CC.ITEM.IDENTITY` | ItemIdentity | AI-02 | VERIFIED | AI-03, AI-07, AI-09, AI-10, AI-11, AI-12 | DRAFT | — | Phase 01 | ItemIdentity | — |
| `CC.ITEM.UPGRADE` | UpgradeDefinition | AI-02 | VERIFIED | AI-03, AI-07, AI-10, AI-11 | DRAFT | — | Phase 01 | UpgradeDefinition | — |
| `CC.LOCALIZATION.KEY` | LocalizationKey | AI-09 | VERIFIED | AI-07, AI-08, AI-12 | DRAFT | — | Phase 01 | LocalizationKey, Localization keys, localization master keys | — |
| `CC.NARRATIVE.CHAPTER` | StoryChapter | AI-09 | INFERRED | UNKNOWN | DRAFT | — | Phase 01 | StoryChapter, ChapterSpec | CR-0006 |
| `CC.NARRATIVE.CHARACTER_MEMORY` | CharacterMemory | AI-09 | VERIFIED | AI-02, AI-06, AI-07, AI-08, AI-10 | DRAFT | — | Phase 01 | CharacterMemory | — |
| `CC.NARRATIVE.EVENT` | NarrativeEvent | AI-09 | VERIFIED | AI-04, AI-07, AI-08, AI-10, AI-13 | DRAFT | — | Phase 01 | NarrativeEvent | — |
| `CC.NARRATIVE.MEMORY_FLAG` | NarrativeMemoryFlag | AI-09 | VERIFIED | AI-02, AI-07, AI-09, AI-10 | DRAFT | — | Phase 01 | NarrativeMemoryFlag | — |
| `CC.PERFORMANCE.BUDGET` | PerformanceBudget | AI-11 | VERIFIED | AI-02, AI-03, AI-04, AI-05, AI-06, AI-07, AI-08, AI-12 | DRAFT | — | Phase 01 | PerformanceBudget | — |
| `CC.PUZZLE.AFFINITY` | PuzzleAffinity | AI-02 | VERIFIED | UNKNOWN | DRAFT | — | Phase 01 | PuzzleAffinity | CR-0006 |
| `CC.PUZZLE.STATE` | PuzzleState | AI-02 | VERIFIED | AI-03, AI-04, AI-05, AI-06, AI-10, AI-13 | DRAFT | — | Phase 01 | PuzzleState | — |
| `CC.QUEST.STATE` | QuestState | AI-03 | VERIFIED | AI-02, AI-07, AI-09, AI-10, AI-13 | DRAFT | — | Phase 01 | QuestState | — |
| `CC.REMOTE.CONTENT_MANIFEST` | RemoteContentManifest | AI-12 | VERIFIED | AI-02, AI-10, AI-11, AI-13 | DRAFT | — | Phase 13 | RemoteContentManifest | — |
| `CC.RESOURCE.LEDGER` | ResourceLedger | AI-02 | VERIFIED | AI-03, AI-07, AI-10, AI-11, AI-12 | DRAFT | — | Phase 01 | ResourceLedger | OD-0006 |
| `CC.REWARD.DEFINITION` | RewardDefinition | AI-03 | VERIFIED | AI-02, AI-07, AI-09, AI-10, AI-12 | DRAFT | — | Phase 01 | RewardDefinition | — |
| `CC.SAVE.SCHEMA` | SaveSchema | AI-02 | VERIFIED | AI-07, AI-10, AI-11, AI-12, AI-13 | DRAFT | — | Phase 01 | SaveSchema, Save schema | — |
| `CC.TELEMETRY.EVENT` | TelemetryEvent | AI-12 | VERIFIED | AI-01, AI-10, AI-11, AI-13 | DRAFT | — | Phase 01 | TelemetryEvent, Analytics event names | — |
| `CC.WORLD.STATE` | WorldState | AI-02 | VERIFIED | AI-05, AI-06, AI-09, AI-10, AI-13 | DRAFT | — | Phase 01 | WorldState | — |
| `CC.WORLD.STATE_EVENT` | WorldStateEvent | AI-02 | VERIFIED | AI-03, AI-05, AI-06, AI-08, AI-09, AI-10 | DRAFT | — | Phase 01 | WorldStateEvent | OD-0003 |

## Notes and protected rules

### `CC.BIOME.STATE`
- Note: Not present in either register table. Owner inferred from 'AI-02 deterministic state semantics'. Relationship to CC.WORLD.STATE (sub-schema vs. separate) must be declared by AI-02 in Phase 01. Biome transformation tiers 0-4 are defined in 01_PREPRODUCTION/WORLD_BIOME_BIBLE_V7.md.

### `CC.COMPETITIVE.RESULT`
- Note: Only contract whose semantic owner is AI-13. Deferred to Phase 13 (Services / Optional Online) per 00_CONTROL/MASTER_ROADMAP.md; not needed for Gold Slice. Trust levels Local / Device-verified / Server-verified per 02_ARCHITECTURE/ANALYTICS_PRIVACY_COMPETITIVE_ARCHITECTURE.md.

### `CC.DISCOVERY.DEFINITION`
- Note: 06_CONTRACTS/NARRATIVE_ITEM_CONTRACTS.md lists CC.DISCOVERY.EVENT. Whether that is the same contract (definition) or a separate runtime event is UNCONFIRMED. Not merged as an alias; AI-03 must declare in Phase 01 (CR-0005).

### `CC.EQUIPMENT.EFFECT`
- Protected rule: DD-002: effects may not mutate puzzle truth outside the contract.

### `CC.ITEM.ACQUISITION`
- Note: Not present in either register table. Owner inferred from AI-02 'item/equipment state rules'. Overlap with CC.REWARD.DEFINITION (AI-03) must be resolved in Phase 01. Idempotency requirement from 08_QA_RELEASE/STORY_ITEM_TEST_MATRIX.md.

### `CC.ITEM.IDENTITY`
- Note: Item identity card fields are listed in 00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md section 5.1. Relationship to CC.ITEM.DEFINITION (same schema vs. companion metadata) must be declared by AI-02 in Phase 01 to avoid a duplicate semantic system (CR-0006).

### `CC.NARRATIVE.CHAPTER`
- Note: Not present in either register table. Owner inferred from AI-09 ownership of chapters/narrative beats. Consumers UNKNOWN. ChapterSpec in TECHNICAL_BLUEPRINT.md may be the same or an AI-03 content schema wrapping it.

### `CC.NARRATIVE.CHARACTER_MEMORY`
- Protected rule: DD-013: controlled flag set, no branch explosion.

### `CC.NARRATIVE.MEMORY_FLAG`
- Note: Relationship to CC.NARRATIVE.CHARACTER_MEMORY (flag = unit, memory = aggregate?) must be declared by AI-09 in Phase 01 to avoid a duplicate semantic system (CR-0006).

### `CC.PERFORMANCE.BUDGET`
- Note: Source says consumers = 'all runtime tracks'. Expanded to the explicit runtime-facing accounts; AI-11 may correct in Phase 01.

### `CC.PUZZLE.AFFINITY`
- Note: Owner verified via ACCOUNT_MATRIX v7 expanded responsibility: AI-02 'world memory, item/equipment state, affinity, persistence'. Consumers UNKNOWN until declared.

### `CC.QUEST.STATE`
- Protected rule: 00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md section 4 state machine: DISCOVERED -> ACCEPTED -> ACTIVE -> BLOCKED(optional) -> RESOLVED -> CONSEQUENCE APPLIED.

### `CC.REMOTE.CONTENT_MANIFEST`
- Protected rule: V7_1 section 12: schema version, content version, compatibility range, checksum, rollback, safe disable.

### `CC.RESOURCE.LEDGER`
- Protected rule: DD-014 and V7_1 section 6: no currency layer is assumed; existence requires a validated product decision (OD-0006).

### `CC.REWARD.DEFINITION`
- Protected rule: DD-006: critical progression rewards must have a deterministic path.

### `CC.SAVE.SCHEMA`
- Protected rule: 06_CONTRACTS/SAVE_MIGRATION_POLICY.md applies in full.

### `CC.TELEMETRY.EVENT`
- Protected rule: DD-015: never required by the offline core.

### `CC.WORLD.STATE_EVENT`
- Note: Source register says 'AI-13 governance + AI-02 domain'. Recorded as owner AI-02 (domain semantics), governance AI-13, to satisfy the single-owner rule in 04_AI_ACCOUNTS/ACCOUNT_MATRIX.md.

## Contract families named in policy docs but not yet registered

| Family | Proposed owner | Evidence | Action |
|---|---|---|---|
| Simulation API (IPuzzleEngine) | AI-02 | INFERRED | AI-02 registers a CC.PUZZLE.* ID in Phase 01 (CR-0007). |
| Runtime state DTOs | AI-02 | INFERRED | Likely covered by CC.PUZZLE.STATE / CC.WORLD.STATE; AI-02 confirms in Phase 01 (CR-0007). |
| Event bus IDs | AI-13 (registry) with per-event domain owner | INFERRED | AI-13 opens an event-ID registry in Phase 01; each event names its producer account. |
| Content schemas (BiomeSpec, CreatureSpec, ChapterSpec, EffectSpec, CompanionSpec, balance tables) | AI-03 | INFERRED | AI-03 registers content-schema IDs in Phase 01 (CR-0007). Overlap with CC.NARRATIVE.CHAPTER and CC.BIOME.STATE to be resolved at the same time. |
| Asset IDs / asset manifest | UNKNOWN | UNKNOWN | Manifest format owner is undecided (AI-05 art / AI-06 characters / AI-12 packaging each hold part). Open decision OD-0004. |
| Audio cue IDs | AI-08 | VERIFIED | AI-08 registers a CC.AUDIO.* ID in Phase 01 (CR-0007). |
| Build/environment contracts | AI-12 | VERIFIED | AI-12 registers a CC.BUILD.* ID in Phase 01 (CR-0007). Engine/SDK versions remain UNKNOWN until OD-0002 is decided. |

## Alias policy

Three overlapping contract vocabularies exist on the baseline (`V7_MASTER_CONTRACT_REGISTER.md` PascalCase families, `NARRATIVE_ITEM_CONTRACTS.md` `CC.*` IDs, `PROGRESS.md` baseline names). The `CC.<DOMAIN>.<NAME>` form is canonical because it already existed and is machine-safe. Every other name is an alias of exactly one canonical ID. Aliases are for human lookup only and must never appear in code, schemas, save data or events.

## Notes from source

- Every entry is DRAFT at Phase 00. No version is assigned until the owner freezes the contract in Phase 01 under 06_CONTRACTS/CONTRACT_REGISTRY_TEMPLATE.md.
- aliases record names used for the same semantic contract in other repository documents so that no second vocabulary is created. Aliases are never valid as contract IDs.
- owner_evidence: VERIFIED = owner named in a register document; INFERRED = derived from 04_AI_ACCOUNTS/ACCOUNT_MATRIX.md ownership text; UNKNOWN = must be decided by Product/AI-13 in Phase 01.
- consumers lists are copied verbatim from the source register rows. An empty list means the source did not declare consumers (UNKNOWN), not that there are none.
- governance is always AI-13 for versioning/integration; owner is the single account that defines semantics and fields.
