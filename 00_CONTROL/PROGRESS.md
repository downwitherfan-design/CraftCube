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

### AI-12
- Branch: `ai-12-build`
- Task: PHASE00-AI12-RELEASE-DIRECTION-LOCK — Release & Build Direction Lock v1.0.0, Release Validation Gate Policy (RG-001..017), DRAFT contracts BuildProvenance / RemoteContentManifest / TelemetryEvent 0.1.0 + MOCK/NEG fixtures + stdlib validator, .gitignore and inactive CI templates
- Status: READY_FOR_REVIEW
- Contract versions consumed: none FROZEN/RELEASED exist (all `TBD 1.0.0`); `TelemetryEvent`/`RemoteContentManifest` ownership rows read from `06_CONTRACTS/WORLDCLASS_CONTRACTS_V7_1.md`; PD-010/013/014 read from unmerged `origin/ai-01-product` as product intent
- Contract versions changed: none (three new DRAFT outlines live under `12_RELEASE/contracts/`; registry inclusion requested)
- Tests: `python3 12_RELEASE/tools/validate_release_fixtures.py` → exit 0, 10 passed / 0 failed (3 positive MOCK, 7 NEG_ each failing on its declared RG); validator self-test with a mislabelled negative → exit 1. No build/CI/device run exists to claim.
- Known issues: RD-001 no `integration` branch on origin; RD-002 legacy `.github/`+`Release/`→AI-08 mapping in `07_GITHUB/*`; RD-003 `12_RELEASE/` path awaiting ratification; RD-004/005/006/007 Unity version, CI licence/keystore custody, applicationId/title, telemetry legal stance are UNKNOWN/HUMAN; RG-001..009/013..015 MISSING by design until domain owners publish validators
- Next integration action: AI-13 create `integration`, ratify path + fix ownership mapping, register `BuildProvenance` and `RG/RD/RC` ID families; PR `ai-12-build` → `integration`. Handoff: `12_RELEASE/handoffs/AI-12_PHASE00_HANDOFF.md`
