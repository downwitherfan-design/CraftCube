# CraftCube v5 — Professional Prompt Usage Guide

This package is designed for 13 independent AI accounts working in parallel on one GitHub repository.
The prompts are execution instructions, not a substitute for repository inspection.

## 1. One account = one role = one branch/workspace
Use the account mapping in `04_AI_ACCOUNTS/ACCOUNT_MATRIX.md`.
Each account works only in its own branch/workspace and targets PRs to `integration`.

## 2. Files each AI receives
At the start of every task, provide:
1. `05_PROMPTS/00_MASTER_CONTROL_PROMPT.md`
2. the matching `04_AI_ACCOUNTS/AI-XX_Track.md`
3. the exact phase/account prompt under `05_PROMPTS/phase_XX/`
4. current `00_CONTROL/PROGRESS.md`
5. current contract/version manifests relevant to the task
6. the actual GitHub-connected repository/workspace
Do not mix prompts from multiple accounts.

## 3. Prompt order
Run: PRECHECK → PLAN → INSPECT → IMPLEMENT/CREATE → SELF-AUDIT → TEST → EVIDENCE → HANDOFF → COMMIT → PR.
The AI should spend as much work as necessary to satisfy the quality gates. There is no reward for premature completion.

## 4. Context priority
When the AI sees a conflict, it must follow the source-of-truth hierarchy in the Master Control Prompt and raise a conflict instead of guessing.

## 5. Parallel work
All accounts can operate simultaneously. A dependency that is not yet implemented should be represented by a mock/stub/fixture/adapter inside the owning track when possible.
The temporary artifact must be clearly marked and must not leak into the production path.

## 6. Integration sequence
PRs go to `integration`, never directly to `main`.
AI-13 performs the integration review and can reject/return work with an actionable change request. Another account must not silently rewrite the producer's implementation.

## 7. What to do when an AI gets stuck
Use the recovery protocol. Do not restart from scratch. Preserve the branch, capture evidence, classify the blocker, and continue with safe work that does not depend on the blocker.

## 8. What to do when a contract changes
Pause incompatible consumers, publish a new contract version, add compatibility/migration guidance, update affected prompts if necessary, then resume parallel work against the new version.

## 9. Human review points
Human review is required for: product scope decisions, IP/legal decisions, breaking contracts, monetization choices, store declarations, signing credentials, and final release approval.

## 10. Minimum handoff quality
A handoff is accepted only when another engineer/AI can reproduce what was done from the evidence and follow the integration/rollback steps without guessing.

## 11. Recommended working rhythm
Do not force equal effort across every phase. Heavy implementation phases can use many accounts; governance/release phases may keep some accounts in audit mode. The objective is parallel throughput without sacrificing integration safety.
