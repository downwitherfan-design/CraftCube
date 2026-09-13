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

### AI-10
- Branch: `ai-10-qa`
- Task: Phase 00 — make the product lock verifiable: traceability register for PD/F10/IGM/CUT criteria, IP/terminology rule set, first-10-minutes playtest protocol + pseudonymous session schema, deterministic validator, evidence-based findings.
- Status: READY_FOR_REVIEW
- Contract versions consumed: none frozen (all `TBD 1.0.0`). Contract family names referenced read-only from `06_CONTRACTS/`. Product inputs: `CC.PRODUCT.LOCK` / `DECISIONS` / `FIRST10` / `IGM` / `CUTLIST` 1.0.0 on `ai-01-product@2db84b5` (READY_FOR_REVIEW, unmerged).
- Contract versions changed: none
- Tests: `python3 08_QA_RELEASE/phase_00/QA_PHASE00_VALIDATOR.py` → exit 0, fail=0 (6 check groups A–F, 14 negative self-test cases). Evidence: `08_QA_RELEASE/phase_00/evidence/validator_run_ai-10-qa_only.log` (5 SOURCE_NOT_PRESENT skips) and `validator_run_with_ai-01-product_overlay.log` (all 8 sources cross-checked, 0 skips). No build/device/playtest executed — none exists.
- Known issues: 12 findings in `08_QA_RELEASE/phase_00/QA_PHASE00_FINDINGS_REGISTER.md` (7 MAJOR, all Phase 01 contract inputs; 0 BLOCKER). 25/36 QAT items blocked on contracts/sources by design. Protocol exit-question wording is `1.0.0-draft` pending AI-01 (QAF-007).
- Next integration action: PR `ai-10-qa` → `integration` after AI-01's PRODUCT docs merge (register cross-check E depends on them); AI-13 to register `QAT/QAR/QAF/PT` ID families (QAF-001).
