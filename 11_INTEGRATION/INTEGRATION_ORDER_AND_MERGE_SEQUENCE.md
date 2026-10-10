# Integration Order and Merge Sequence (AI-13 owned)

Source policies: `07_GITHUB/GITHUB_MODEL.md`, `01_GOVERNANCE/INTEGRATION_PLAYBOOK.md`, `05_PROMPTS/PHASE_KICKOFF_PROCEDURE.md` ("ترتیب Merge"), `00_CONTROL/13_AI_EXECUTION_MANUAL.md` ("Integration sequence"). This document records the **actual** branch model and the operational sequence; it does not change policy.

## 1. Actual branch model (VERIFIED at `584141c` + AI-13 Phase 00)

```text
main                      release-approved merges only; at 584141c
└── integration           created by AI-13 from 584141c (Phase 00); PR target for every account
    ├── ai-01-product
    ├── ai-02-core
    ├── ai-03-puzzle
    ├── ai-04-gameplay
    ├── ai-05-world
    ├── ai-06-creatures
    ├── ai-07-uiux
    ├── ai-08-audio
    ├── ai-09-narrative
    ├── ai-10-qa
    ├── ai-11-performance
    ├── ai-12-build
    └── ai-13-integration
```

Canonical account → branch mapping (actual names win over `07_GITHUB/GITHUB_MODEL.md`; see CR-0001):

| Account | Branch | `GITHUB_MODEL.md` name (stale) |
|---|---|---|
| AI-01 | `ai-01-product` | `ai-01/product` |
| AI-02 | `ai-02-core` | `ai-02/core` |
| AI-03 | `ai-03-puzzle` | `ai-03/puzzle-content` |
| AI-04 | `ai-04-gameplay` | `ai-04/gameplay-mobile` |
| AI-05 | `ai-05-world` | `ai-05/environment-art` |
| AI-06 | `ai-06-creatures` | `ai-06/characters-vfx` |
| AI-07 | `ai-07-uiux` | `ai-07/uiux` |
| AI-08 | `ai-08-audio` | `ai-08/audio` |
| AI-09 | `ai-09-narrative` | `ai-09/narrative-localization` |
| AI-10 | `ai-10-qa` | `ai-10/qa` |
| AI-11 | `ai-11-performance` | `ai-11/performance-android` |
| AI-12 | `ai-12-build` | `ai-12/release` |
| AI-13 | `ai-13-integration` | `ai-13/integration` |

Rules: one account edits only its own branch; nobody pushes to `integration` or `main` directly; AI-13 merges PRs into `integration` after gate review; promotion `integration → main` requires Human release approval.

## 2. Phase 00 merge order

Phase 00 is document-only, so conflicts are semantic, not textual. Order still matters because later artifacts reference earlier ones.

| Step | Branch | Why this position | Gate items |
|---|---|---|---|
| 1 | `ai-13-integration` | Registry, IDs, gate and merge rules must exist before others reference `CC.*` / `CR-` / `OD-` IDs | L13 |
| 2 | `ai-01-product` | Product truth, scope, cut list, IP decision — everything else claims coherence with it | L1, L2, L3(audience), L5, L6, L7, L9 |
| 3 | `ai-09-narrative` | Terminology keys and story canon; downstream notes must quote canon terms | L4, L8 |
| 4 | `ai-02-core` | Domain boundaries and state semantics that puzzle/UX/world notes depend on | L11 |
| 5 | `ai-03-puzzle` | Puzzle grammar; depends on product + core boundaries | L10 |
| 6 | `ai-04-gameplay`, `ai-05-world`, `ai-06-creatures`, `ai-07-uiux`, `ai-08-audio` | Feasibility notes; order among them is free (no cross-dependency at Phase 00) | L12 |
| 7 | `ai-11-performance`, `ai-12-build` | Device tiers and platform/build constraints; consume the above | L3 (tiers/platform), L12 |
| 8 | `ai-10-qa` | Measurability review of success metrics and acceptance criteria — needs everything above to review | L6 (measurability), L12 |
| 9 | AI-13 gate re-run | `validate_registry.py`, watch-list, ownership audit → verdict | Gate verdict |

An account whose PR is ready before its step may still open the PR; AI-13 queues it. Nothing here blocks development on the account's own branch.

## 3. Standing merge order for implementation phases (01+)

From `05_PROMPTS/PHASE_KICKOFF_PROCEDURE.md`, made explicit against the 13 accounts:

1. Contract/schema changes (owner account PR + AI-13 registry update) — status change DRAFT→FROZEN recorded in `registry/contract_registry.json` in the **same** PR that lands the contract.
2. Core/domain (AI-02), then puzzle/content schemas (AI-03), narrative data (AI-09).
3. Runtime adapters (AI-04).
4. UI/UX (AI-07).
5. Art/VFX (AI-05, AI-06).
6. Audio (AI-08).
7. QA validation (AI-10) — may merge earlier when it only adds tests against FROZEN contracts.
8. Performance (AI-11) — measurements and budgets.
9. Build/release (AI-12) — last, so CI sees the full tree.
10. AI-13 governance artifacts — may merge at any point; they never touch other owners' paths.

## 4. Gate procedure per PR (manual until CI exists — RISK-0002)

```bash
# 1. fetch and inspect
git fetch origin
git log --oneline origin/integration..origin/<branch>
git diff --stat origin/integration...origin/<branch>

# 2. ownership audit: every changed path must be inside the account's declared ownership
git diff --name-only origin/integration...origin/<branch>

# 3. governance validation on the would-be merged tree
git checkout -B gate-check origin/integration
git merge --no-ff --no-commit origin/<branch>
python3 11_INTEGRATION/scripts/validate_registry.py --check-render
# (Phase 01+: also run the owner's declared test command from the handoff)
git merge --abort

# 4. approve → merge via PR (no fast-forward so the merge commit is the rollback unit)
# 5. reject → file CR-nnnn in 11_INTEGRATION/CHANGE_REQUESTS.md with evidence
```

Rejection returns to the owner; AI-13 never patches the producer branch (`05_PROMPTS/INTEGRATION_GATE_PROMPT_AI13.md`).

## 5. Rollback

- **Single PR:** `git revert -m 1 <merge-commit>` on `integration`, push, re-open CR to owner.
- **Whole phase on `integration`:** `git reset --hard <last-good-tag>` is **forbidden** on shared branches; use a sequence of reverts and tag the last-known-good state `integration/phase-XX-good` before starting the next phase.
- **`main`:** untouched until Human promotion; rollback = do not promote.
- **Registry:** any status change is a JSON diff in the same PR; reverting the PR reverts the status.

## 6. Tags (to be created by AI-13 at each gate PASS)

`phase-00-gate-pass` on `integration` when `PHASE00_INTEGRATION_GATE.md` verdict becomes PASSED. No tag exists yet (VERIFIED: `git tag` empty at baseline).
