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

### AI-03
- Branch: `ai-03-puzzle`
- Task: Phase 00 — Product/IP Lock — puzzle vocabulary, mechanic families, level grammar, content principles (`05_PROMPTS/phase_00/ai_03.md`)
- Status: READY_FOR_REVIEW
- Contract versions consumed: none RELEASED exist (all `TBD 1.0.0`); design bibles and decision register consumed as intent
- Contract versions changed: none released. DRAFT shapes offered for Phase 01 freeze: `CC.CONTENT.CHAPTER_SIGNATURE 0.1.0`, `CC.CONTENT.LEVEL 0.1.0`, `CC.REWARD.DEFINITION 0.1.0`, `CC.DISCOVERY.DEFINITION 0.1.0` (`tracks/ai-03-puzzle-content/fixtures/phase00/`)
- Tests: `python3 tracks/ai-03-puzzle-content/validators/validate_phase00_content.py` → PASS (0 errors, 1 warning); `python3 -m unittest tracks/ai-03-puzzle-content/validators/test_validate_phase00_content.py` → 33 tests OK. Evidence: `tracks/ai-03-puzzle-content/evidence/phase00/validator_run.txt`
- Known issues: reachability/par unverified (no solver until Phase 03); Act III chapter↔biome mapping UNKNOWN; decisions AI03-D1..D5 and conflicts AI03-C1..C4 open — see `tracks/ai-03-puzzle-content/phase_00/08_OPEN_DECISIONS_AND_CONFLICTS.md`
- Next integration action: AI-13 to register `tracks/ai-03-puzzle-content/` ownership and name the PR target branch (`integration` does not exist on remote); AI-01 to decide AI03-D1..D5; AI-09 to resolve AI03-C1
