# Risk Register — CraftCube (AI-13 owned)

**Scope:** cross-track, integration, architecture-health and release-gate risks. Track-internal risks stay in each account's handoff; they are promoted here only when they affect another account or a gate.
**ID rule:** `RISK-nnnn`, sequential, never reused. **Likelihood/Impact:** L/M/H. **States:** OPEN, MITIGATING, ACCEPTED (requires human record for release-blocking risks per `00_CONTROL/13_AI_EXECUTION_MANUAL.md`), CLOSED.

| ID | Title | Owner | L | I | Phase raised | State |
|---|---|---|---|---|---|---|
| RISK-0001 | Engine/toolchain not available to every AI account | AI-13 → OD-0002 (Human) | H | H | 00 | OPEN |
| RISK-0002 | No CI, branch protection or ownership enforcement exists | AI-12 (CI) / Human (protection) | H | H | 00 | OPEN |
| RISK-0003 | Stale ownership tooling could enforce wrong owners once CI exists | AI-12 | M | M | 00 | OPEN |
| RISK-0004 | Three overlapping contract vocabularies → duplicate semantic systems | AI-13 | M | H | 00 | MITIGATING |
| RISK-0005 | Phase 00 identity/story/scope locks require Human decisions that may not arrive before Phase 01 | AI-01 + Human | M | H | 00 | OPEN |
| RISK-0006 | Equipment/affinity/companion layers erode protected puzzle mastery (DD-001/002/012) | AI-01 (gate) / AI-03 / AI-02 | M | H | 00 | OPEN |
| RISK-0007 | World-memory + narrative flags + quest states explode save size / permutations | AI-02 / AI-09 / AI-03 | M | M | 00 | OPEN |
| RISK-0008 | Terminology drifts across tracks before AI-09 publishes stable term/localization keys | AI-09 | H | M | 00 | OPEN |
| RISK-0009 | Residual proprietary (source-GDD) naming or presentation leaks into content | AI-09 (terms) / AI-05 / AI-06 (assets) / AI-01 (IP decision) | L | H | 00 | OPEN |
| RISK-0010 | Parallel tracks build against un-frozen DRAFT contracts and diverge | all producers; AI-13 gate | H | M | 00 | MITIGATING |
| RISK-0011 | Sandbox instability loses uncommitted governance work | AI-13 | M | L | 00 | MITIGATING |
| RISK-0012 | Complexity budget grows silently (currencies, slots, flags, systems) | AI-13 (tracking) / AI-01 (decision) | M | H | 00 | MITIGATING |

---

### RISK-0001 — Engine/toolchain not available to every AI account
- **Description:** `02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md` locks Unity 6 + URP + Android. The AI-13 session that produced this register runs in a Flutter/Dart sandbox with no Unity installation (VERIFIED: `flutter --version` succeeds, no `Unity` binary). Other accounts' environments are UNKNOWN. If Phase 02 Bootstrap assumes every account can open the Unity project, tracks will block or hallucinate build results.
- **Trigger:** Phase 02 kickoff.
- **Mitigation:** OD-0002 asks Product/Human to confirm the engine lock and state which accounts need engine access vs. which can work on pure data/contract/fixture surfaces. Until then all accounts must treat build/device claims as BLOCKED, not PASS (`05_PROMPTS/00_MASTER_CONTROL_PROMPT.md` Evidence Rule).
- **Rollback/contingency:** None needed at Phase 00; no engine artifacts exist.

### RISK-0002 — No CI, branch protection or ownership enforcement exists
- **Description:** Baseline has no `.github/workflows`, no CODEOWNERS in effect, and `integration`/`main` are unprotected (VERIFIED: branch created and pushed without review). "Merge is a gate, not a reward" (`01_GOVERNANCE/MULTI_AI_OPERATING_MODEL.md` principle 7) is currently unenforceable.
- **Trigger:** First PR to `integration`.
- **Mitigation:** OD-0001 requests Human admin to apply `07_GITHUB/BRANCH_PROTECTION_CHECKLIST.md`. AI-12 owns CI creation (Phase 01/02). Until then AI-13 performs manual gate review using `INTEGRATION_ORDER_AND_MERGE_SEQUENCE.md` and refuses fast-forward merges without a handoff.
- **Contingency:** If a bad merge lands, revert commit on `integration`; `main` remains at baseline.

### RISK-0003 — Stale ownership tooling could enforce wrong owners once CI exists
- **Description:** See CR-0002. If AI-12 wires `validate_ownership.py` into CI unchanged, AI-08 would "own" `.github/` and AI-07 would "own" tests.
- **Mitigation:** CR-0002 must be RESOLVED before any ownership check is enabled. AI-13 gate blocks CI PRs that enable ownership validation while CR-0002 is OPEN.

### RISK-0004 — Three overlapping contract vocabularies
- **Description:** Register PascalCase names, `CC.*` IDs and PROGRESS.md baseline names do not agree (`PHASE00_PREFLIGHT_FINDINGS.md` §4). Without a single registry, two accounts could freeze `ItemDefinition` and `CC.ITEM.DEFINITION` as different schemas.
- **Mitigation (applied):** `registry/contract_registry.json` maps every name to one canonical ID with aliases; `validate_registry.py` fails on duplicate IDs/aliases. Residual overlaps are CR-0005/0006/0007.
- **Residual:** Medium until Phase 01 owners answer the CRs.

### RISK-0005 — Human decisions may not arrive before Phase 01
- **Description:** Phase 00 gate requires human approval of product identity, story canon and scope (`00_CONTROL/13_AI_EXECUTION_MANUAL.md` "Human approval gates"). Contracts cannot be RELEASED until then (`00_CONTROL/CRAFTCUBE_START_SEQUENCE.md` step 6).
- **Mitigation:** `PHASE00_INTEGRATION_GATE.md` lists every open decision (OD-nnnn) in one place with the blocked downstream item. Phase 01 may proceed to FROZEN (not RELEASED) contracts using the provisional canon; any later canon change is a MAJOR version bump with migration.

### RISK-0006 — Equipment/affinity/companion layers erode protected puzzle mastery
- **Description:** Five item families, four suggested slots, upgrade branches, resonance, set synergy, puzzle affinity and companion capability each individually respect DD-002; combined they can still auto-solve or make observation unnecessary.
- **Detection:** `08_QA_RELEASE/QUALITY_AND_RELEASE.md` Gate I "equipment cannot bypass protected puzzle mastery rules"; AI-10 tests.
- **Mitigation:** AI-13 requires every `CC.EQUIPMENT.EFFECT` fixture submitted in Phase 01+ to declare which of the eight effect categories it uses and to include a negative test proving it does not change legal-move outcome. Tracked in `COMPLEXITY_BUDGET.md`.

### RISK-0007 — World-memory / narrative flags / quest states explode persistence
- **Description:** `WORLD_BIOME_BIBLE_V7.md` allows 7 state kinds × 5 tiers per biome; `CharacterMemory`, `NarrativeMemoryFlag`, `QuestState` add flags. V7_1 §2.4 "Memory with restraint".
- **Mitigation:** `COMPLEXITY_BUDGET.md` tracks flag/state counts; AI-02 save schema must declare a maximum flag count per release; AI-13 gate rejects a save-schema freeze without that ceiling.

### RISK-0008 — Terminology drift before stable term keys exist
- **Description:** Canon terms exist as prose only (Axis Loom, Weaver, Hearthwild, …). Twelve tracks writing Phase 00 documents in parallel will spell/capitalize/translate them differently. Localization keys are an AI-09 Phase 00 deliverable that does not exist yet.
- **Mitigation:** Downstream tracks quote terms exactly as in `00_CONTROL/CRAFTCUBE_GAME_MASTER_BIBLE.md` / `01_PREPRODUCTION/STORY_BIBLE_V7.md` and mark them "provisional canon" until `CC.LOCALIZATION.KEY` is FROZEN. AI-13 gate checks new documents for unregistered proper nouns.

### RISK-0009 — Residual proprietary naming/presentation
- **Description:** `10_SOURCE_REFERENCE/SOURCE_GDD_NOTES.md` confirms the source GDD used Minecraft-specific names/creatures. Baseline grep (`evidence/phase00_preflight_repo_facts.txt`) shows only "not a clone" statements — no leaked content names today. Risk is future asset/creature naming and any block-building visual language.
- **Mitigation:** Asset metadata `source`/`license` required by `09_ART_AUDIO/ASSET_PIPELINE.md`; AI-13 gate rejects assets without provenance; Human IP decision recorded in OD-0005.

### RISK-0010 — Tracks build against un-frozen DRAFT contracts
- **Description:** All 27 registry entries are DRAFT. Independent execution policy encourages mocks; without a shared fixture format, mocks diverge.
- **Mitigation (applied):** `CONTRACT_REGISTRY.md` shows status per contract; `DEPENDENCY_GRAPH.md` states the mock policy per edge; `validate_registry.py` refuses a consumable status without a version. Phase 01 target: every Gold-Slice contract FROZEN with a fixture path.

### RISK-0011 — Sandbox instability loses governance work
- **Mitigation (applied):** One change → commit → push discipline on `ai-13-integration` (VERIFIED by commit history). Credential refresh required once during this phase (push failed with "could not read Username", re-run of GitHub setup fixed it).

### RISK-0012 — Silent complexity growth
- **Description:** V7_1 §16 requires tracking currencies, item families, slots, upgrade materials, quest states, world states, flags, dependencies, runtime systems. Nothing tracked them before Phase 00.
- **Mitigation (applied):** `COMPLEXITY_BUDGET.md` baseline captured from the bibles; every phase gate requires an updated count and a Product decision for any increase.
