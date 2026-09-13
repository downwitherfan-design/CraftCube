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

### AI-04
- Branch: `ai-04-gameplay`
- Task: Phase 00 — Product/IP Lock — interaction vision, platform/input assumptions, IP-safe interaction terminology, gesture arbitration model, interruption/recovery requirements, equipment/world runtime interaction model, measurable success criteria, DRAFT contract proposal CC.INTERACTION.COMMAND 0.1.0. Deliverables under `04_AI_ACCOUNTS/AI-04/phase_00/`.
- Status: READY_FOR_REVIEW
- Contract versions consumed: none released (all baselines TBD). Referenced as intent only: INTERACTION_CONTRACTS.md (Command/State/Error contract text), AccessibilityPreference (AI-07, unversioned), PuzzleState/EquipmentEffect/CompanionReaction/DiscoveryDefinition (registered owners, unversioned).
- Contract versions changed: none. Proposed (DRAFT, not released): CC.INTERACTION.COMMAND 0.1.0.
- Tests: `python3 04_AI_ACCOUNTS/AI-04/phase_00/scripts/validate_ai04_phase00.py` → 28 passed, 0 failed (evidence: `04_AI_ACCOUNTS/AI-04/phase_00/evidence/validate_ai04_phase00.output.txt`). No Unity build, no device test — none exist yet.
- Known issues: no `integration` branch on remote (CONFLICT-04-01); ownership example files contradict account matrix (CONFLICT-04-02); 8 open decisions + 16 integration requests in `04_AI_ACCOUNTS/AI-04/phase_00/08_OPEN_DECISIONS_AND_INTEGRATION_REQUESTS.md`.
- Next integration action: AI-13 to review PR #6 (`ai-04-gameplay` → `integration`, https://github.com/downwitherfan-design/CraftCube/pull/6) and register CC.INTERACTION.COMMAND as DRAFT; AI-02/AI-07 to answer IR-04-01..08 before Phase 01 freeze.
