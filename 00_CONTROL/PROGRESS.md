# PROGRESS.md — Shared Project Memory

## Current phase
Phase 0 / planning package

## Contract baseline
- Simulation: TBD 1.0.0
- Content schema: TBD 1.0.0
- Save schema: TBD 1.0.0
- Event IDs: TBD 1.0.0
- Asset manifest: TBD 1.0.0

## Status
This file is deliberately short. Each AI must update only its own section in the actual project implementation.

## Required update format
### AI-XX
- Branch:
- Task:
- Status: NOT_STARTED / IN_PROGRESS / BLOCKED / READY_FOR_REVIEW / MERGED
- Contract versions consumed:
- Contract versions changed:
- Tests:
- Known issues:
- Next integration action:

### AI-13
- Branch: `ai-13-integration` (PR target `integration`, created by AI-13 from `584141c` in Phase 00)
- Task: Phase 00 — Integration / Governance contribution to Product/IP Lock
- Status: READY_FOR_REVIEW
- Contract versions consumed: none (no contract is FROZEN/RELEASED yet)
- Contract versions changed: none. Registered 27 contracts as DRAFT with canonical `CC.*` IDs in `11_INTEGRATION/registry/contract_registry.json`; no version assigned.
- Tests: `python3 11_INTEGRATION/scripts/validate_registry.py --check-render` → PASS (27 DRAFT, 0 consumable). Negative tests: `11_INTEGRATION/evidence/phase00_validator_negative_tests.txt` (10 injected defects FAIL, baseline PASS).
- Known issues: CR-0001…CR-0009 open to owning accounts; OD-0001…OD-0007 open Product/Human decisions (PD-002/004/023 on `ai-01-product` will close OD-0004/0006/0007 once PR #10 merges); RISK-0001…RISK-0012 registered. Phase 00 gate verdict NOT PASSED pending merges (`11_INTEGRATION/PHASE00_INTEGRATION_GATE.md`). Preliminary mechanical review of all incoming PRs: `11_INTEGRATION/PHASE00_GATE_REVIEW_INCOMING.md` (PRs #1 and #5 returned for base retarget, CR-0008).
- Next integration action: merge PR #9 `ai-13-integration` → `integration` first (step 1 of `11_INTEGRATION/INTEGRATION_ORDER_AND_MERGE_SEQUENCE.md`), then gate-review PR #10 (AI-01) and PR #5 (AI-09, after retarget).
- Recovery session 2026-10-10 (OpenHands): full local Phase 00 gate re-run on the would-be integrated tree. Verdict: PR #9 PASS (step 1), PR #10 PASS (step 2), **PR #5 (AI-09) FAIL — its own validator exits 1 on the PR head (CR-0011)**; all other 9 account branches' validators PASS. Filed CR-0010 (PROGRESS.md shared-append conflict) and CR-0011. Persistent checkpoint: `11_INTEGRATION/OPENHANDS_RESUME_STATE.md`. **Blocker: the session's `GITHUB_TOKEN` is read-only (403 on push/PR write), so the recovery commits and merges are prepared locally but not pushed; human/admin action required.**
- Session 7 2026-10-10 (AI-13, OpenHands): engine-migration completion + Chapter 01 quality, on **`godot-migration` (PR #11)** and **`ai-01-product-godot` (PR #12)**. (a) AI-01 recorded **PD-030** (Godot 4.x + GDScript, Android-first, superseding PD-025) → **CR-0013 RESOLVED**; an E3 source-baseline drift found by AI-10's QA validator (PD-030 labelled v1.3.0 while the header stayed 1.2.0) was fixed (register→1.3.0, CUT→1.2.0), and accidentally-staged build artifacts (`dist/*.apk`, `game/.godot/*`) were removed from the index. (b) Chapter 01 rule conflict resolved against the **real Godot 4.7.2 engine**; **CR-0014** filed to AI-03 for binding confirmation (the draft `rule.axis_lock{X,Z}` on `level.01.awaken` is degenerate: solved on scramble, min_solve=0). (c) HUD six-wide row → 3-column grid in a ScrollContainer (mobile 360px); scene-integration test `remove_child` engine-ERROR fixed. (d) Godot suite **166 passed / 0 failed** (was 134); validator sweep **13/13**; QA validator **fail=0** on the intended combined tree; **clean-runner CI run 38078776142 = success** (166 tests + signed debug APK, CI: PASS). **Phase 00 gate verdict: NOT PASSED** (human OD-0001/OD-0005 open; AI-03 binding CR-0014 pending; no PR self-merged). Checkpoint: `11_INTEGRATION/OPENHANDS_RESUME_STATE.md` §15.
### AI-01
- Branch: `ai-01-product`
- Task: Phase 00 — Product/IP Lock (product truth, decisions, first-10-minutes proof, Investment Gate metrics, cut list, progression/anti-grind/expression policy, competitor review) + recording of Human Product Authority closure decisions
- Status: READY_FOR_REVIEW — Human decisions RECORDED as PD-025 (engine: Unity 6 + URP + Android), PD-026 (title "CraftCube" working; no trademark claim; Asterra internal-only; `CC.` namespace title-independent), PD-027 (premium one-time purchase), PD-028 (Story Bible v0.1.0 canon baseline; Quiet Engine canonical; Verdant Archive LATER; Hold/Weave/Open working names), PD-029 (remaining human items). Integration gate verdict remains AI-13's.
- Contract versions consumed: none released (all `CC.*` registry entries are DRAFT per `11_INTEGRATION/registry/contract_registry.json` on `ai-13-integration`). Product docs reference contract IDs by name only.
- Contract versions changed: none. AI-01 document versions: `CC.PRODUCT.LOCK` 1.1.0, `CC.PRODUCT.DECISIONS` 1.2.0, `CC.PRODUCT.FIRST10` 1.0.0, `CC.PRODUCT.IGM` 1.0.2, `CC.PRODUCT.CUTLIST` 1.1.0, `CC.PRODUCT.PROGRESSION_POLICY` 1.0.1, `CC.PRODUCT.COMPETITORS` 1.0.0
- Tests: `python3 01_PREPRODUCTION/PRODUCT/validate_product_lock.py` → pass=14 fail=0 exit 0 (log: `01_PREPRODUCTION/PRODUCT/evidence/validate_product_lock_run_phase00_closure.log`); 9 negative self-tests exit 1; PD-025..029 collision-free across all branches
- Known issues: remaining human items per PD-029 — final title trademark/legal clearance (before brand lock/Phase 14), Asterra legal clearance, retail price, Unity licence custody + CI build environment (Human Project Owner, before Phase 02), branch protection (OD-0001), signing custody (Phase 14). Toolchain versions deliberately unpinned (PD-025). Downstream applications pending: AI-09 S1 rename + Ch.08 LATER marking, AI-13 OD-0002/0005 closure + complexity budget (biomes 5, chapters ≤ 9), owners' "superseded by PD-020" annotations.
- Next integration action: PR #10 `ai-01-product` → `integration` (merge step 2). AI-13: close OD-0002 (PD-025), OD-0005 product part (PD-026), OD-0006 (PD-021), OD-0007 (PD-020), OD-0003 (PD-022), OD-0004 (PD-023); register PD/F10/IGM/CUT/AGP/CMP families; re-rate RISK-0001/RISK-0008. AI-09: close OD-01/02/03/04/05/08 via PD-026/024/017+028/018+028/019/024; apply Quiet Engine rename; mark Verdant Archive/Ch.08 LATER.
### AI-09
- Branch: `ai-09-narrative`
- Task: Phase 00 — Narrative / Lore / Localization contribution (Story Bible refinement + narrative registers + fixtures)
- Status: READY_FOR_REVIEW
- Contract versions consumed: none released (all contract families in `06_CONTRACTS/` are unversioned names; PROGRESS baseline "TBD 1.0.0")
- Contract versions changed: none. New DRAFT fixtures proposed for Phase 01 freeze: `cc.narrative.canon_registry` 0.1.0, `cc.loc.strings` 0.1.0 (both in `11_NARRATIVE/fixtures/`)
- Tests: `python3 11_NARRATIVE/tools/validate_narrative_registry.py` → 24 pass groups, 0 failures (91 nar.* IDs, 85 loc.* keys, 10/12 flags)
- Known issues: PR target `integration` does not exist (only `ai-13-integration`); 11 open Product/Human decisions in `11_NARRATIVE/OPEN_DECISIONS_AI09.md`; item lore keyed to PROPOSED slugs pending AI-02 item IDs
- Next integration action: AI-13 review of PR from `ai-09-narrative` → `ai-13-integration`; AI-01 decision on OD-03 (Story Promise) and OD-04 (finale set)
### AI-02
- Branch: `ai-02-core`
- Task: Phase 00 — audit source GDD simulation concepts; define domain boundaries for a deterministic pure-C# core
- Status: READY_FOR_REVIEW
- Contract versions consumed: none (no contract is FROZEN/RELEASED yet; all `TBD 1.0.0`). Contract family *names* referenced read-only from `06_CONTRACTS/`.
- Contract versions changed: none
- Tests: `python3 02_ARCHITECTURE/AI02_DOMAIN_CONCEPT_REGISTER_VALIDATOR.py` → PASS (10 check groups, 0 findings; 11 bounded contexts, 39 concepts, 13/13 GDD bullets covered). Negative tests (duplicate key, bad enum/owner, missing source path, undefined open item, invented contract family, uncovered GDD bullet, IP-unsafe key) each produced FAIL on a throwaway copy.
- Known issues: source GDD ZIP not in repo (U-01); no `integration` branch exists, only `ai-13-integration` (U-05); ownership conflicts C-01/C-02 (narrative flags, quest state) and decisions D-01…D-07 routed to AI-13/AI-01 — see `02_ARCHITECTURE/AI02_CORE_DOMAIN_BOUNDARY_AUDIT_PHASE00.md` §10.
- Next integration action: AI-13 to confirm PR target branch and record decisions on §9 ownership splits; then AI-02 proceeds to Phase 01 contract freeze scoped by the 11 bounded contexts.
### AI-03
- Branch: `ai-03-puzzle`
- Task: Phase 00 — Product/IP Lock — puzzle vocabulary, mechanic families, level grammar, content principles (`05_PROMPTS/phase_00/ai_03.md`)
- Status: READY_FOR_REVIEW
- Contract versions consumed: none RELEASED exist (all `TBD 1.0.0`); design bibles and decision register consumed as intent
- Contract versions changed: none released. DRAFT shapes offered for Phase 01 freeze: `CC.CONTENT.CHAPTER_SIGNATURE 0.1.0`, `CC.CONTENT.LEVEL 0.1.0`, `CC.REWARD.DEFINITION 0.1.0`, `CC.DISCOVERY.DEFINITION 0.1.0` (`tracks/ai-03-puzzle-content/fixtures/phase00/`)
- Tests: `python3 tracks/ai-03-puzzle-content/validators/validate_phase00_content.py` → PASS (0 errors, 1 warning); `python3 -m unittest tracks/ai-03-puzzle-content/validators/test_validate_phase00_content.py` → 33 tests OK. Evidence: `tracks/ai-03-puzzle-content/evidence/phase00/validator_run.txt`
- Known issues: reachability/par unverified (no solver until Phase 03); Act III chapter↔biome mapping UNKNOWN; decisions AI03-D1..D5 and conflicts AI03-C1..C4 open — see `tracks/ai-03-puzzle-content/phase_00/08_OPEN_DECISIONS_AND_CONFLICTS.md`
- Next integration action: AI-13 to register `tracks/ai-03-puzzle-content/` ownership and name the PR target branch (`integration` does not exist on remote); AI-01 to decide AI03-D1..D5; AI-09 to resolve AI03-C1
### AI-04
- Branch: `ai-04-gameplay`
- Task: Phase 00 — Product/IP Lock — interaction vision, platform/input assumptions, IP-safe interaction terminology, gesture arbitration model, interruption/recovery requirements, equipment/world runtime interaction model, measurable success criteria, DRAFT contract proposal CC.INTERACTION.COMMAND 0.1.0. Deliverables under `04_AI_ACCOUNTS/AI-04/phase_00/`.
- Status: READY_FOR_REVIEW
- Contract versions consumed: none released (all baselines TBD). Referenced as intent only: INTERACTION_CONTRACTS.md (Command/State/Error contract text), AccessibilityPreference (AI-07, unversioned), PuzzleState/EquipmentEffect/CompanionReaction/DiscoveryDefinition (registered owners, unversioned).
- Contract versions changed: none. Proposed (DRAFT, not released): CC.INTERACTION.COMMAND 0.1.0.
- Tests: `python3 04_AI_ACCOUNTS/AI-04/phase_00/scripts/validate_ai04_phase00.py` → 28 passed, 0 failed (evidence: `04_AI_ACCOUNTS/AI-04/phase_00/evidence/validate_ai04_phase00.output.txt`). No Unity build, no device test — none exist yet.
- Known issues: no `integration` branch on remote (CONFLICT-04-01); ownership example files contradict account matrix (CONFLICT-04-02); 8 open decisions + 16 integration requests in `04_AI_ACCOUNTS/AI-04/phase_00/08_OPEN_DECISIONS_AND_INTEGRATION_REQUESTS.md`.
- Next integration action: AI-13 to review PR #6 (`ai-04-gameplay` → `integration`, https://github.com/downwitherfan-design/CraftCube/pull/6) and register CC.INTERACTION.COMMAND as DRAFT; AI-02/AI-07 to answer IR-04-01..08 before Phase 01 freeze.
### AI-05
- Branch: `ai-05-world`
- Task: PHASE00-AI05-ENV-DIRECTION-LOCK — Environment Art Direction Lock + Biome Presentation Identity Matrix + MOCK presentation fixture + fixture validator
- Status: READY_FOR_REVIEW
- Contract versions consumed: none FROZEN/RELEASED exist; World Biome Bible tier model (design intent); `CC.BIOME.STATE` name only (schema MISSING, mocked)
- Contract versions changed: none
- Tests: `python3 09_ART_AUDIO/environment/tools/validate_environment_fixtures.py` → exit 0, 9 passed / 0 failed; 7 negative mutations each exit 1
- Known issues: DEP-03 "Quiet Engine" vs "Silent Engine" naming (AI-09); DEP-04 screen orientation UNKNOWN; DEP-05 legacy AI-05→UI ownership mappings in `07_GITHUB/*` and `08_QA_RELEASE/DEVICE_MATRIX_TEMPLATE.csv`; presentation IDs DRAFT until Phase-1 freeze
- Next integration action: review/merge PR #2 `ai-05-world` → `integration`; AI-13 ratify `09_ART_AUDIO/environment/` as AI-05 path; AI-01 ratify boundaries/cut list. Handoff: `09_ART_AUDIO/environment/handoffs/AI-05_PHASE00_HANDOFF.md`
### AI-06
- Branch: `ai-06-creatures`
- Task: Phase 00 — Characters / Creatures / Animation / VFX direction lock, companion reaction model (DRAFT `CompanionReaction` outline), draft register, labeled fixture, validator, handoff. Artifacts under `01_PREPRODUCTION/CHARACTERS_VFX/`.
- Status: READY_FOR_REVIEW
- Contract versions consumed: none released (all `TBD 1.0.0`); worked from verified design docs and unmerged AI-01/AI-02 Phase 00 outputs (dependencies listed in lock §2)
- Contract versions changed: none (`CompanionReaction` proposed as `0.1.0-draft`, not consumable)
- Tests: `python3 01_PREPRODUCTION/CHARACTERS_VFX/tools/ai06_validate_phase00.py` → 187 passed, 0 failed
- Known issues: lock becomes LOCKED only after AI-01 product lock approval + AI-13 decisions D6-03/D6-04; no `integration` branch on remote (U6-02); D6-01 human-character fidelity and D6-02 ambient creatures need Product decisions; conflicts C6-01..C6-03 routed to owners
- Next integration action: PR `ai-06-creatures` → integration branch named by AI-13; see `01_PREPRODUCTION/CHARACTERS_VFX/AI06_PHASE00_HANDOFF.md`
### AI-07
- Branch: `ai-07-uiux`
- Task: Phase 00 — Product/IP Lock — UX/Motion/Accessibility contribution
- Status: READY_FOR_REVIEW
- Contract versions consumed: none released yet (all registry contracts TBD); design intent consumed from Game Master Bible, V7 Design Decision Register, V7.1 World-Class Upgrade §9/§13/§14, Technical Blueprint (UI architecture line)
- Contract versions changed: `AccessibilityPreference` **DRAFT 0.1.0** authored (AI-07 owned) at `11_UIUX/contracts/AccessibilityPreference.v0.1.0-draft.md`; not consumable until Phase 01 freeze
- Tests: `python3 11_UIUX/tools/validate_a11y_fixtures.py` → 6 fixtures, 0 failures, exit 0; mutation checks recorded in `11_UIUX/evidence/phase_00_validator_run.md`
- Known issues: no `integration` branch on remote (IR-AI07-001); ownership example files contradict execution manual (IR-AI07-002); 7 Product decisions pending (D-UX-01..07)
- Next integration action: AI-13 to confirm PR target branch and register `11_UIUX/` ownership; AI-01 to rule on D-UX decisions; Phase 01 freeze of `AccessibilityPreference`
### AI-08
- Branch: `ai-08-audio`
- Task: PHASE00-AI08-AUDIO-IDENTITY-LOCK — audio identity, IP-safe direction, adaptive audio language, DRAFT cue-ID contract + fixture + validator
- Status: READY_FOR_REVIEW
- Contract versions consumed: none released (all `TBD 1.0.0`); design references intended families by name only
- Contract versions changed: new DRAFT `CC.AUDIO.CUE` 0.1.0 (owner AI-08) — requires AI-13 registration; freeze targeted for Phase 01
- Tests: `python3 09_ART_AUDIO/AUDIO/scripts/test_validate_audio_cue_registry.py` → 17/17 passed; fixture validates with exit 0
- Known issues: `integration` branch MISSING on remote (PR target unavailable); CONFLICT in `07_GITHUB/CODEOWNERS_EXAMPLE.txt`/`validate_ownership.py` maps `/Assets/Audio/` to AI-06 (reported, not edited); open decisions AUD-OD-01..04
- Next integration action: AI-13 creates `integration`, registers `CC.AUDIO.CUE` DRAFT, opens PR `ai-08-audio` → `integration`; details in `09_ART_AUDIO/AUDIO/PHASE_00_HANDOFF_AI-08.md`
### AI-11
- Branch: `ai-11-performance`
- Task: Phase 00 — performance/Android contribution to Product/IP Lock: platform assumptions with evidence class, measurable boundaries `PERF-001..035` (all HYPOTHESIS), Android device tier definitions (no fabricated devices), measurement method standard, `PerformanceBudget` DRAFT 0.1.0 + fixture + validator. Workspace: `12_PERFORMANCE/`.
- Status: READY_FOR_REVIEW
- Contract versions consumed: none FROZEN/RELEASED exists. Read-only references: `PerformanceBudget` registry row (owner AI-11) in `06_CONTRACTS/V7_MASTER_CONTRACT_REGISTER.md`; AI-07 `AccessibilityPreference` 0.1.0-draft (branch `ai-07-uiux`, AI-11 as reader of `reduce_motion`); AI-01 `IGM-006b/006e` and Product Lock §5/§10 (branch `ai-01-product`).
- Contract versions changed: `PerformanceBudget` created as DRAFT 0.1.0 (`12_PERFORMANCE/contracts/`). Not consumable until Phase 01 freeze.
- Tests: `python3 12_PERFORMANCE/tools/validate_performance_budget.py` → exit 0; positive fixture PASS (35 entries, 23 gate, 0 measured); 4 negative fixtures under `_expect_invalid/` each correctly rejected (MEASURED without evidence, missing tier value, duplicate ID, `build_id: UNKNOWN`).
- Known issues: zero devices measured (by design — no engine project/build exists); `integration` branch missing on remote (C11-02); `DEVICE_MATRIX_TEMPLATE.csv` owner column stale (C11-01); min API level / Unity & URP versions UNKNOWN (U11-01); audio budgets deferred to Phase 01 (IR-AI11-010). Full list: `12_PERFORMANCE/phase_00/INTEGRATION_REQUESTS_AND_UNKNOWNS.md`.
- Next integration action: AI-13 to create `integration` and register AI-11 ID families (IR-AI11-005); AI-12 to confirm `build_id` exposure (IR-AI11-002); then AI-11 proceeds to Phase 01 freeze of `PerformanceBudget` 1.0.0 and drafting of `QualityTierState`.
### AI-12
- Branch: `ai-12-build`
- Task: PHASE00-AI12-RELEASE-DIRECTION-LOCK — Release & Build Direction Lock v1.0.0, Release Validation Gate Policy (RG-001..017), DRAFT contracts BuildProvenance / RemoteContentManifest / TelemetryEvent 0.1.0 + MOCK/NEG fixtures + stdlib validator, .gitignore and inactive CI templates
- Status: READY_FOR_REVIEW
- Contract versions consumed: none FROZEN/RELEASED exist (all `TBD 1.0.0`); `TelemetryEvent`/`RemoteContentManifest` ownership rows read from `06_CONTRACTS/WORLDCLASS_CONTRACTS_V7_1.md`; PD-010/013/014 read from unmerged `origin/ai-01-product` as product intent
- Contract versions changed: none (three new DRAFT outlines live under `12_RELEASE/contracts/`; registry inclusion requested)
- Tests: `python3 12_RELEASE/tools/validate_release_fixtures.py` → exit 0, 10 passed / 0 failed (3 positive MOCK, 7 NEG_ each failing on its declared RG); validator self-test with a mislabelled negative → exit 1. No build/CI/device run exists to claim.
- Known issues: RD-001 no `integration` branch on origin; RD-002 legacy `.github/`+`Release/`→AI-08 mapping in `07_GITHUB/*`; RD-003 `12_RELEASE/` path awaiting ratification; RD-004/005/006/007 Unity version, CI licence/keystore custody, applicationId/title, telemetry legal stance are UNKNOWN/HUMAN; RG-001..009/013..015 MISSING by design until domain owners publish validators
- Next integration action: AI-13 create `integration`, ratify path + fix ownership mapping, register `BuildProvenance` and `RG/RD/RC` ID families; PR `ai-12-build` → `integration`. Handoff: `12_RELEASE/handoffs/AI-12_PHASE00_HANDOFF.md`
### AI-10
- Branch: `ai-10-qa`
- Task: Phase 00 — make the product lock verifiable: traceability register for PD/F10/IGM/CUT criteria, IP/terminology rule set, first-10-minutes playtest protocol + pseudonymous session schema, deterministic validator, evidence-based findings.
- Status: READY_FOR_REVIEW
- Contract versions consumed: none frozen (all `TBD 1.0.0`). Contract family names referenced read-only from `06_CONTRACTS/`. Product inputs: `CC.PRODUCT.LOCK` / `DECISIONS` / `FIRST10` / `IGM` / `CUTLIST` 1.0.0 on `ai-01-product@2db84b5` (READY_FOR_REVIEW, unmerged).
- Contract versions changed: none
- Tests: `python3 08_QA_RELEASE/phase_00/QA_PHASE00_VALIDATOR.py` → exit 0, fail=0 (6 check groups A–F, 14 negative self-test cases). Evidence: `08_QA_RELEASE/phase_00/evidence/validator_run_ai-10-qa_only.log` (5 SOURCE_NOT_PRESENT skips) and `validator_run_with_ai-01-product_overlay.log` (all 8 sources cross-checked, 0 skips). No build/device/playtest executed — none exists.
- Known issues: 12 findings in `08_QA_RELEASE/phase_00/QA_PHASE00_FINDINGS_REGISTER.md` (7 MAJOR, all Phase 01 contract inputs; 0 BLOCKER). 25/36 QAT items blocked on contracts/sources by design. Protocol exit-question wording is `1.0.0-draft` pending AI-01 (QAF-007).
- Next integration action: PR `ai-10-qa` → `integration` after AI-01's PRODUCT docs merge (register cross-check E depends on them); AI-13 to register `QAT/QAR/QAF/PT` ID families (QAF-001).
### AI-13 — Session 8 (Godot gameplay-quality sprint)
- Branch: `godot-migration` (PR #11 → `integration`); commits `69de79d`..`309c4cf` (local in this runtime; push blocked by a read-only token).
- Task: Phase 00 closure continuation — find and fix real, player-visible defects by RUNNING the Godot slice, then reproduce the Android build on the fixed commit.
- Defects fixed (verified at runtime): (1) completion feedback clobbered — reward/discovery wrote over the world reaction, hiding authored narrative (`69de79d`); (2) cube camera off-centre and clipped left on every viewport (`298ec98`); (3) relaunch replayed the just-solved level instead of resuming (`4f4190f`); plus aligned-cue refresh after undo/restart and guarded mobile haptics (`8793822`).
- Tests: `godot --headless --path game --script res://tests/run_tests.gd` → **198 passed / 0 failed** (was 166). New regressions: `_test_completion_feedback`, `_test_camera_framing`, `_test_resume_selection`, `_test_chapter_playthrough`.
- Build: `bash game/ci/build_android.sh` → **CI: PASS** (import 0, tests 198/0, boot 0, signed debug APK, package `com.downwitherfandesign.craftcube` v0.1.0, arm64-v8a). Log: `game/docs/evidence/android_export_run_8793822.log`.
- Status: READY_FOR_REVIEW. Phase 00 gate remains **NOT PASSED**; no PR merged. Human decisions OD-0001 (branch protection) and OD-0005 (IP/title clearance) still open.
- Known limitations: no physical Android device (no device playtest); 4 verified commits unpushed (read-only credential); QA validator `fail=20` on this branch is pre-existing and fixed by PR #12.
- Checkpoint: `11_INTEGRATION/OPENHANDS_RESUME_STATE.md` (Session 8).

### AI-13 — Session 9 (Chapter 01 gameplay-quality sprint, continued)
- Branch: `godot-migration` (PR #11 → `integration`); commits `958566a..2067351` (pushed; remote synced).
- Task: Phase 00 closure continuation — fix real, player-visible defects by RUNNING the Godot slice, then reproduce the Android build.
- Defects fixed (verified at runtime): (1) domain labelled the BOTTOM face `U`, so the "U" control twisted an invisible face and contradicted authored "Align the top" hints — U now renders on top (`f3aa28b`); (2) `CubeView` was static-only → rebuilt as a position-based ANIMATED view (turn tweens about the cube centre, input locked in flight, re-synced to truth on settle) so overlapping inputs cannot desync render from logic (`f3aa28b`); (3) world rendered EMPTY after resume despite saved progress → `WorldView.sync_lit()` + capped `react()` (`1307db2`); (4) no partial objective feedback → `PuzzleEngine.objective_progress()` + HUD "Aligned N/M required faces" (`1307db2`); (5) `confirm_solve`/`next_level` could free the animating pivot mid-turn → now refuse while animating (`44d099d`).
- Defects fixed (additional): (6) status line now names the objective in player terms and shows par (`Align top, front · 1/2 aligned · Moves: 4 (par 7)`) — `3212201`.
- Tests: `godot --headless --path game --script res://tests/run_tests.gd` → **239 passed / 0 failed** (was 198). New: `_test_face_orientation`, `_test_layer_selection`, `_test_animation_locks_and_syncs`, `_test_world_state_and_resume`, `_test_objective_progress`, `_test_animated_chapter_end_to_end`, `_test_hud_status_text`.
- Build: `bash game/ci/build_android.sh` → **CI: PASS** on `2067351` (import 0, tests 239/0, boot 0, signed debug APK). Log: `game/docs/evidence/android_export_run_2067351.log`.
- Rendering evidence: real 720x1280 frames from the running scene (`game/docs/evidence/screenshots/`) prove on-screen playability; the cube changes after animated turns.
- Status: READY_FOR_REVIEW. Phase 00 gate remains **NOT PASSED**; no PR merged. Human decisions OD-0001 (branch protection) and OD-0005 (IP/title clearance) still open.
- Known limitation: no physical Android device (no device playtest) — the pipeline is VERIFIED, not a device run.
- Checkpoint: `11_INTEGRATION/OPENHANDS_RESUME_STATE.md` (Session 9).

### AI-13 — Session 10 (Epic 0.3 — Extended Gameplay Development, Milestones A–H)
- Branch: `godot-migration` (PR #11 → `integration`); commits `314d836` (A), `efda6de` (B), `a899179` (C), `bab56ee` (D), `5c075de` (E), `56be0bb` (F), `c21d897` (G), `5af28e1` (H) — all pushed; remote synced.
- Task: Phase 00 closure continuation — extend the playable slice with real, player-facing features, each with acceptance criteria, tests and evidence.
- Features (verified by running the Godot slice): (A) deterministic guided-solving — a cached self-consistent route whose HUD step applies the real move; (B) interactive orbit/zoom/reset camera with HUD input pass-through; (C) world remembers progression — one ward stone per level, warming ground, Nox on completion, one authoritative revealed count restored on resume; (D) per-face readiness readout (`PuzzleEngine.face_readiness()`; HUD "solid"/"N shades", objective faces marked); (E) equipment delivers its declared capability — the granted Rootweave Gauntlet's `perceive.resonance` surfaces faces one turn from settling, keyed off the effect slot and only while equipped (PD-002); (F) persisted large-text accessibility in a separate settings file; (G) progress flushed on the OS close/back request; (H) persisted reduced-motion toggle that still runs the real animated lifecycle.
- Tests: `godot --headless --path game --script res://tests/run_tests.gd` → **375 passed / 0 failed** (was 239). New: `_test_guided_solver_domain`/`_controller`, `_test_orbit_camera`, `_test_world_progression_landmarks`, `_test_face_readiness`, `_test_hud_readiness_line`, `_test_equipment_capability`, `_test_hud_resonance_line`, `_test_settings_persistence`, `_test_hud_big_text_persistence`, `_test_progress_flush_on_exit`, `_test_reduced_motion_persistence`.
- Build: `bash game/ci/build_android.sh` → **CI: PASS** on `5af28e1` (import 0, tests 375/0, boot 0, signed debug APK sha256 `018458ba…`). Log: `game/docs/evidence/session10_build.log`. GitHub Actions green on every pushed head.
- Rendering evidence: real 720x1280 frames from the running scene (`game/docs/evidence/screenshots/`); `capture_frames.gd` now preserves/restores the player save it used to overwrite.
- Status: READY_FOR_REVIEW. Phase 00 gate remains **NOT PASSED**; no PR merged. Human decisions OD-0001 (branch protection) and OD-0005 (IP/title clearance) still open. PR #12 (AI-01 `PD-030`) must merge before PR #11.
- Known limitation: no physical Android device (no device playtest) — the pipeline is VERIFIED, not a device run.
- Checkpoint: `11_INTEGRATION/OPENHANDS_RESUME_STATE.md` (Session 10).

### AI-13 — Session 11 (Epic 0.3 — versioned-APK release tooling)
- Branch: `godot-migration` (PR #11 → `integration`); commit `78dcad1` (release tooling). **Unpushed** — remote write regressed to BLOCKED (injected `GITHUB_TOKEN` has empty OAuth scopes → `403`); `origin/godot-migration` remains at `94ebe93`.
- Task: satisfy the new permanent requirement that every release-ready milestone publishes a real, downloadable Android APK via the repository's **GitHub Releases** (a CI run / local APK / Actions artifact alone is not sufficient).
- Delivered: single source of truth `game/app_version.json` (`0.2.0` / versionCode `2`); runtime reader `game/scripts/game/version.gd` (HUD shows the version from the same file); `game/ci/validate_version.py` (export preset + reader + released-ledger consistency, monotonic version codes, no version reuse); dependency-free `game/ci/verify_apk.py` (real AXML/APK metadata: package, versionName, versionCode, minSdk, architecture, signing); extended `game/ci/build_android.sh` (clean stale outputs → validate → test → export → verify → stage a versioned APK + `.sha256` + `.json` provenance; fail visibly otherwise); new `.github/workflows/craftcube-release.yml` (tag `v*`/dispatch → build, verify, artifact, GitHub Release); `12_RELEASE/ANDROID_RELEASE_POLICY.md` + release-notes template; CR-0015/CR-0016 route AI-12-owned file ratification.
- Tests: `godot --headless --path game --script res://tests/run_tests.gd` → **388 passed / 0 failed** (was 375). New: `_test_version_single_source_of_truth`, `_test_hud_version_label`.
- Build: `bash game/ci/build_android.sh` → **CI: PASS** on this tree (toolchain reinstalled in-runtime: Godot 4.7.2-stable, Temurin JDK 17, Android SDK 36, export templates). APK verified: `com.downwitherfandesign.craftcube`, versionName `0.2.0`, versionCode `2`, minSdk 24, arm64-v8a, v1+v2 signed (Godot debug keystore). Staged: `dist/release/CraftCube-v0.2.0-android-arm64-v8a-debug.apk`. Log: `game/docs/evidence/session10_build.log`.
- Status: READY_FOR_REVIEW (release tooling). **No GitHub Release published yet** and **commit `78dcad1` unpushed** — both blocked by the read-only credential. Phase 00 gate remains **NOT PASSED**; PR #12 (AI-01 `PD-030`) must merge before PR #11. Human decisions OD-0001, OD-0005 still open.
- Known limitation: no physical Android device (no device playtest); the APK was built and statically verified in CI, not installed on a device.
- Checkpoint: `11_INTEGRATION/OPENHANDS_RESUME_STATE.md` (Session 11).

