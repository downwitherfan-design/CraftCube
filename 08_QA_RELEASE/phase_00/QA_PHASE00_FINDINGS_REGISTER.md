# CraftCube — QA Phase 00 Findings Register

| Field | Value |
|---|---|
| Owner | AI-10 — QA / Automation / Quality Engineering |
| Document ID | `CC.QA.FINDINGS` |
| Version | 1.0.0 |
| ID family | `QAF-###` — QA finding. Immutable once released; a finding is closed by status change, never deleted. |
| Rule | Every finding is evidence-driven (exact path/line/command). QA does **not** fix producer files; each finding is routed to its owner as an actionable request with an acceptance test. |

## Status vocabulary

`OPEN` · `ACKNOWLEDGED` (owner confirmed) · `RESOLVED` (owner shipped a fix; QA verified) · `WONT_FIX` (owner decision recorded) · `SUPERSEDED`

## Severity vocabulary

- **BLOCKER** — prevents a QA item from ever being executable or prevents the Phase 00 gate from being declared.
- **MAJOR** — will produce a wrong or unmeasurable gate result if not fixed before the phase in which the item is measured.
- **MINOR** — inconsistency that does not change a gate result.
- **INFO** — observation for the owner; no action required by QA.

---

## QAF-001 — No governance ID registry exists to register QA ID families

- **Severity:** MAJOR · **Status:** OPEN · **Owner:** AI-13
- **Evidence:** `06_CONTRACTS/EVENT_AND_ID_POLICY.md` requires "search repository → verify absent → assign canonical owner → record meaning" and "CI should fail on duplicate canonical IDs where deterministic registry validation is possible", but no registry file exists in any branch (`git ls-files | grep -i registry` on `main` returns only `06_CONTRACTS/CONTRACT_REGISTRY_TEMPLATE.md` and `06_CONTRACTS/V7_MASTER_CONTRACT_REGISTER.md`, neither of which lists ID families). AI-01 made the same request in `PRODUCT_LOCK_V1.md` §12 for `PD/F10/IGM/CUT`.
- **Request:** create a canonical ID-family registry and register `QAT-###` (verification items, `CC.QA.TRACE`), `QAR-###` (terminology rules, `CC.QA.TERMRULES`), `QAF-###` (findings, `CC.QA.FINDINGS`), `PT-####-###` (playtest session IDs) as owned by AI-10. Collision search performed by QA on all 15 remote branches: no existing use of these stems (`git grep -ohE "\b(QAT|QAR|QAF)-[0-9]{3}\b" <every branch>` → empty).
- **Acceptance test:** registry lists the four families with owner AI-10; a duplicate-stem validator (AI-13-owned) passes.

## QAF-002 — `integration` branch did not exist at Phase 00 start; PR target ambiguous

- **Severity:** MINOR · **Status:** RESOLVED (observed) · **Owner:** AI-13
- **Evidence:** At session start `git ls-remote --heads origin integration` returned nothing; only `ai-13-integration` existed. AI-02 recorded the same as U-05 in `00_CONTROL/PROGRESS.md` (branch `ai-02-core`). A later `git fetch` in this session shows `refs/heads/integration` now exists at `584141c` (same as `main`).
- **Request:** none further; AI-13 should confirm in `07_GITHUB/GITHUB_MODEL.md` that `integration` is the PR target (it currently is by the diagram).

## QAF-003 — Device matrix missing; `DEVICE_MATRIX_TEMPLATE.csv` owner column contradicts ownership model

- **Severity:** MAJOR · **Status:** OPEN · **Owner:** AI-11 (matrix), AI-13 (template ownership ruling)
- **Evidence:** `PRODUCT_LOCK_V1.md` §5 marks "Device tiers … MISSING (no matrix in repo yet)"; `IGM-006b` is `UNMEASURED` until AI-11 publishes it. The only matrix artefact, `08_QA_RELEASE/DEVICE_MATRIX_TEMPLATE.csv`, assigns `Owner` = `AI-07` for Low/Mid/High and `AI-05` for Tablet, contradicting `00_CONTROL/13_AI_EXECUTION_MANUAL.md` (AI-11 owns "low/mid/high device behavior"). The file sits in a QA-owned folder but its content is AI-11's domain.
- **Impact:** `QAT-025`, `QAT-028` are `BLOCKED_ON_SOURCE`; `deviceTier` in every session record is `UNKNOWN`.
- **Request (AI-11):** publish the device matrix with tier definitions and measurement method. **Request (AI-13):** rule whether the CSV template moves to an AI-11 path or is rewritten by AI-11 in place; QA will not edit the owner column itself.
- **Acceptance test:** `deviceTier` enum in `fixtures/playtest_session_record.schema.json` maps 1:1 to the published tiers.

## QAF-004 — Cut-list counting source `CC.NARRATIVE.CHAPTER` and other counting sources are undefined

- **Severity:** MAJOR · **Status:** OPEN · **Owner:** AI-09 (chapter definition), AI-13 (complexity report)
- **Evidence:** `CUT_LIST_AND_COMPLEXITY_BUDGET.md` §3 names counting sources such as `CC.NARRATIVE.CHAPTER`, `CC.PUZZLE.AFFINITY`, "loadout schema", "quest UX", "AI-07 screen inventory". `git grep -n "CC.NARRATIVE.CHAPTER\|CC.PUZZLE.AFFINITY"` across all branches finds them only in the cut list itself. No chapter definition schema exists anywhere.
- **Impact:** `QAT-005` (complexity counters) and `QAT-006` (chapter question introduced/advanced) cannot be automated; PD-003's `[VALIDATOR]` complexity report has no data source.
- **Request:** in Phase 01 contract freeze, define the chapter definition contract (owner AI-09) with `questionIntroduced` (exactly 1) and `questionsAdvancedOrResolved` (≥ 1) as data fields, and register the counting-source IDs. QA will supply positive/negative fixtures once the schema exists.

## QAF-005 — Ownership of Smart Assist rules and puzzle tile presentation contract is not stated

- **Severity:** MAJOR · **Status:** OPEN · **Owner:** AI-13 (ruling) with AI-03 / AI-04 / AI-07
- **Evidence:** `PD-007` acceptance `[VALIDATOR] No assist level definition performs a move` and `PD-011` `[VALIDATOR] tile identity encoded by ≥ 2 channels … in the presentation contract`. `V7_MASTER_CONTRACT_REGISTER.md` lists no assist contract and no presentation contract. AI-07 raised the presentation side as `D-UX-04` (`11_UIUX/phase_00/UX_PRODUCT_LOCK_AI07.md`, branch `ai-07-uiux`); AI-03 owns mastery rules per the execution manual; AI-04 owns runtime interaction.
- **Impact:** `QAT-013` and `QAT-016` have a provisional `fixOwner` (AI-03 / AI-07) that may be wrong.
- **Request:** AI-13 to record the owner of (a) assist-level definitions, (b) the tile presentation DTO, in the Phase 01 contract register; QA will update `fixOwner` (patch version of `CC.QA.TRACE`).

## QAF-006 — Two different definitions of "unintended input" exist (IGM-006 vs AI-04 SC-R1)

- **Severity:** MAJOR · **Status:** OPEN · **Owner:** AI-01 + AI-04
- **Evidence:** `INVESTMENT_GATE_METRICS.md` `IGM-006`: "≤ 2 unintended actions per 10 minutes, median across cohort … logged by the build's debug counter (AI-04 to provide)"; HARD_STOP > 5. `04_AI_ACCOUNTS/AI-04/phase_00/07_SUCCESS_CRITERIA_AND_MEASURABLE_BOUNDARIES.md:18` (branch `ai-04-gameplay`) `SC-R1`: "Twists the player reports as unintended ÷ total Twists … ≤ 2 % unintended (proxy: twists undone within 1.5 s of commit ≤ 4 %); > 5 %". One is a **count per time**, the other a **rate per twist**; the same session can pass one and fail the other.
- **Impact:** `QAT-028` cannot state a single pass rule.
- **Request:** AI-01 and AI-04 agree one canonical definition and unit (QA recommendation: keep IGM-006's count-per-10-minutes as the product gate, and record AI-04's proxy as a secondary engineering metric in the same session record). QA will add the agreed proxy field to the session schema (minor version).
- **Acceptance test:** one definition, one threshold, one HARD_STOP, referenced by both documents.

## QAF-007 — Playtest exit-question wording needs AI-01 acceptance (Q4b added, Q7–Q10 derived)

- **Severity:** MINOR · **Status:** OPEN · **Owner:** AI-01
- **Evidence:** `FIRST_10_MINUTES_PROOF.md` §Playtest protocol handoff lists six exit questions and delegates freezing "verbatim wording … by AI-10 with AI-01 review". `QA_FIRST10_PLAYTEST_PROTOCOL_V1.md` §7 adds Q4b (choice recognition, needed to measure F10-005's "≥ 70% recognize they made a choice") and lifts Q7–Q10 from `IGM-005b`, `IGM-008`, `IGM-001b`, `IGM-005c` method text.
- **Request:** approve or amend Q4b and Q7–Q10; protocol then moves from `1.0.0-draft` to `1.0.0`.

## QAF-008 — Reward/resource idempotency key not yet a contract requirement

- **Severity:** MAJOR · **Status:** OPEN · **Owner:** AI-02 (RewardDefinition/ResourceLedger state), AI-13 (event policy)
- **Evidence:** `QUALITY_AND_RELEASE.md` Gate I: "rewards cannot be duplicated through interruption/retry abuse"; `EVENT_AND_ID_POLICY.md`: events must document "whether duplication is possible". No contract text yet requires reward grants to carry an idempotency key or a deterministic grant ID.
- **Impact:** `QAT-012` (duplication abuse) has no testable field.
- **Request:** Phase 01 `RewardDefinition` / `WorldStateEvent` contracts specify a stable `grantId` (or equivalent) such that re-delivery of the same grant is a no-op; QA supplies the double-delivery fixture.

## QAF-009 — Item identity card six-question answers must be data, not prose

- **Severity:** MAJOR · **Status:** OPEN · **Owner:** AI-02 (`ItemIdentity` contract)
- **Evidence:** `PD-002` `[VALIDATOR] Every equipment item declares ≥ 2 affirmative answers to the Bible §9 six-question test, recorded in its item identity card`; `V7_1_WORLDCLASS_UPGRADE.md` §5.1 lists the identity-card fields but not the six answers as fields.
- **Impact:** `QAT-004` cannot be a validator if the answers are free text.
- **Request:** `ItemIdentity` carries six explicit booleans (or an enum per question) so the ≥ 2 rule is countable.

## QAF-010 — Terminology INFO scan: design documents legitimately mention rejected terms; one owner check requested

- **Severity:** INFO · **Status:** OPEN · **Owner:** AI-09
- **Evidence:** `evidence/validator_run_with_ai-01-product_overlay.log`: 593 `INFO C2 DESIGN_DOC` lines; 0 `FAIL` in IDENTIFIER / PLAYER_FACING scopes. Breakdown on the `ai-10-qa` checkout: QAR-001 (franchise names) 238, QAR-007 ("the core"/"the matrix"/"the nexus") 290, QAR-006 (auto-solve/cheat) 22, QAR-005 (damage/attack) 3, QAR-004 (loot/xp) 2. Spot check: every sampled QAR-004/005 line is a negation or a non-equipment sense (e.g. `CRAFTCUBE_GAME_MASTER_BIBLE.md:103 "- a loot-grind game,"` under Non-goals). QAR-001 lines are dominated by the phase prompts' repeated "not a Minecraft clone" sentence.
- **Request:** none required. AI-09 may wish to confirm that no design document uses a rejected term *affirmatively*; QA's scope-aware rule set intentionally does not fail design prose.

## QAF-011 — `validate_ownership.py` / `CODEOWNERS_EXAMPLE.txt` map `tests/` and `QA/` to AI-07

- **Severity:** MINOR · **Status:** OPEN (duplicate of AI-07's IR-AI07-002) · **Owner:** AI-13
- **Evidence:** `07_GITHUB/scripts/validate_ownership.py` `OWNERS = {... 'tests/':'AI-07', 'QA/':'AI-07' ...}`; `07_GITHUB/CODEOWNERS_EXAMPLE.txt` `/tests/ @AI-07`, `/QA/ @AI-07`. `13_AI_EXECUTION_MANUAL.md` assigns automated tests to AI-10. Both files self-describe as examples. AI-07 already reported this (`UX_PRODUCT_LOCK_AI07.md` §13, branch `ai-07-uiux`).
- **Request:** when AI-13 produces the real ownership map, `08_QA_RELEASE/`, `tests/` (or the engine-appropriate test root) map to AI-10.

## QAF-012 — Kickoff procedure says "eight branches"; model has thirteen

- **Severity:** MINOR · **Status:** OPEN · **Owner:** AI-13
- **Evidence:** `05_PROMPTS/PHASE_KICKOFF_PROCEDURE.md:5` "هشت branch مستقل" (eight independent branches) vs 13 tracks everywhere else (`07_GITHUB/GITHUB_MODEL.md`, `00_CONTROL/manifest.json` `"accounts": 13`).
- **Request:** textual fix by the owner; no QA impact.

---

## Summary

| Severity | Count | IDs |
|---|---|---|
| BLOCKER | 0 | — |
| MAJOR | 7 | QAF-001, 003, 004, 005, 006, 008, 009 |
| MINOR | 4 | QAF-002, 007, 011, 012 |
| INFO | 1 | QAF-010 |

No finding blocks the Phase 00 QA deliverables themselves; the MAJOR items block **Phase 01 automation** of the named QAT items and are therefore Phase 01 contract-freeze inputs.
