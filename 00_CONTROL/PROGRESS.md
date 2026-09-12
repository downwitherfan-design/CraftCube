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

### AI-11
- Branch: `ai-11-performance`
- Task: Phase 00 — performance/Android contribution to Product/IP Lock: platform assumptions with evidence class, measurable boundaries `PERF-001..035` (all HYPOTHESIS), Android device tier definitions (no fabricated devices), measurement method standard, `PerformanceBudget` DRAFT 0.1.0 + fixture + validator. Workspace: `12_PERFORMANCE/`.
- Status: READY_FOR_REVIEW
- Contract versions consumed: none FROZEN/RELEASED exists. Read-only references: `PerformanceBudget` registry row (owner AI-11) in `06_CONTRACTS/V7_MASTER_CONTRACT_REGISTER.md`; AI-07 `AccessibilityPreference` 0.1.0-draft (branch `ai-07-uiux`, AI-11 as reader of `reduce_motion`); AI-01 `IGM-006b/006e` and Product Lock §5/§10 (branch `ai-01-product`).
- Contract versions changed: `PerformanceBudget` created as DRAFT 0.1.0 (`12_PERFORMANCE/contracts/`). Not consumable until Phase 01 freeze.
- Tests: `python3 12_PERFORMANCE/tools/validate_performance_budget.py` → exit 0; positive fixture PASS (35 entries, 23 gate, 0 measured); 4 negative fixtures under `_expect_invalid/` each correctly rejected (MEASURED without evidence, missing tier value, duplicate ID, `build_id: UNKNOWN`).
- Known issues: zero devices measured (by design — no engine project/build exists); `integration` branch missing on remote (C11-02); `DEVICE_MATRIX_TEMPLATE.csv` owner column stale (C11-01); min API level / Unity & URP versions UNKNOWN (U11-01); audio budgets deferred to Phase 01 (IR-AI11-010). Full list: `12_PERFORMANCE/phase_00/INTEGRATION_REQUESTS_AND_UNKNOWNS.md`.
- Next integration action: AI-13 to create `integration` and register AI-11 ID families (IR-AI11-005); AI-12 to confirm `build_id` exposure (IR-AI11-002); then AI-11 proceeds to Phase 01 freeze of `PerformanceBudget` 1.0.0 and drafting of `QualityTierState`.
