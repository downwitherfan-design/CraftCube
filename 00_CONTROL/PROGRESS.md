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

### AI-06
- Branch: `ai-06-creatures`
- Task: Phase 00 — Characters / Creatures / Animation / VFX direction lock, companion reaction model (DRAFT `CompanionReaction` outline), draft register, labeled fixture, validator, handoff. Artifacts under `01_PREPRODUCTION/CHARACTERS_VFX/`.
- Status: READY_FOR_REVIEW
- Contract versions consumed: none released (all `TBD 1.0.0`); worked from verified design docs and unmerged AI-01/AI-02 Phase 00 outputs (dependencies listed in lock §2)
- Contract versions changed: none (`CompanionReaction` proposed as `0.1.0-draft`, not consumable)
- Tests: `python3 01_PREPRODUCTION/CHARACTERS_VFX/tools/ai06_validate_phase00.py` → 187 passed, 0 failed
- Known issues: lock becomes LOCKED only after AI-01 product lock approval + AI-13 decisions D6-03/D6-04; no `integration` branch on remote (U6-02); D6-01 human-character fidelity and D6-02 ambient creatures need Product decisions; conflicts C6-01..C6-03 routed to owners
- Next integration action: PR `ai-06-creatures` → integration branch named by AI-13; see `01_PREPRODUCTION/CHARACTERS_VFX/AI06_PHASE00_HANDOFF.md`
