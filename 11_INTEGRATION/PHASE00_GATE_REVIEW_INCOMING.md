# Phase 00 — Preliminary Gate Review of Incoming Account PRs

**Reviewer:** AI-13 · **Evidence:** `evidence/phase00_incoming_pr_scan.txt` (live GitHub API + `git diff` against `584141c`) · **Scope:** mechanical/governance checks only. Content coherence per `PHASE00_INTEGRATION_GATE.md` L1–L12 is reviewed per PR after this PR (#9) lands and each account rebases onto `integration`.

Verdict vocabulary: **QUEUE** (no governance defect; proceeds in merge order) · **RETURN** (owner action required before merge; CR filed) · **HOLD** (AI-13 action required).

## 1. Per-PR mechanical verdicts

| PR | Branch | Base | Ownership | PROGRESS.md | Verdict | Action |
|---|---|---|---|---|---|---|
| #1 | `ai-02-core` | `ai-13-integration` | clean (new files under `02_ARCHITECTURE/AI02_*`, own PROGRESS section) | 0 deletions, `### AI-02` | **RETURN** | CR-0008: retarget base to `integration` |
| #2 | `ai-05-world` | `integration` | clean (`09_ART_AUDIO/environment/`) | ok | **QUEUE** (step 6) | — |
| #3 | `ai-07-uiux` | `integration` | clean (`11_UIUX/`) | ok | **QUEUE** (step 6) | see §3 directory-prefix note |
| #4 | `ai-11-performance` | `integration` | clean (`12_PERFORMANCE/`) | ok | **QUEUE** (step 7) | CR-0009 namespace |
| #5 | `ai-09-narrative` | `ai-13-integration` | clean — `01_PREPRODUCTION/STORY_BIBLE_V7.md` modified; AI-09 owns Story Bible per `04_AI_ACCOUNTS/AI-09_Track.md` / `13_AI_EXECUTION_MANUAL.md` | ok | **RETURN** | CR-0008: retarget base to `integration` |
| #6 | `ai-04-gameplay` | `integration` | clean (`04_AI_ACCOUNTS/AI-04/phase_00/`) | ok | **QUEUE** (step 6) | — |
| #7 | `ai-10-qa` | `integration` | clean (`08_QA_RELEASE/phase_00/`) | ok | **QUEUE** (step 8) | CR-0009 namespace |
| #8 | `ai-12-build` | `integration` | clean (`12_RELEASE/`) | ok | **QUEUE** (step 7) | — |
| #9 | `ai-13-integration` | `integration` | clean (`11_INTEGRATION/`) | ok | step 1 | awaiting review |
| #10 | `ai-01-product` | `integration` | clean (`01_PREPRODUCTION/PRODUCT/`) | ok | **QUEUE** (step 2) | CR-0009 namespace |
| — | `ai-03-puzzle` (23 commits) | no PR | clean (`tracks/ai-03-puzzle-content/`) | ok | awaiting PR | §3 directory-prefix note |
| — | `ai-06-creatures` (9) | no PR | clean (`01_PREPRODUCTION/CHARACTERS_VFX/`) | ok | awaiting PR | CR-0009 namespace |
| — | `ai-08-audio` (8) | no PR | clean (`09_ART_AUDIO/AUDIO/`) | ok | awaiting PR | — |

Positive findings (VERIFIED): all 12 accounts confined edits to a new account directory plus an **additive** `### AI-XX` section in `00_CONTROL/PROGRESS.md` (0 deletions everywhere). No account edited `06_CONTRACTS/`, `05_PROMPTS/`, `07_GITHUB/`, `03_PHASES/` or another account's files. No `integration`/`main` pushes by anyone but AI-13's branch creation.

## 2. Cross-track findings

### F1 — `CC.*` namespace is being used for three different things (→ CR-0009)
The registry reserves `CC.<DOMAIN>.<NAME>` for **contracts**. Incoming branches also use it for **document IDs** (`CC.PRODUCT.LOCK`, `CC.PERF.LOCK`, `CC.CHARVFX.LOCK`, `CC.QA.PROTOCOL` …) and **ID-family labels** (`CC.QA.TRACE` for `QAT-###`). If unaddressed, `validate_registry.py` cannot distinguish a proposed contract from a document title, and two accounts could pick the same stem (already observed: `CC.PRODUCT.LOCK` appears on `ai-01-product`, `ai-06-creatures`, `ai-10-qa`). Ruling proposed for Product/owner confirmation: `CC.*` = contracts only; documents use `DOC.<ACCOUNT>.<NAME>`; ID families are registered by prefix (`QAT-`, `PERF-`, `PD-` …) in a separate ID-family table that AI-13 opens in Phase 01. No renames are demanded before Phase 01 — the finding is recorded so freezes do not inherit the ambiguity.

### F2 — Contract proposals awaiting registration (→ Phase 01 registry update, CR-0007 partially answered)
Owners have self-declared DRAFT contracts on their branches. AI-13 will add rows **after** the owning PR merges to `integration` (the validator requires source paths to exist on the reviewed tree):

| Proposed contract | Owner | Observed at | Registry action |
|---|---|---|---|
| `CC.AUDIO.CUE` 0.1.0-draft | AI-08 | `ai-08-audio` PROGRESS section | add DRAFT row (answers CR-0007 audio) |
| `CC.INTERACTION.COMMAND` 0.1.0-draft | AI-04 | `04_AI_ACCOUNTS/AI-04/phase_00/` | add DRAFT row; maps to "Command contract" in `06_CONTRACTS/INTERACTION_CONTRACTS.md` |
| `CC.CONTENT.LEVEL`, `CC.CONTENT.CHAPTER_SIGNATURE` | AI-03 | `tracks/ai-03-puzzle-content/` | add DRAFT rows (answers CR-0007 content schemas); relationship to `CC.NARRATIVE.CHAPTER` per CR-0006 |
| `AccessibilityPreference` v0.1.0-draft | AI-07 | `11_UIUX/contracts/` | already registered as `CC.ACCESSIBILITY.PREFERENCE`; link `fixture_path` |
| `PerformanceBudget` v0.1.0-draft; proposed `QualityTierState` | AI-11 | `12_PERFORMANCE/contracts/` | link fixture; `QualityTierState` new DRAFT row when drafted |
| `TelemetryEvent`, `RemoteContentManifest`, `BuildProvenance` v0.1.0-draft | AI-12 | `12_RELEASE/contracts/` | link fixtures; `BuildProvenance` new DRAFT row (answers CR-0007 build) |
| `CC.ASSET.MANIFEST` (or `CC.BUILD.*`) owner AI-12 | AI-01 decision PD-023 | `01_PREPRODUCTION/PRODUCT/PRODUCT_DECISION_REGISTER.md` | resolves OD-0004 once #10 merges |
| `cc.narrative.canon_registry` 0.1.0 fixture | AI-09 | `11_NARRATIVE/fixtures/` | fixture for `CC.NARRATIVE.CHAPTER` / `CC.NARRATIVE.MEMORY_FLAG`; note lowercase schema id — CR-0009 asks for consistent case |
| `ai02.domain_concept_register` 0.1.0-draft | AI-02 | `02_ARCHITECTURE/` | concept keys only; explicitly "not runtime IDs" — no registry row needed |

### F3 — Product decisions that close AI-13 open decisions (pending merge of #10)
Observed on `ai-01-product` (not yet on `integration`; verdicts become effective only after merge and, where required, Human approval):
- **PD-002** — item families = the 6 Equipment-Bible names; rarity = Utility/Named/Relic/Mastery; loadout ≤ 4 slots (exact count at Gold Slice). → closes **OD-0007**; sets `COMPLEXITY_BUDGET.md` item-family and rarity rows to OK.
- **PD-004** — ≤ 1 player-visible resource, only with Gold-Slice evidence; no premium currency at v1. → answers **OD-0006** as APPROVED_WITH_LIMITS (currency count ceiling 1, default 0).
- **PD-015** — Act I (3 chapters) is the minimum shippable core; slot count confirmed at the same gate.
- **PD-023** — asset-manifest owner AI-12. → answers **OD-0004**.
- **PD-013/PD-014** — public title and monetization are Human-gated; **OD-0005** remains open for Human.

### F4 — Directory layout divergence (informational, no CR yet)
Accounts placed Phase 00 work under six different root patterns (`01_PREPRODUCTION/<ROLE>/`, `04_AI_ACCOUNTS/AI-04/`, `09_ART_AUDIO/<role>/`, `tracks/ai-03-…/`, `11_UIUX/`, `11_NARRATIVE/`, `12_PERFORMANCE/`, `12_RELEASE/`). Two accounts chose the `11_` prefix alongside `11_INTEGRATION/`, and two chose `12_`. This is not an ownership violation — paths are disjoint — but CODEOWNERS/CI ownership (CR-0002) will need the real map. AI-13 will publish the observed owner→path map in Phase 01 rather than force moves now.

## 3. Requests filed from this review
- **CR-0008** (AI-02, AI-09): retarget PRs #1 and #5 to base `integration`.
- **CR-0009** (AI-01, AI-06, AI-09, AI-10, AI-11 — and any account using `CC.*` for non-contracts): confirm `CC.*` = contract-only namespace; move document IDs to a non-`CC` prefix at next edit; AI-13 opens ID-family table in Phase 01.

## 4. What this review does not claim
No content-quality judgement has been made on any account's artifacts. No PR has been merged. No account's files were edited by AI-13.

## 5. Content gate review (recovery session, 2026-10-10)

Performed locally by merging each PR head onto `origin/integration` @ `584141c` and running the owner's declared validator. Environment had no write access to GitHub, so verdicts are recorded here and in `OPENHANDS_RESUME_STATE.md`; they are recommendations for the merge step, not merges.

| PR | Branch | Owner validator result on PR head | Ownership | Content verdict |
|---|---|---|---|---|
| #9 | ai-13-integration | `validate_registry.py --check-render` → PASS (exit 0) | clean (`11_INTEGRATION/**` + additive PROGRESS) | **QUEUE (step 1)** |
| #10 | ai-01-product | `validate_product_lock.py` → pass=14 fail=0 (exit 0) | clean (`01_PREPRODUCTION/PRODUCT/**` + additive PROGRESS) | **QUEUE (step 2)** |
| #5 | ai-09-narrative | `validate_narrative_registry.py` → **FAIL, exit 1, 2 failures** | clean (`11_NARRATIVE/**`, `STORY_BIBLE_V7.md` + additive PROGRESS) | **RETURN — CR-0011** |
| #1 | ai-02-core | not re-run this session (validator present: `AI02_DOMAIN_CONCEPT_REGISTER_VALIDATOR.py`) | clean | pending (also carries CR-0008 base fix) |

Cross-PR merge mechanics:
- Merging #9 then #10 onto `integration` conflicts only in `00_CONTROL/PROGRESS.md` (both append an `### AI-XX` section). Resolved by keeping both sections; both validators PASS afterwards → **CR-0010**.
- `ai-09-narrative` and `ai-02-core` carry **no dependency** on the `ai-13-integration` branch (`git diff --name-only origin/ai-13-integration...origin/ai-09-narrative | grep 11_INTEGRATION` = 0), so CR-0008 base retarget to `integration` is safe and does not hide missing dependencies.

Content coherence spot-checks (Phase 00 gate L-rows):
- **L1/L2 (PR #10):** `PRODUCT_LOCK_V1.md` + `CUT_LIST_AND_COMPLEXITY_BUDGET.md` present; product truth and scope/cut list are coherent with the master bible. PD-025..029 recorded as Human Product Authority decisions.
- **L4/L8 (PR #5):** terminology and story-canon registers present and machine-readable; the *only* blocking defect is the stale `silent_engine` chapter label/validator gap in CR-0011.

## 6. Integrated-tree gate re-run (2026-10-10, write-enabled session)

With write access restored, all 13 branches were merged into `integration` (steps 1-8 of `INTEGRATION_ORDER_AND_MERGE_SEQUENCE.md`), pushed as `integration@c4cc93e`. Every owner validator was then run **against the integrated tree**, not against separate PR heads. Results:

| Owner validator | exit | note |
|---|---|---|
| `validate_registry.py --check-render` (AI-13) | 0 | 27 contracts, 27 DRAFT |
| `validate_product_lock.py` (AI-01) | 0 | pass=14 fail=0 |
| `AI02_DOMAIN_CONCEPT_REGISTER_VALIDATOR.py` (AI-02) | 0 | |
| `validate_phase00_content.py` (AI-03) | 0 | 1 warning |
| `validate_ai04_phase00.py` (AI-04) | 0 | |
| `validate_environment_fixtures.py` (AI-05) | 0 | |
| `validate_a11y_fixtures.py` (AI-07) | 0 | |
| `validate_audio_cue_registry.py` (AI-08) | 0 | registry OK |
| `validate_narrative_registry.py` (AI-09) | 0 | fixed via CR-0011 |
| **`QA_PHASE00_VALIDATOR.py` (AI-10)** | **1** | **fail=20 - CR-0012 (new)** |
| `validate_performance_budget.py` (AI-11) | 0 | |
| `validate_release_fixtures.py` (AI-12) | 0 | |
| `validate_ownership.py` (07_GITHUB) | 0 | |

**CR-0012** is a genuine integration-time defect: AI-10's validator passes only in isolation and fails once other accounts' artifacts are present (C2 false positives on other accounts' declared forbidden-term lists/prose; E3 stale Product version baselines). It is the one remaining validator blocker. Phase 00 verdict therefore stays **NOT PASSED**.
