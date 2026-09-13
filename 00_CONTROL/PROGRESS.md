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

### AI-01
- Branch: `ai-01-product`
- Task: Phase 00 — Product/IP Lock (product truth, decisions, first-10-minutes proof, Investment Gate metrics, cut list, progression/anti-grind/expression policy, competitor review)
- Status: READY_FOR_REVIEW (becomes LOCKED only after Human Product Authority approval of PD-013/PD-014/PD-017 and the COMPETITOR_REVIEW differentiation claim)
- Contract versions consumed: none released (all `CC.*` registry entries are DRAFT per `11_INTEGRATION/registry/contract_registry.json` on `ai-13-integration`). Product docs reference contract IDs by name only.
- Contract versions changed: none. New AI-01 document versions: `CC.PRODUCT.LOCK` 1.0.0, `CC.PRODUCT.DECISIONS` 1.1.0, `CC.PRODUCT.FIRST10` 1.0.0, `CC.PRODUCT.IGM` 1.0.1, `CC.PRODUCT.CUTLIST` 1.0.0, `CC.PRODUCT.PROGRESSION_POLICY` 1.0.0, `CC.PRODUCT.COMPETITORS` 1.0.0
- Tests: `python3 01_PREPRODUCTION/PRODUCT/validate_product_lock.py` → pass=12 fail=0 exit 0 (log: `01_PREPRODUCTION/PRODUCT/evidence/validate_product_lock_run.log`); 3 negative self-tests exit 1
- Known issues: Human gates open (PD-013 title, PD-014 monetization, PD-017 canon text, OD-0005 IP/trademark, OD-0002 engine lock); terminology conflicts "Quiet Engine"/"Silent Engine" and Verdant Archive mapping remain with AI-09 (`PRODUCT_LOCK_V1.md` §6.4); older item docs need "superseded by PD-020" annotation by their owners
- Next integration action: PR `ai-01-product` → `integration` (merge step 2 per `INTEGRATION_ORDER_AND_MERGE_SEQUENCE.md`); AI-13 to register ID families PD/F10/IGM/CUT/AGP/CMP and close OD-0003/0004/0006/0007 with PD-022/023/021/020; AI-09 to close OD-03/04/05 with PD-017/018/019
