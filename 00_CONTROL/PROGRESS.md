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

### AI-08
- Branch: `ai-08-audio`
- Task: PHASE00-AI08-AUDIO-IDENTITY-LOCK — audio identity, IP-safe direction, adaptive audio language, DRAFT cue-ID contract + fixture + validator
- Status: READY_FOR_REVIEW
- Contract versions consumed: none released (all `TBD 1.0.0`); design references intended families by name only
- Contract versions changed: new DRAFT `CC.AUDIO.CUE` 0.1.0 (owner AI-08) — requires AI-13 registration; freeze targeted for Phase 01
- Tests: `python3 09_ART_AUDIO/AUDIO/scripts/test_validate_audio_cue_registry.py` → 17/17 passed; fixture validates with exit 0
- Known issues: `integration` branch MISSING on remote (PR target unavailable); CONFLICT in `07_GITHUB/CODEOWNERS_EXAMPLE.txt`/`validate_ownership.py` maps `/Assets/Audio/` to AI-06 (reported, not edited); open decisions AUD-OD-01..04
- Next integration action: AI-13 creates `integration`, registers `CC.AUDIO.CUE` DRAFT, opens PR `ai-08-audio` → `integration`; details in `09_ART_AUDIO/AUDIO/PHASE_00_HANDOFF_AI-08.md`
