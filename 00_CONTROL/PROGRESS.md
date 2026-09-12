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

### AI-05
- Branch: `ai-05-world`
- Task: PHASE00-AI05-ENV-DIRECTION-LOCK — Environment Art Direction Lock + Biome Presentation Identity Matrix + MOCK presentation fixture + fixture validator
- Status: READY_FOR_REVIEW
- Contract versions consumed: none FROZEN/RELEASED exist; World Biome Bible tier model (design intent); `CC.BIOME.STATE` name only (schema MISSING, mocked)
- Contract versions changed: none
- Tests: `python3 09_ART_AUDIO/environment/tools/validate_environment_fixtures.py` → exit 0, 9 passed / 0 failed; 7 negative mutations each exit 1
- Known issues: DEP-03 "Quiet Engine" vs "Silent Engine" naming (AI-09); DEP-04 screen orientation UNKNOWN; DEP-05 legacy AI-05→UI ownership mappings in `07_GITHUB/*` and `08_QA_RELEASE/DEVICE_MATRIX_TEMPLATE.csv`; presentation IDs DRAFT until Phase-1 freeze
- Next integration action: review/merge PR #2 `ai-05-world` → `integration`; AI-13 ratify `09_ART_AUDIO/environment/` as AI-05 path; AI-01 ratify boundaries/cut list. Handoff: `09_ART_AUDIO/environment/handoffs/AI-05_PHASE00_HANDOFF.md`
