# CraftCube — QA Phase 00 Traceability Matrix (rendered view)

| Field | Value |
|---|---|
| Owner | AI-10 — QA / Automation / Quality Engineering |
| Register ID | `CC.QA.TRACE` |
| registerVersion | `1.0.0` |
| Status | READY_FOR_REVIEW |
| Source of truth | `QA_PHASE00_TRACEABILITY_REGISTER.json` — this markdown is a rendered view; `QA_PHASE00_VALIDATOR.py` check B1 fails if the two drift. |
| ID family | `QAT-###` — QA verification item. Immutable once released. |

## Purpose

Every product acceptance criterion produced in Phase 00 by AI-01 (`PD-###`, `F10-###`, `IGM-###`, `CUT` complexity caps) and every relevant release gate in `QUALITY_AND_RELEASE.md` is mapped to exactly one QA verification item that states **how** it will be verified, **when** it can first be measured, **which contract** it needs, **which fixture** it needs, and **who fixes** a failure. Nothing here is a test result. Statuses record executability, not outcome.

## Source baseline

| sourceId | Path | Version | Branch@commit | Owner |
|---|---|---|---|---|
| SRC-PRODUCT-LOCK | `01_PREPRODUCTION/PRODUCT/PRODUCT_LOCK_V1.md` | 1.0.0 | `ai-01-product@2db84b5` | AI-01 |
| SRC-PD | `01_PREPRODUCTION/PRODUCT/PRODUCT_DECISION_REGISTER.md` | 1.0.0 | `ai-01-product@2db84b5` | AI-01 |
| SRC-F10 | `01_PREPRODUCTION/PRODUCT/FIRST_10_MINUTES_PROOF.md` | 1.0.0 | `ai-01-product@2db84b5` | AI-01 |
| SRC-IGM | `01_PREPRODUCTION/PRODUCT/INVESTMENT_GATE_METRICS.md` | 1.0.0 | `ai-01-product@2db84b5` | AI-01 |
| SRC-CUT | `01_PREPRODUCTION/PRODUCT/CUT_LIST_AND_COMPLEXITY_BUDGET.md` | 1.0.0 | `ai-01-product@2db84b5` | AI-01 |
| SRC-BIBLE | `00_CONTROL/CRAFTCUBE_GAME_MASTER_BIBLE.md` | v7 | `main@584141c` | AI-01 |
| SRC-DD | `00_CONTROL/V7_DESIGN_DECISION_REGISTER.md` | v7 | `main@584141c` | AI-01 |
| SRC-GATES | `08_QA_RELEASE/QUALITY_AND_RELEASE.md` | v7.1 | `main@584141c` | AI-10 |

Product documents (SRC-PRODUCT-LOCK … SRC-CUT) are on the unmerged `ai-01-product` branch at authoring time. The validator reports `SOURCE_NOT_PRESENT` for them in a checkout that lacks them; it never marks them passed.

## Status legend

- `DEFINED` — Verification item is specified; nothing can be executed yet.
- `BLOCKED_ON_CONTRACT` — Cannot be automated until the named contract family is released.
- `BLOCKED_ON_SOURCE` — Cannot be executed until the named upstream artifact exists.
- `EXECUTABLE_NOW` — Can be executed against the current repository.
- `EXECUTED_PASS` — Executed; evidence path recorded; passed.
- `EXECUTED_FAIL` — Executed; evidence path recorded; failed; finding filed.
- `UNMEASURED` — Execution attempted but method could not produce a result.

## Method legend

- `VALIDATOR` — Deterministic check over content/data/definitions. No build or player required.
- `BUILD` — Automated or scripted check against a built artifact (unit/integration/playmode/device automation).
- `PLAYTEST` — Fresh-participant protocol with coded exit answers. Requires cohort >= minimum.
- `EVIDENCE` — Produced by another track as measured evidence; QA verifies presence, format and method, not the number.
- `DOC_REVIEW` — Structured review of a document against a checklist; result is a finding list, not a pass/fail number.

## Verification items

| QAT | Title | Traces | Method | Priority | Earliest phase | Contract prerequisites | Fix owner | Status |
|---|---|---|---|---|---|---|---|---|
| QAT-001 | Protected-core proof: every critical-path puzzle solvable with all equipment removed | PD-002, DD-001, DD-002, Gate I | BUILD | MUST | 03 | PuzzleState, SaveSchema, EquipmentDefinition | AI-02 | BLOCKED_ON_CONTRACT |
| QAT-002 | Equipment effects never reference or mutate puzzle truth | PD-002, PD-008, DD-002, Gate I | VALIDATOR | MUST | 01 | EquipmentEffect | AI-02 | BLOCKED_ON_CONTRACT |
| QAT-003 | Zero critical-path items acquired via random drop | PD-002, PD-006, DD-006, Gate H, Gate J | VALIDATOR | MUST | 01 | RewardDefinition, ItemDefinition, DiscoveryDefinition | AI-03 | BLOCKED_ON_CONTRACT |
| QAT-004 | Every equipment item answers >= 2 of the Bible §9 six questions in its identity card | PD-002, Bible §9, V7.1 §5.1 | VALIDATOR | MUST | 01 | ItemIdentity | AI-02 | BLOCKED_ON_CONTRACT |
| QAT-005 | Complexity budget counters within cap | PD-002, PD-003, CUT §3 | VALIDATOR | MUST | 01 | ItemDefinition, EquipmentDefinition, UpgradeDefinition, QuestState, WorldState, NarrativeMemoryFlag, ResourceLedger, CompanionReaction | AI-13 | BLOCKED_ON_CONTRACT |
| QAT-006 | Chapter definitions declare one question introduced and >= 1 question advanced/resolved | PD-001, V7.1 §3, Gate H | VALIDATOR | MUST | 01 | NarrativeEvent | AI-09 | BLOCKED_ON_CONTRACT |
| QAT-007 | Mandatory text budget before first solve and in minutes 0-10 | PD-001, F10-004, IGM-005b, Product Lock §10, CUT §3 | VALIDATOR | MUST | 01 | NarrativeEvent, LocalizationKey | AI-09 | BLOCKED_ON_CONTRACT |
| QAT-008 | Main story path completable with zero optional lore read | PD-001, PD-005, PD-006, Gate H, Gate J | VALIDATOR | MUST | 01 | QuestState, DiscoveryDefinition, ItemDefinition, NarrativeMemoryFlag | AI-03 | BLOCKED_ON_CONTRACT |
| QAT-009 | Companion reaction triggers limited to approved trigger list | PD-005, DD-007 | VALIDATOR | MUST | 01 | CompanionReaction | AI-06 | BLOCKED_ON_CONTRACT |
| QAT-010 | Discovery definitions complete (Secret Design Test) and deterministically reproducible | PD-006, DD-006, Gate J | VALIDATOR | MUST | 01 | DiscoveryDefinition | AI-03 | BLOCKED_ON_CONTRACT |
| QAT-011 | Save -> kill -> reload preserves puzzle, world, loadout, discovery ledger and memory flags | PD-006, F10-007, IGM-006c, Product Lock §4, Gate A, Gate J | BUILD | HARD_STOP | 03 | SaveSchema, PuzzleState, WorldState, NarrativeMemoryFlag | AI-02 | BLOCKED_ON_CONTRACT |
| QAT-012 | Reward and resource duplication impossible via interruption/retry | Gate I, WORLDCLASS_QA_EXPANSION Economy QA, STORY_ITEM_TEST_MATRIX Abuse | BUILD | MUST | 05 | RewardDefinition, ResourceLedger, SaveSchema | AI-02 | BLOCKED_ON_CONTRACT |
| QAT-013 | Smart Assist never performs a move; assist level persists and is changeable in <= 2 taps | PD-007, CUT-016 | VALIDATOR | MUST | 01 | PuzzleState, SaveSchema, AccessibilityPreference | AI-03 | BLOCKED_ON_CONTRACT |
| QAT-014 | Affinity entries map to approved effect categories; disabling affinity does not change solvability | PD-008, DD-002 | VALIDATOR | MUST | 01 | EquipmentEffect, WorldState | AI-03 | BLOCKED_ON_CONTRACT |
| QAT-015 | Offline completeness: Gold Slice completable in airplane mode | PD-010, IGM-006d, DD-015, CUT-001, Gate K | BUILD | MUST | 06 | TelemetryEvent, RemoteContentManifest | AI-12 | DEFINED |
| QAT-016 | Puzzle tile identity encoded by >= 2 independent channels | PD-011, V7.1 §9 | VALIDATOR | MUST | 01 | PuzzleState | AI-07 | BLOCKED_ON_CONTRACT |
| QAT-017 | Accessibility smoke test passes in Gold Slice | PD-011, V7.1 §15, Gate B, Gate K | BUILD | MUST | 06 | AccessibilityPreference, SaveSchema | AI-07 | DEFINED |
| QAT-018 | Zero hard-coded player-facing strings; pseudo-localization +35% shows no clipping | PD-012, V7.1 §13, Gate B | VALIDATOR | MUST | 02 | LocalizationKey | AI-07 | BLOCKED_ON_CONTRACT |
| QAT-019 | F10-001 deliberate twist within 90 s; accidental-input complaints <= 5% | F10-001, IGM-002, IGM-006 | PLAYTEST | MUST | 06 | — | AI-04 | DEFINED |
| QAT-020 | F10-002 median time-to-first-solve <= 3:00; world reaction <= 2 s | F10-002, IGM-002, Product Lock §10, P2 | PLAYTEST | HARD_STOP | 06 | PuzzleState, WorldStateEvent | AI-03 | DEFINED |
| QAT-021 | F10-003 / IGM-007 causality recognition and unprompted creature mention | F10-003, IGM-007, IGM-005c, PD-005 | PLAYTEST | MUST | 06 | — | AI-05 | DEFINED |
| QAT-022 | F10-004 / IGM-005 story curiosity and no lore-wall complaints | F10-004, IGM-005, IGM-005b, PD-001 | PLAYTEST | MUST | 06 | — | AI-09 | DEFINED |
| QAT-023 | F10-005 / IGM-004 meaningful choice and behavioral equipment value | F10-005, IGM-004, PD-002 | PLAYTEST | HARD_STOP | 06 | NarrativeMemoryFlag, QuestState | AI-03 | DEFINED |
| QAT-024 | F10-006 progression is more than numbers; no numeric indicator rendered in minutes 0-10 | F10-006, IGM-002, IGM-003, CUT-006, PD-003 | PLAYTEST | MUST | 06 | — | AI-07 | DEFINED |
| QAT-025 | F10-007 forced interruption recovery and low-tier frame hitch ceiling | F10-007, IGM-006b, IGM-006c, DD-010 | BUILD | MUST | 06 | SaveSchema, PerformanceBudget | AI-11 | BLOCKED_ON_SOURCE |
| QAT-026 | IGM-001 voluntary continuation and IGM-001b solve ownership | IGM-001, IGM-001b, DD-001, PD-007 | PLAYTEST | HARD_STOP | 06 | — | AI-01 | DEFINED |
| QAT-027 | IGM-002b loadout change task success and PD-003 menu comprehension | IGM-002b, PD-003, IGM-004b | PLAYTEST | MUST | 06 | — | AI-07 | DEFINED |
| QAT-028 | IGM-006 input reliability: unintended actions per 10 minutes | IGM-006, F10-001 | BUILD | HARD_STOP | 06 | — | AI-04 | BLOCKED_ON_SOURCE |
| QAT-029 | IGM-008 retention intent proxy with zero dark-pattern reasons | IGM-008, DD-009, CUT-002, CUT-017 | PLAYTEST | SHOULD | 06 | — | AI-01 | DEFINED |
| QAT-030 | Product-approved vocabulary and IP rule respected in player-facing and design text | Product Lock §6, Bible §1, CUT-007, IGM-003 | VALIDATOR | MUST | 00 | — | AI-09 | EXECUTABLE_NOW |
| QAT-031 | Phase 00 deliverables of other tracks are consumable by QA (structured acceptance criteria present) | Phase 00 gate, DEFINITION_OF_DONE | DOC_REVIEW | MUST | 00 | — | AI-01 | EXECUTABLE_NOW |
| QAT-032 | Quest state machine uses exactly the six approved states and every quest has fail/recovery behaviour | PD-003, V7.1 §4, Gate H | VALIDATOR | MUST | 01 | QuestState | AI-03 | BLOCKED_ON_CONTRACT |
| QAT-033 | Telemetry privacy: no personal data, versioned schema, opt-out honoured, failure is silent to gameplay | V7.1 §10, Gate K, WORLDCLASS_QA_EXPANSION Analytics QA, IGM-008 | VALIDATOR | MUST | 13 | TelemetryEvent | AI-12 | BLOCKED_ON_CONTRACT |
| QAT-034 | Competitive integrity: impossible scores rejected; trust level explicit; challenge version recorded | V7.1 §11, CUT-023, WORLDCLASS_QA_EXPANSION Leaderboard QA | BUILD | MUST | 13 | CompetitiveResult, PuzzleState | AI-13 | DEFINED |
| QAT-035 | Remote content safety: invalid package rejected, rollback works, offline core unaffected | V7.1 §12, CUT-024, WORLDCLASS_QA_EXPANSION Remote content QA | BUILD | MUST | 13 | RemoteContentManifest, SaveSchema | AI-12 | DEFINED |
| QAT-036 | Economy: <= 1 resource, deterministic source per sink in same chapter, no irreversible loss on failure | PD-004, DD-014, CUT-012, WORLDCLASS_QA_EXPANSION Economy QA | VALIDATOR | MUST | 01 | ResourceLedger, RewardDefinition | AI-02 | BLOCKED_ON_CONTRACT |

## Item detail

### QAT-001 — Protected-core proof: every critical-path puzzle solvable with all equipment removed

- **Criterion:** [BUILD] With all equipment removed from the save, every critical-path puzzle remains solvable by legal moves alone. Required automated regression, owner AI-10.
- **Fixture requirement:** Golden save fixture with empty loadout + list of critical-path puzzle IDs (from AI-03 chapter definitions).
- **Notes:** Solvability is decided by the deterministic simulation (same seed + move list + rulesetVersion => same result, TECHNICAL_BLUEPRINT.md). Test must not use any solver that reads equipment state.

### QAT-002 — Equipment effects never reference or mutate puzzle truth

- **Criterion:** [VALIDATOR] No equipment effect definition may reference or mutate puzzle truth (cube permutation state, legal-move set, solved predicate). Effects are consumed via the capability model only.
- **Fixture requirement:** Positive fixture (approved effect categories only) and negative fixture (effect referencing solved predicate) to prove the validator fails correctly.
- **Notes:** Approved effect categories per PD-002: information, access, interaction, efficiency, risk management, exploration, companion synergy, puzzle strategy. Forbidden: damage, defense, health, attack, any numeric multiplier on puzzle state.

### QAT-003 — Zero critical-path items acquired via random drop

- **Criterion:** [VALIDATOR] Zero critical-path items are acquired via random drop. Product Lock §10: Critical-path items dependent on random drops = 0.
- **Fixture requirement:** Reward fixture with one deterministic and one seeded-random source; critical-path flag on items.
- **Notes:** Also covers the Phase 00 prompt requirement: 'Verify no random drop can soft-lock critical progress.' Soft-lock analysis = graph reachability from chapter start to chapter end using deterministic sources only.

### QAT-004 — Every equipment item answers >= 2 of the Bible §9 six questions in its identity card

- **Criterion:** [VALIDATOR] Every equipment item declares >= 2 affirmative answers to the Bible §9 six-question test, recorded in its item identity card.
- **Fixture requirement:** Item identity card fixture with the six boolean answers as explicit fields.
- **Notes:** Requires the ItemIdentity contract to carry the six answers as data, not prose. Integration request to AI-02 recorded in findings register.

### QAT-005 — Complexity budget counters within cap

- **Criterion:** [VALIDATOR] Count of equipment/relic items <= 12; active slots <= 4; upgrade steps per branch <= 2; upgrade branches per item <= 3; item families <= 6; quest states <= 6; world-state tiers per biome <= 5; narrative memory flags per chapter <= 6 and <= 60 total; companions <= 1; player-visible resources <= 1; named set synergies <= 3.
- **Fixture requirement:** Per-contract minimal fixtures; the counting sources are named in CUT §3.
- **Notes:** PD-003 names AI-13 as report owner fed by AI-02/03/07 data. QA provides the counting validator and the negative fixtures; AI-13 owns the gate verdict.

### QAT-006 — Chapter definitions declare one question introduced and >= 1 question advanced/resolved

- **Criterion:** [VALIDATOR] Every chapter definition declares exactly one question introduced and at least one question advanced or resolved. Missing either -> validation failure.
- **Fixture requirement:** Chapter definition fixture with questionIntroduced / questionsAdvanced fields.
- **Notes:** Chapter definition schema does not exist yet; CUT §3 references a `CC.NARRATIVE.CHAPTER` counting source that is not defined anywhere in the repository (see QAF-004).

### QAT-007 — Mandatory text budget before first solve and in minutes 0-10

- **Criterion:** [VALIDATOR] No mandatory narrative text node before the first solve exceeds 40 words in the source language. No narrative node in minutes 0-10 exceeds 40 words; total mandatory text in minutes 0-10 <= 120 words. No cutscene > 20 s before first solve.
- **Fixture requirement:** Narrative node fixture with mandatory flag, ordering, timing window and source-language text.
- **Notes:** Word count is counted on the source language only (PD-001). Cutscene duration needs a duration field or timeline metadata in the NarrativeEvent contract (request to AI-09).

### QAT-008 — Main story path completable with zero optional lore read

- **Criterion:** [VALIDATOR] No critical-path prerequisite references a Memory Collectible, an optional discovery, or a companion bond level.
- **Fixture requirement:** Quest prerequisite fixture with a negative case referencing an optional discovery.
- **Notes:** Merges three PD criteria with identical mechanics (PD-001 optional lore, PD-005 bond level, PD-006 secrets never block). One validator, three rule IDs.

### QAT-009 — Companion reaction triggers limited to approved trigger list

- **Criterion:** [VALIDATOR] Companion reaction definitions reference only: puzzle states, biome health, relics, story revelations, mastery moments, player choices. Any other trigger fails.
- **Fixture requirement:** Reaction fixture with one entry per approved trigger class and one forbidden trigger.
- **Notes:** Also proves CUT-005 (no combat triggers) and CUT-011 (no gift trigger).

### QAT-010 — Discovery definitions complete (Secret Design Test) and deterministically reproducible

- **Criterion:** [VALIDATOR] Every discovery definition answers notice / skill / reveal / worth as non-empty fields and records a deterministic reproduction path (seed or state sequence).
- **Fixture requirement:** Discovery fixture with reproductionPath as an ordered state/move list.
- **Notes:** The reproduction path becomes the input of the Phase 05+ automated discovery replay test.

### QAT-011 — Save -> kill -> reload preserves puzzle, world, loadout, discovery ledger and memory flags

- **Criterion:** [BUILD] 100% of trials restore puzzle state, world state, loadout, discovery ledger and memory flags after save/kill/reload. Any interruption loses at most the in-progress twist animation. Any data loss -> HARD_STOP.
- **Fixture requirement:** Versioned golden save fixtures per released schema; corrupted, truncated, missing-field and future-version variants (SAVE_MIGRATION_POLICY.md).
- **Notes:** Kill points: mid-twist, mid-save-write, mid-reward-claim, mid-discovery-record. Trials must be repeated >= 20 per kill point; the 100% threshold is per trial, not per cohort.

### QAT-012 — Reward and resource duplication impossible via interruption/retry

- **Criterion:** Rewards cannot be duplicated through interruption/retry abuse; resource duplication blocked; interrupted reward claims safe.
- **Fixture requirement:** Idempotency fixture: same reward event delivered twice with identical event ID must yield one grant.
- **Notes:** Requires reward events to carry an idempotency key (EVENT_AND_ID_POLICY.md: events document whether duplication is possible). Request to AI-02/AI-13 recorded.

### QAT-013 — Smart Assist never performs a move; assist level persists and is changeable in <= 2 taps

- **Criterion:** [VALIDATOR] No assist level definition performs a move on behalf of the player. [BUILD] Assist level changeable mid-puzzle in <= 2 taps and persists in save.
- **Fixture requirement:** Assist level definition fixture with capability list; negative fixture with a `performMove` capability.
- **Notes:** Assist owner across tracks is UNKNOWN: assist rules are puzzle-side (AI-03), presentation is AI-07 (D-UX-04). Recorded as QAF-005.

### QAT-014 — Affinity entries map to approved effect categories; disabling affinity does not change solvability

- **Criterion:** [VALIDATOR] Every affinity entry maps to an effect in an approved category; none maps to a numeric multiplier. [BUILD] Disabling the affinity layer does not change any puzzle's solvability. Matrix size <= 12 items x 6 biomes.
- **Fixture requirement:** Affinity matrix fixture; negative entry with a multiplier field.
- **Notes:** The BUILD half is the same harness as QAT-001 with affinity toggled off.

### QAT-015 — Offline completeness: Gold Slice completable in airplane mode

- **Criterion:** [BUILD] Full Gold Slice completable in airplane mode with zero network-related dialogs or blocks.
- **Fixture requirement:** Device with radios disabled; scripted playthrough of the slice; dialog/log capture.
- **Notes:** Also verify WORLDCLASS_QA_EXPANSION Analytics QA: telemetry failure does not break gameplay.

### QAT-016 — Puzzle tile identity encoded by >= 2 independent channels

- **Criterion:** [VALIDATOR] Puzzle tile identity is encoded by at least two independent channels (e.g., color + glyph/pattern) in the presentation contract.
- **Fixture requirement:** Tile presentation fixture with channel list.
- **Notes:** Presentation contract owner is AI-04/AI-07; the tile identity data field likely lives in the puzzle presentation DTO. Owner confirmation requested (QAF-005).

### QAT-017 — Accessibility smoke test passes in Gold Slice

- **Criterion:** [BUILD] Accessibility smoke test (V7.1 §15) passes in the Gold Slice: reduced motion, camera comfort, haptic intensity, larger touch targets, text-speed control, safe-area handling; toggles persist.
- **Fixture requirement:** Preference fixture with every V7.1 §9 setting at non-default value; save/reload; screenshot per screen.
- **Notes:** Persistence half depends on AccessibilityPreference being part of SaveSchema or a separate settings store — UNKNOWN until Phase 01.

### QAT-018 — Zero hard-coded player-facing strings; pseudo-localization +35% shows no clipping

- **Criterion:** [VALIDATOR] Zero hard-coded player-facing strings in runtime code (AI-10 lint/validator). [BUILD] Pseudo-localization pass at +35% length shows no clipped text in Gold Slice screens.
- **Fixture requirement:** Localization key fixture; pseudo-locale generator producing +35% expansion.
- **Notes:** Lint scope must be defined against the actual code layout after Phase 02 bootstrap (no engine project exists yet). The lint will allow-list AI-09's key-lookup API only.

### QAT-019 — F10-001 deliberate twist within 90 s; accidental-input complaints <= 5%

- **Criterion:** [PLAYTEST] >= 90% of fresh players perform a deliberate face rotation within 90 s without verbal help. <= 5% accidental-input complaints in exit interview.
- **Fixture requirement:** Session record fields: timeToFirstDeliberateTwistMs, accidentalInputComplaint (exit Q6 coding).
- **Notes:** Field definitions live in fixtures/playtest_session_record.schema.json.

### QAT-020 — F10-002 median time-to-first-solve <= 3:00; world reaction <= 2 s

- **Criterion:** [PLAYTEST] median time-to-first-solve <= 3:00 from app start (HARD_STOP > 5:00). [BUILD] world reaction begins <= 2 s after solved predicate becomes true.
- **Fixture requirement:** Session record field timeToFirstSolveMs; build-side timestamp pair (solvedPredicateTrueAt, firstWorldReactionAt) logged by AI-02/AI-05 instrumentation.
- **Notes:** The 2 s causality latency must be measured on the AI-11 low-tier device, not on a workstation.

### QAT-021 — F10-003 / IGM-007 causality recognition and unprompted creature mention

- **Criterion:** [PLAYTEST] >= 70% describe a concrete world change when asked what solving did; >= 50% mention the creature unprompted.
- **Fixture requirement:** Exit Q2 coding: CONCRETE_WORLD_CHANGE | ABSTRACT_REWARD | UNSURE. Observer log: unpromptedCreatureMention boolean.
- **Notes:** Two independent raters; disagreement resolved by a third; inter-rater agreement reported.

### QAT-022 — F10-004 / IGM-005 story curiosity and no lore-wall complaints

- **Criterion:** [PLAYTEST] >= 60% state at least one story/world question they want answered. <= 10% answer yes to 'too much reading or too many cutscenes'.
- **Fixture requirement:** Exit Q3 coding: STORY_WORLD_QUESTION | UI_QUESTION | NONE. Exit Q7 boolean.
- **Notes:** Validator companion is QAT-007.

### QAT-023 — F10-005 / IGM-004 meaningful choice and behavioral equipment value

- **Criterion:** [PLAYTEST] >= 70% recognize they made a choice. >= 60% code as behavioral, <= 10% numeric on 'did any object let you do something new'. HARD_STOP: >= 30% describe any equipment as 'made it easier / solved it for me'. [VALIDATOR] the choice writes exactly one narrative memory flag and does not gate the critical path.
- **Fixture requirement:** Exit Q4 coding: BEHAVIORAL | NUMERIC | SOLVED_FOR_ME | NONE. Exit Q4b choice recognition boolean. Flag-count validator on the chapter-1 choice node.
- **Notes:** SOLVED_FOR_ME is coded separately from NUMERIC because it triggers the IGM-004 HARD_STOP.

### QAT-024 — F10-006 progression is more than numbers; no numeric indicator rendered in minutes 0-10

- **Criterion:** [PLAYTEST] >= 70% restate the value proposition gist; <= 20% answer progression in terms of numbers/levels; >= 60% in terms of skill/tools/places/story. [BUILD] no numeric progression indicator is rendered in minutes 0-10.
- **Fixture requirement:** Exit Q1 coding (DISTINCT | GENERIC | COMPETITOR_FRAMED); Exit Q5 coding (NUMBERS_LEVELS | SKILL_TOOLS_PLACES_STORY | OTHER). Build-side HUD element inventory captured at 60 s intervals.
- **Notes:** Q1 coding lists are owned by AI-01 (IGM-003); QA applies them and reports inter-rater agreement.

### QAT-025 — F10-007 forced interruption recovery and low-tier frame hitch ceiling

- **Criterion:** [BUILD] resume restores exact puzzle state, world state and position after a forced interruption between minutes 2-6. [BUILD] on the AI-11 low-tier device no frame hitch > 100 ms during a twist in minutes 0-10 (HYPOTHESIS until measured).
- **Fixture requirement:** AI-11 device matrix (MISSING in repo); profiler capture method published by AI-11.
- **Notes:** Frame-time numbers are reported as EVIDENCE from AI-11; QA verifies presence/method per EVIDENCE_STANDARD.md and never fills in a number.

### QAT-026 — IGM-001 voluntary continuation and IGM-001b solve ownership

- **Criterion:** [PLAYTEST] >= 60% continue >= 3 min unprompted after 'you can stop here or keep going'. >= 70% answer 'me' or 'mix', <= 10% 'game' on solve ownership. HARD_STOP > 30% 'game'. Max-assist users still report 'I figured it out' >= 50%.
- **Fixture requirement:** Session record fields: continuedAfterProtocol, continuationDurationMs, solveOwnership (ME|MIX|GAME), maxAssistUsed.
- **Notes:** PD-007 acceptance is a sub-group analysis of the same field, so no extra question is asked.

### QAT-027 — IGM-002b loadout change task success and PD-003 menu comprehension

- **Criterion:** [PLAYTEST] >= 80% change a loadout item without help on first attempt. <= 10% describe menus as confusing/too many. [PLAYTEST] loadout change from gameplay <= 2 taps by UX walkthrough. SHOULD: >= 40% swap a loadout item voluntarily when facing the second biome.
- **Fixture requirement:** Task script + observer fields: loadoutTaskFirstAttemptSuccess, loadoutTapCount, voluntaryLoadoutSwap.
- **Notes:** Gold Slice only; not part of the first-10-minutes script because F10 forbids forced menus.

### QAT-028 — IGM-006 input reliability: unintended actions per 10 minutes

- **Criterion:** [BUILD+PLAYTEST] <= 2 unintended face rotations / camera moves per 10 minutes, median across cohort, on mid-tier device. HARD_STOP > 5.
- **Fixture requirement:** Debug counter of unintended actions provided by AI-04 (per IGM-006 'AI-04 to provide'); observer tally as cross-check.
- **Notes:** Definition of 'unintended' must be operationalised by AI-04's gesture arbitration model before this can be measured; request recorded (QAF-006).

### QAT-029 — IGM-008 retention intent proxy with zero dark-pattern reasons

- **Criterion:** [PLAYTEST] >= 50% 'yes' to playing again tomorrow; >= 70% of yes/maybe reasons map to the healthy-retention list; 0% cite a timer, reward schedule or FOMO.
- **Fixture requirement:** Exit Q8 coding against Bible §11 list plus DARK_PATTERN bucket.
- **Notes:** Becomes MUST at Phase 15 with opt-in telemetry D1/D7 (TelemetryEvent, AI-12).

### QAT-030 — Product-approved vocabulary and IP rule respected in player-facing and design text

- **Criterion:** No rejected/avoid term from Product Lock §6.3 is used affirmatively as CraftCube vocabulary; no proprietary franchise name is used as CraftCube branding, asset name, ID or player-facing string.
- **Fixture requirement:** QA_IP_TERMINOLOGY_RULES.json (QAR-###) with scope-aware severity.
- **Notes:** Executed by QA_PHASE00_VALIDATOR.py against markdown in the current checkout. Design docs may name rejected terms when negating them; the validator flags only affirmative use in ID/asset/key contexts and reports design-doc mentions as INFO.

### QAT-031 — Phase 00 deliverables of other tracks are consumable by QA (structured acceptance criteria present)

- **Criterion:** Every PD acceptance criterion carries a [VALIDATOR] / [BUILD] / [PLAYTEST] / [EVIDENCE] tag; every IGM has a threshold, method, owner and phase; every F10 has a pass condition. Any criterion without a method tag is a finding.
- **Fixture requirement:** None; runs against product documents when present in the checkout, otherwise reports SOURCE_NOT_PRESENT.
- **Notes:** Executed by QA_PHASE00_VALIDATOR.py section 'product-doc cross-check'. Result recorded in evidence/.

### QAT-032 — Quest state machine uses exactly the six approved states and every quest has fail/recovery behaviour

- **Criterion:** [VALIDATOR] QuestState enum == {DISCOVERED, ACCEPTED, ACTIVE, BLOCKED, RESOLVED, CONSEQUENCE_APPLIED}; every quest definition declares stable ID, owner, prerequisites, fail/recovery behaviour, reward, narrative consequence, save persistence, replay behaviour.
- **Fixture requirement:** Quest fixture with all eight required properties; negative fixture with a seventh state.
- **Notes:** Quest state ownership conflict C-02 was raised by AI-02; QA waits for AI-13's ruling before writing the fixture.

### QAT-033 — Telemetry privacy: no personal data, versioned schema, opt-out honoured, failure is silent to gameplay

- **Criterion:** [VALIDATOR] Every TelemetryEvent field is classified (none = personal/sensitive); schema carries version. [BUILD] with telemetry endpoint unreachable, gameplay is unaffected; with opt-out set, zero events leave the device.
- **Fixture requirement:** Event schema fixture with field classification; network-blackhole test harness.
- **Notes:** Playtest session records produced by QA before Phase 13 are pseudonymous by construction (see fixtures/playtest_session_record.schema.json) and are not telemetry.

### QAT-034 — Competitive integrity: impossible scores rejected; trust level explicit; challenge version recorded

- **Criterion:** [BUILD] A submitted result whose move list is illegal under rulesetVersion is rejected; every result carries trustLevel in {Local, Device-verified, Server-verified} and challengeDefinitionVersion; no signing secret in the client.
- **Fixture requirement:** Legal and illegal replay fixtures for a fixed seed.
- **Notes:** Leaderboards are LATER (CUT-023). Item is defined now so the CompetitiveResult contract is testable when it appears.

### QAT-035 — Remote content safety: invalid package rejected, rollback works, offline core unaffected

- **Criterion:** [BUILD] Package with bad checksum / incompatible schema range is rejected; last-known-good is restored; old save remains readable; failure of an optional package cannot block the core offline game.
- **Fixture requirement:** Manifest fixtures: valid, corrupted checksum, out-of-range schema.
- **Notes:** Remote content is LATER (CUT-024).

### QAT-036 — Economy: <= 1 resource, deterministic source per sink in same chapter, no irreversible loss on failure

- **Criterion:** [VALIDATOR] ResourceLedger declares <= 1 resource type; every sink is reachable by a deterministic source within the chapter it is introduced. [PLAYTEST] >= 70% can explain what the resource is for after first acquiring it. [BUILD] no failed attempt reduces the ledger below its pre-attempt value.
- **Fixture requirement:** Ledger fixture with one resource; sink/source graph per chapter.
- **Notes:** If the Gold Slice cuts the resource (PD-004 fallback), this item is marked superseded rather than deleted.

## Coverage summary

- PD covered by ≥1 item: PD-001, PD-002, PD-003, PD-004, PD-005, PD-006, PD-007, PD-008, PD-010, PD-011, PD-012
- PD deliberately not turned into a QA item:
  - PD-009: DEFERRED_TO_EVIDENCE; its unlock criterion (>= 30% voluntary replay) is observable in QAT-026 continuation data but is a Product scope decision, not a QA gate.
  - PD-013: DEFERRED_TO_HUMAN (title).
  - PD-014: DEFERRED_TO_HUMAN (monetization). QA enforces the design constraint indirectly through QAT-005 (currency cap) and QAT-036.
  - PD-015: DEFERRED_TO_EVIDENCE; requires AI-13 production-cost evidence.
  - PD-016: Pointer to cut list; enforced by QAT-005 counters and QAT-030 vocabulary.
- F10 covered: F10-001, F10-002, F10-003, F10-004, F10-005, F10-006, F10-007
- IGM covered: IGM-001, IGM-001b, IGM-002, IGM-002b, IGM-003, IGM-004, IGM-004b, IGM-005, IGM-005b, IGM-005c, IGM-006, IGM-006b, IGM-006c, IGM-006d, IGM-007, IGM-008
- IGM not turned into a QA item:
  - IGM-003b: Documentation-form competitor review owned by AI-01 + human; QA verifies existence only via QAT-031 doc review.
  - IGM-006e: SHOULD placeholders for AI-11/AI-12 budgets; QA verifies EVIDENCE format only.

## Executability snapshot (Phase 00)

| Status | Count |
|---|---|
| BLOCKED_ON_CONTRACT | 19 |
| BLOCKED_ON_SOURCE | 2 |
| DEFINED | 13 |
| EXECUTABLE_NOW | 2 |

| Method | Count |
|---|---|
| BUILD | 9 |
| DOC_REVIEW | 1 |
| PLAYTEST | 9 |
| VALIDATOR | 17 |

Only `EXECUTABLE_NOW` items (QAT-030, QAT-031) have been executed in Phase 00; see `evidence/`. Every other item is a specification awaiting a contract, a build or a cohort. No number in this document is a measurement.

## Regeneration

This file is generated from the register. Do not hand-edit tables; edit the JSON and re-render, then run `python3 08_QA_RELEASE/phase_00/QA_PHASE00_VALIDATOR.py`.
