# AI-01 — Phase 00 Handoff (Product / IP Lock)

Format: `05_PROMPTS/HANDOFF_TEMPLATE.md`. Labels per `05_PROMPTS/ANTI_HALLUCINATION_ADDENDUM.md`: VERIFIED / INFERRED / ASSUMED / UNKNOWN.

STATUS: READY_FOR_REVIEW — all Phase 00 product deliverables exist, validate, and are downstream-consumable. Not COMPLETE/LOCKED: four Human gates remain open (listed under KNOWN_LIMITATIONS); Product cannot close them.

TASK_ID: phase_00/ai_01 (`05_PROMPTS/phase_00/ai_01.md`)
PHASE: 00 — Product/IP Lock
ACCOUNT: AI-01 — Product / Game Direction

TASKS_COMPLETED:
- Product Lock v1.0.0: value proposition, 30-second loop, ranked pillars P1–P5, audience, platform assumptions (labelled ASSUMED/HYPOTHESIS/MISSING), IP policy + approved vocabulary, scope Must/Should/Later/Reject, non-goals, measurable boundaries, deferred Human decisions.
- Product Decision Register v1.1.0: PD-001..PD-024 with testable acceptance criteria. Required Phase 00 decisions: narrative premise (PD-001 APPROVED), equipment role (PD-002 APPROVED_WITH_LIMITS), max progression/menu complexity (PD-003 caps), Story Promise (PD-017 APPROVED), plus resolution of every open decision routed to AI-01 by AI-09 (OD-03/04/05 → PD-017/018/019) and AI-13 (OD-0003/0004/0006/0007 → PD-022/023/021/020) and AI-09 OD-02/OD-08 → PD-024.
- First 10 Minutes proof F10-001..F10-007 with playtest protocol.
- Investment Gate Metrics v1.0.1: IGM-001..IGM-008 (fun, clarity, uniqueness, equipment value, story curiosity, mobile feasibility, causality, retention intent) with method, threshold, sample size, owner, HARD_STOP rules.
- Hard Cut List CUT-001..CUT-031, complexity budget caps, cut order, "never cut" floor.
- Progression / Anti-Grind / Expression Policy v1.0.0: Story Promise approval + boundaries, session emotional arc, equipment philosophy clarifications, AGP-001..AGP-025, narrative/gameplay balance rules, CMP-001..CMP-012 (complexity-too-high criteria).
- Competitor Review v1.0.0 (5 adjacent titles, store-verified facts, differentiation matrix, IGM-003 coding lists) — closes the MISSING Gate A item.
- `validate_product_lock.py` product-doc validator + evidence log.
- AI-01 section in `00_CONTROL/PROGRESS.md`.

FILES_ADDED (all on `ai-01-product`, VERIFIED via `git diff --name-status origin/main...HEAD`):
- `01_PREPRODUCTION/PRODUCT/PRODUCT_LOCK_V1.md`
- `01_PREPRODUCTION/PRODUCT/PRODUCT_DECISION_REGISTER.md`
- `01_PREPRODUCTION/PRODUCT/FIRST_10_MINUTES_PROOF.md`
- `01_PREPRODUCTION/PRODUCT/INVESTMENT_GATE_METRICS.md`
- `01_PREPRODUCTION/PRODUCT/CUT_LIST_AND_COMPLEXITY_BUDGET.md`
- `01_PREPRODUCTION/PRODUCT/PROGRESSION_ANTI_GRIND_AND_EXPRESSION_POLICY.md`
- `01_PREPRODUCTION/PRODUCT/COMPETITOR_REVIEW.md`
- `01_PREPRODUCTION/PRODUCT/validate_product_lock.py`
- `01_PREPRODUCTION/PRODUCT/evidence/validate_product_lock_run.log`
- `01_PREPRODUCTION/PRODUCT/AI-01_PHASE00_HANDOFF.md` (this file)

FILES_MODIFIED:
- `00_CONTROL/PROGRESS.md` — AI-01 section only (append; the shared header and other sections untouched).

FILES_DELETED: none.

CONTRACTS_CONSUMED: none released. All `CC.*` entries in `11_INTEGRATION/registry/contract_registry.json` (branch `ai-13-integration`) are DRAFT. Product documents reference contract IDs by name so acceptance criteria can attach when they freeze: `CC.WORLD.STATE_EVENT`, `CC.ITEM.DEFINITION`, `CC.EQUIPMENT.EFFECT`, `CC.REWARD.DEFINITION`, `CC.RESOURCE.LEDGER`, `CC.COMPANION.REACTION`, `CC.NARRATIVE.MEMORY_FLAG`, `CC.SAVE.SCHEMA`, `CC.PUZZLE.AFFINITY`.

CONTRACTS_CHANGED: none. AI-01 owns no runtime contract. Product *rulings* that affect contract freezes (for the owners to apply): PD-020 (family/rarity enums), PD-021 (ledger defined-but-empty in Gold Slice), PD-022 (STATE_EVENT owner AI-02), PD-023 (asset manifest owner AI-12).

NEW_IDS (all AI-01-owned, immutable; VERIFIED absent from every remote branch before creation via `git grep` across `origin/*`):
- `PD-001..PD-024` (Product Decision) — PD-017..024 new this pass.
- `F10-001..F10-007` (First-10 proof point).
- `IGM-001..IGM-008` incl. suffixed sub-metrics (`IGM-001b`, `IGM-002b`, `IGM-003b`, `IGM-004b`, `IGM-005b`, `IGM-005c`, `IGM-006b..e`).
- `CUT-001..CUT-031` (Cut list).
- `AGP-001..007, 010..017, 020..025` (Anti-Grind / Progression rules; blocks are intentional per policy §4–§6).
- `CMP-001..CMP-012` (Complexity-too-high criteria).
- Document IDs: `CC.PRODUCT.LOCK`, `CC.PRODUCT.DECISIONS`, `CC.PRODUCT.FIRST10`, `CC.PRODUCT.IGM`, `CC.PRODUCT.CUTLIST`, `CC.PRODUCT.PROGRESSION_POLICY`, `CC.PRODUCT.COMPETITORS` (document identifiers, not runtime contracts; AI-13 may register them as governance artifacts or leave them unregistered — Product has no preference).

TESTS_AND_COMMANDS (VERIFIED, run in this session):
```
cd <repo> && python3 01_PREPRODUCTION/PRODUCT/validate_product_lock.py
# → SUMMARY pass=12 fail=0, exit 0
```
Negative self-tests on a temporary copy of the tree (not committed): (1) duplicate `PD-023` heading → FAIL; (2) removed `COMPETITOR_REVIEW.md` + dangling `CUT-099` → FAIL; (3) stripped acceptance tags from an APPROVED PD → FAIL. All exit 1.
Cross-track check: AI-10's `QA_PHASE00_VALIDATOR.py` was run by AI-10 against `ai-01-product@2db84b5` (five original docs) with fail=0 (`08_QA_RELEASE/phase_00/evidence/validator_run_with_ai-01-product_overlay.log` on `ai-10-qa`). It has **not** been re-run against the two new documents — AI-10 should re-run at gate.

EVIDENCE:
- `01_PREPRODUCTION/PRODUCT/evidence/validate_product_lock_run.log`
- Commit series on `ai-01-product` (one change per commit, all pushed): `fc29b64 … 965cfe0`.
- Competitor facts: each fact in `COMPETITOR_REVIEW.md` is labelled VERIFIED (store listing) or INFERRED; no sales/retention figures claimed.
- No build, no device run, no playtest was performed. Every threshold in IGM is a pre-measurement target, explicitly stated as such.

PERFORMANCE_NOTES: no runtime impact (documents + one offline Python script that reads Markdown). Product performance *ceilings* (≤ 100 ms frame hitch low-tier, ≤ 2 s causality latency, ≤ 150 MB install, ≤ 5 s cold start) are HYPOTHESES for AI-11/AI-12 to replace with measured budgets; they are not evidence.

SECURITY_OR_PRIVACY_NOTES: none introduced. Product requires (PD-010) that analytics/online layers fail closed and are never required offline; retention telemetry at Phase 15 must be opt-in and privacy-minimal (IGM-008). No credentials or tokens appear in any committed file (VERIFIED by `git grep -n "ghp_\|token" -- 01_PREPRODUCTION/PRODUCT` → 0 hits).

KNOWN_LIMITATIONS:
- Human gates still OPEN (Product cannot close): PD-013 final title (+ trademark check, OD-0005); PD-014 monetization; PD-017 canon text approval (Story Promise approved at product level only); COMPETITOR_REVIEW §2 differentiation-claim confirmation; OD-0002 engine lock (Product recommends confirming Unity 6 + URP as stated in `TECHNICAL_BLUEPRINT.md`, but this is a Human + toolchain-availability decision — the AI sandboxes are Flutter, not Unity, so no account can currently build).
- Terminology conflicts reported, not resolved (owner AI-09): "Quiet Engine" vs "Silent Engine"; Verdant Archive chapter mapping (CUT-030 stays LATER until mapped).
- Older item docs (`ITEM_EQUIPMENT_PROGRESSION.md`, `ITEM_DESIGN_BIBLE.md`, `NARRATIVE_ITEM_INTEGRATION.md`) still show non-canonical family/rarity names; Product ruled (PD-020) but does not edit files it does not own — owners should annotate "superseded by PD-020".
- `validate_product_lock.py` checks structure and ID integrity, not semantic quality. It does not validate other accounts' files.
- The AI-01 track file (`04_AI_ACCOUNTS/AI-01_Track.md`) and the phase prompt were not modified; both are governance-owned.

RISKS:
- Identity misread (IGM-003 HARD_STOP): players calling it "a Rubik's cube app" or "Minecraft-like". Mitigations locked in vocabulary policy, F10 pacing, and the visual-language requirement to AI-05/06/07 in `COMPETITOR_REVIEW.md` §3.
- Title collision risk: two adjacent products already own "Cube" associations (cube solvers; Cube Escape). PD-013 recommends title check before any brand spend.
- Complexity creep between phases: mitigated by CUT list, CMP criteria and AI-13's complexity budget; requires AI-13 to actually re-count at each gate.
- Engine/toolchain (RISK-0001 on AI-13): if Unity is unavailable to accounts, the Gold Slice timing behind IGM measurements slips; Product thresholds do not change.

INTEGRATION_STEPS:
1. AI-13: merge `ai-01-product` → `integration` as **step 2** of `11_INTEGRATION/INTEGRATION_ORDER_AND_MERGE_SEQUENCE.md` (after `ai-13-integration`). Gate check: `python3 01_PREPRODUCTION/PRODUCT/validate_product_lock.py` on the merged tree must exit 0; ownership audit — every changed path is under `01_PREPRODUCTION/PRODUCT/` plus the AI-01 section of `00_CONTROL/PROGRESS.md`.
2. AI-13: register ID families PD/F10/IGM/CUT/AGP/CMP as AI-01-owned; mark OD-0003 → PD-022, OD-0004 → PD-023, OD-0006 → PD-021, OD-0007 → PD-020 as decided (Product) — Human co-sign needed only for OD-0006 if a resource is later *added*.
3. AI-09: mark OD-03 → PD-017, OD-04 → PD-018, OD-05 → PD-019, OD-02/OD-08 → PD-024 as decided; carry the §1 promise boundaries and CMP-005/007/008/012 into the Story Bible freeze.
4. AI-02: adopt PD-020 enums (namespaced family vs rarity), PD-021 (ledger defined, empty in slice), PD-022 (acknowledge STATE_EVENT ownership); AGP-001/002/005/012/016 as invariants.
5. AI-03: AGP-004/006/010/015, CMP-006 item-card gate; seed set is 11 candidates after PD-019.
6. AI-07: PD-003 caps, AGP-001/023, CMP-004/011; non-hotbar inventory (COMPETITOR_REVIEW §3.3).
7. AI-05/AI-06: non-voxel world grammar; Nox owns "sensing direction to secrets" (PD-019); AGP-013 bond triggers.
8. AI-10: add AGP/CMP/PD-017..024 to the traceability register; re-run `QA_PHASE00_VALIDATOR.py` over the two new documents.
9. AI-12: PD-023 asset-manifest ownership → register `CC.ASSET.MANIFEST` (or `CC.BUILD.*`) row.
10. Human Product Authority: decide PD-013, PD-014, confirm PD-017 canon text, confirm COMPETITOR_REVIEW §2, decide OD-0002/OD-0005.

ROLLBACK_STEPS:
- Whole contribution: `git revert -m 1 <merge-commit>` on `integration` (Phase 00 is document-only; nothing downstream is code-bound yet).
- Single decision: append a superseding `PD-025+` entry (`Supersedes: PD-0xx`); never rewrite or renumber. Validator enforces uniqueness/contiguity.
- Validator: deleting `validate_product_lock.py` has no runtime effect; evidence log becomes stale and should be removed with it.

NEXT_SAFE_ACTION: PR opened — https://github.com/downwitherfan-design/CraftCube/pull/10 (`ai-01-product` → `integration`). Then wait for AI-13 gate review and Human decisions; Phase 01 for AI-01 begins by converting `PRODUCT_LOCK_V1.md` §10 boundaries into acceptance tests attached to the first FROZEN contracts.

OWNERSHIP_AUDIT (VERIFIED):
```
git diff --name-only origin/main...HEAD
  00_CONTROL/PROGRESS.md                       (AI-01 section only — permitted by PROGRESS.md "update only its own section")
  01_PREPRODUCTION/PRODUCT/*                   (AI-01 owned: GDD/product/scope/acceptance)
```
No runtime code, assets, UI, audio, CI or non-product tests were touched. No file owned by another account was edited; all cross-track needs are expressed as PD rulings and integration requests above.
