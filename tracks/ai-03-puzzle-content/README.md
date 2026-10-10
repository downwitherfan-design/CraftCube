# AI-03 — Puzzle Design / Level & Content Logic — Track Workspace

**Owner:** AI-03 (Puzzle / Content). No other account edits files under `tracks/ai-03-puzzle-content/`.
**Branch:** `ai-03-puzzle`
**Status:** Phase 00 — Product/IP Lock (puzzle vocabulary, mechanic families, level grammar, content principles)

## Why this directory exists

The v7 planning pack defines *what* AI-03 owns (`04_AI_ACCOUNTS/AI-03_Track.md`) but the repository baseline has no
ownership path for AI-03 artifacts (no `src/`, `Assets/`, `Contracts/` or `tracks/` directories exist in commit `584141c`).
This directory is the canonical, clearly-owned home for AI-03 design, fixtures, validators and evidence until
AI-13 publishes the frozen folder-ownership map in Phase 01.

**Integration request to AI-13:** register `tracks/ai-03-puzzle-content/` as AI-03-owned in the ownership validator and
CODEOWNERS. Note that `07_GITHUB/scripts/validate_ownership.py` currently maps `src/Presentation/` to AI-03, which
contradicts `04_AI_ACCOUNTS/ACCOUNT_MATRIX.md` (AI-03 = puzzle/content). AI-03 does not edit that script.

## Layout

```
tracks/ai-03-puzzle-content/
  README.md                          this file
  phase_00/                          Phase 00 design deliverables (markdown)
  fixtures/phase00/                  DRAFT v0.1.0 JSON fixtures consumable by other tracks
  validators/                        deterministic, stdlib-only Python validators for the fixtures
  evidence/phase00/                  captured validator output (exact command + result)
```

## Status legend used in all AI-03 documents

| Label | Meaning |
|---|---|
| VERIFIED | Confirmed from repository content at the referenced path |
| PROPOSED | AI-03 design proposal; becomes binding only through the decision/contract process |
| DRAFT | Fixture/contract shape offered for Phase 01 freeze; not consumable as RELEASED |
| UNKNOWN | Fact not derivable from the repository; recorded, not guessed |
| CONFLICT | Two repository sources disagree; recorded for the owning account |
| MISSING | Required dependency absent; mock/fixture used or work stopped as appropriate |

## Contract posture

- AI-03 consumes no RELEASED contracts in Phase 00 because none exist (`00_CONTROL/PROGRESS.md` lists all as `TBD 1.0.0`).
- AI-03 is the register-named owner of `DiscoveryDefinition`, `RewardDefinition` (`06_CONTRACTS/V7_MASTER_CONTRACT_REGISTER.md`)
  and `QuestState` (`06_CONTRACTS/WORLDCLASS_CONTRACTS_V7_1.md`). Phase 00 produces DRAFT shapes for the first two;
  `QuestState` is deferred to Phase 01 (see `phase_00/OPEN_DECISIONS_AND_CONFLICTS.md`).
- Every fixture carries `schema_version` and `status: "DRAFT"`. IDs inside are PROPOSED and are not immutable until a
  contract is marked FROZEN/RELEASED by the governance process.

## How downstream tracks use this

- **AI-02 (core/state):** objective predicates, level rules, deterministic reward/discovery conditions → domain contracts.
- **AI-04 (interaction):** level rules that touch input (axis locks, fog) and the puzzle-truth invariant.
- **AI-05/06/08 (world/companion/audio):** world hooks and causality beats in the Vertical Slice map.
- **AI-07 (UX):** mastery dimensions, challenge conditions, reward classes to present.
- **AI-09 (narrative):** chapter signature matrix, terminology requests, discovery breadcrumb requirements.
- **AI-10 (QA):** validator, negative tests, acceptance conditions.
- **AI-13 (integration):** DRAFT contract shapes, new-ID list, open conflicts.
