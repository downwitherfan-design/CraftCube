# Cross-Track Dependency Graph (AI-13 owned)

Derived from `11_INTEGRATION/registry/contract_registry.json` (owners/consumers) and `02_ARCHITECTURE/NARRATIVE_EQUIPMENT_SYSTEM_ARCHITECTURE_V7.md` (data flow). A dependency is **blocking only when the contract is missing or incompatible** (`00_CONTROL/13_AI_EXECUTION_MANUAL.md`). Every edge below therefore carries a mock policy.

## 1. Canonical data flow

```text
CC.PUZZLE.STATE ──► CC.WORLD.STATE_EVENT ──► CC.WORLD.STATE / CC.BIOME.STATE
      │                       │                        │
      │                       ├──► CC.NARRATIVE.EVENT ─┼─► CC.NARRATIVE.MEMORY_FLAG / CC.NARRATIVE.CHARACTER_MEMORY
      │                       ├──► CC.DISCOVERY.DEFINITION
      │                       └──► CC.COMPANION.REACTION
      │
      └──► CC.REWARD.DEFINITION ──► CC.ITEM.ACQUISITION ──► CC.ITEM.DEFINITION / CC.ITEM.IDENTITY
                                                                   │
                                          CC.EQUIPMENT.DEFINITION ─┴─► CC.EQUIPMENT.EFFECT ──► CC.PUZZLE.AFFINITY ──► (capability query) ──► next puzzle
                                                                   │
                                          CC.ITEM.UPGRADE ─────────┘

CC.QUEST.STATE  wraps  NARRATIVE.EVENT + REWARD + WORLD.STATE consequences
CC.SAVE.SCHEMA  persists  WORLD/BIOME state, item ownership, equipment, upgrades, quest, memory flags, discoveries
CC.LOCALIZATION.KEY, CC.ACCESSIBILITY.PREFERENCE, CC.PERFORMANCE.BUDGET  are cross-cutting inputs to presentation tracks
CC.TELEMETRY.EVENT, CC.COMPETITIVE.RESULT, CC.REMOTE.CONTENT_MANIFEST  are optional; never required by the offline core (DD-015)
```

Protected rule on the graph: nothing downstream of `CC.PUZZLE.STATE` may write back into puzzle truth except through `CC.EQUIPMENT.EFFECT` under DD-002 constraints. AI-13 gate rejects any contract that adds a reverse edge.

## 2. Producer → consumer matrix (from registry, Phase 00)

Rows = producer (owner). Cells = contracts that account produces for the column account. All are DRAFT.

| Producer ↓ / Consumer → | AI-01 | AI-02 | AI-03 | AI-04 | AI-05 | AI-06 | AI-07 | AI-08 | AI-09 | AI-10 | AI-11 | AI-12 | AI-13 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **AI-02** | — | — | PUZZLE.STATE, ITEM.DEFINITION, EQUIPMENT.DEFINITION, EQUIPMENT.EFFECT, WORLD.STATE_EVENT, ITEM.IDENTITY, ITEM.UPGRADE, RESOURCE.LEDGER | PUZZLE.STATE, EQUIPMENT.DEFINITION, EQUIPMENT.EFFECT | PUZZLE.STATE, WORLD.STATE, WORLD.STATE_EVENT, EQUIPMENT.EFFECT | PUZZLE.STATE, WORLD.STATE, WORLD.STATE_EVENT, EQUIPMENT.EFFECT | ITEM.DEFINITION, EQUIPMENT.DEFINITION, EQUIPMENT.EFFECT, SAVE.SCHEMA, ITEM.IDENTITY, ITEM.UPGRADE, RESOURCE.LEDGER | WORLD.STATE_EVENT | WORLD.STATE, WORLD.STATE_EVENT, ITEM.DEFINITION, EQUIPMENT.DEFINITION, ITEM.IDENTITY | all AI-02 contracts | ITEM.DEFINITION, EQUIPMENT.DEFINITION, SAVE.SCHEMA, ITEM.IDENTITY, ITEM.UPGRADE, RESOURCE.LEDGER | ITEM.DEFINITION, EQUIPMENT.DEFINITION, SAVE.SCHEMA, ITEM.IDENTITY, RESOURCE.LEDGER | PUZZLE.STATE, WORLD.STATE, SAVE.SCHEMA |
| **AI-03** | — | REWARD.DEFINITION, QUEST.STATE | — | DISCOVERY.DEFINITION | — | — | DISCOVERY.DEFINITION, REWARD.DEFINITION, QUEST.STATE | — | DISCOVERY.DEFINITION, REWARD.DEFINITION, QUEST.STATE | all AI-03 contracts | — | DISCOVERY.DEFINITION, REWARD.DEFINITION | QUEST.STATE |
| **AI-06** | — | — | — | COMPANION.REACTION | — | — | — | COMPANION.REACTION | COMPANION.REACTION | COMPANION.REACTION | — | — | — |
| **AI-07** | — | — | — | ACCESSIBILITY.PREFERENCE | — | — | — | ACCESSIBILITY.PREFERENCE | — | ACCESSIBILITY.PREFERENCE | ACCESSIBILITY.PREFERENCE | — | — |
| **AI-09** | — | CHARACTER_MEMORY, MEMORY_FLAG | — | NARRATIVE.EVENT | — | CHARACTER_MEMORY | NARRATIVE.EVENT, LOCALIZATION.KEY, CHARACTER_MEMORY, MEMORY_FLAG | NARRATIVE.EVENT, LOCALIZATION.KEY, CHARACTER_MEMORY | — | NARRATIVE.EVENT, CHARACTER_MEMORY, MEMORY_FLAG | — | LOCALIZATION.KEY | NARRATIVE.EVENT |
| **AI-11** | — | PERFORMANCE.BUDGET | PERFORMANCE.BUDGET | PERFORMANCE.BUDGET | PERFORMANCE.BUDGET | PERFORMANCE.BUDGET | PERFORMANCE.BUDGET | PERFORMANCE.BUDGET | — | — | — | PERFORMANCE.BUDGET | — |
| **AI-12** | TELEMETRY.EVENT | REMOTE.CONTENT_MANIFEST | — | — | — | — | — | — | — | TELEMETRY.EVENT, REMOTE.CONTENT_MANIFEST | TELEMETRY.EVENT, REMOTE.CONTENT_MANIFEST | — | TELEMETRY.EVENT, REMOTE.CONTENT_MANIFEST |
| **AI-13** | — | — | — | — | — | — | — | — | — | COMPETITIVE.RESULT | — | COMPETITIVE.RESULT | — |

Accounts that produce **no** registered contract: AI-01 (produces decisions, not schemas), AI-04, AI-05, AI-08, AI-10. Their outputs are consumed through assets, tests and evidence, not contracts — consistent with the ownership model. `CC.NARRATIVE.CHAPTER`, `CC.BIOME.STATE`, `CC.ITEM.ACQUISITION`, `CC.PUZZLE.AFFINITY` have UNKNOWN consumers (CR-0006) and are omitted from the matrix until declared.

## 3. Heaviest dependency hubs (integration attention)

| Account | Contracts produced | Distinct consumers | Note |
|---|---|---|---|
| AI-02 | 12 | 11 | Critical path. A late or unstable AI-02 freeze blocks the most tracks. Mock policy §4 is mandatory for every AI-02 contract from Phase 01 day one. |
| AI-09 | 5 | 8 | Terminology/localization keys gate every player-facing text (RISK-0008). |
| AI-03 | 3 | 7 | Reward/quest/discovery sit between puzzle and item layers; overlap with AI-02 acquisition (CR-0006). |

## 4. Mock policy per edge type

| Edge type | Consumer builds | Label | Swap-out condition |
|---|---|---|---|
| State DTO (PUZZLE.STATE, WORLD.STATE, BIOME.STATE) | Deterministic JSON sample states in consumer's own fixture folder | `MOCK-<CC.ID>-<consumer>` in filename and header | Producer contract FROZEN with fixture path in registry → consumer deletes its mock and points at the producer fixture |
| Definition data (ITEM/EQUIPMENT/REWARD/DISCOVERY/QUEST/UPGRADE) | Hand-authored sample definitions using **candidate** IDs from `01_PREPRODUCTION/ITEM_CATALOG_STARTER_SET.md` labelled `candidate.` prefix | same | Canonical IDs released by owner; consumer runs a rename script and records old→new in handoff |
| Event (WORLD.STATE_EVENT, NARRATIVE.EVENT, COMPANION.REACTION) | Fake emitter that replays a fixed ordered list | same | Real producer + contract test suite pass on fake and real (`06_CONTRACTS/CONTRACT_FIRST_RULES.md` three-way rule) |
| Cross-cutting input (LOCALIZATION.KEY, ACCESSIBILITY.PREFERENCE, PERFORMANCE.BUDGET) | Default table with provisional values, clearly marked provisional | same | Owner freezes; provisional values removed |
| Optional service (TELEMETRY, COMPETITIVE, REMOTE) | Null implementation that records calls and never fails the caller | `NULL-<CC.ID>` | Phase 13 |

Rules for every mock: lives outside production paths, cannot be shipped (AI-12 content validation must detect the `MOCK-`/`NULL-`/`candidate.` markers — request to AI-12 in Phase 01), and never hides an integration defect (a mock that always returns success is not acceptable for state or event edges).

## 5. What changes this graph

Only a registry change (new contract, new consumer, owner change). The matrix in §2 is regenerated by hand from the JSON at each phase gate; if it disagrees with the JSON, the JSON wins.
