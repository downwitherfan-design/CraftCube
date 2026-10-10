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
