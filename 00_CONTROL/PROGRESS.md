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
- Task: Phase 00 — Product/IP Lock (product truth, decisions, first-10-minutes proof, Investment Gate metrics, cut list, progression/anti-grind/expression policy, competitor review) + recording of Human Product Authority closure decisions
- Status: READY_FOR_REVIEW — Human decisions RECORDED as PD-025 (engine: Unity 6 + URP + Android), PD-026 (title "CraftCube" working; no trademark claim; Asterra internal-only; `CC.` namespace title-independent), PD-027 (premium one-time purchase), PD-028 (Story Bible v0.1.0 canon baseline; Quiet Engine canonical; Verdant Archive LATER; Hold/Weave/Open working names), PD-029 (remaining human items). Integration gate verdict remains AI-13's.
- Contract versions consumed: none released (all `CC.*` registry entries are DRAFT per `11_INTEGRATION/registry/contract_registry.json` on `ai-13-integration`). Product docs reference contract IDs by name only.
- Contract versions changed: none. AI-01 document versions: `CC.PRODUCT.LOCK` 1.1.0, `CC.PRODUCT.DECISIONS` 1.2.0, `CC.PRODUCT.FIRST10` 1.0.0, `CC.PRODUCT.IGM` 1.0.2, `CC.PRODUCT.CUTLIST` 1.1.0, `CC.PRODUCT.PROGRESSION_POLICY` 1.0.1, `CC.PRODUCT.COMPETITORS` 1.0.0
- Tests: `python3 01_PREPRODUCTION/PRODUCT/validate_product_lock.py` → pass=14 fail=0 exit 0 (log: `01_PREPRODUCTION/PRODUCT/evidence/validate_product_lock_run_phase00_closure.log`); 9 negative self-tests exit 1; PD-025..029 collision-free across all branches
- Known issues: remaining human items per PD-029 — final title trademark/legal clearance (before brand lock/Phase 14), Asterra legal clearance, retail price, Unity licence custody + CI build environment (Human Project Owner, before Phase 02), branch protection (OD-0001), signing custody (Phase 14). Toolchain versions deliberately unpinned (PD-025). Downstream applications pending: AI-09 S1 rename + Ch.08 LATER marking, AI-13 OD-0002/0005 closure + complexity budget (biomes 5, chapters ≤ 9), owners' "superseded by PD-020" annotations.
- Next integration action: PR #10 `ai-01-product` → `integration` (merge step 2). AI-13: close OD-0002 (PD-025), OD-0005 product part (PD-026), OD-0006 (PD-021), OD-0007 (PD-020), OD-0003 (PD-022), OD-0004 (PD-023); register PD/F10/IGM/CUT/AGP/CMP families; re-rate RISK-0001/RISK-0008. AI-09: close OD-01/02/03/04/05/08 via PD-026/024/017+028/018+028/019/024; apply Quiet Engine rename; mark Verdant Archive/Ch.08 LATER.