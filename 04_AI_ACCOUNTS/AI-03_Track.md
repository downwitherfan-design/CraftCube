# AI-03 Track — Puzzle Design / Level & Content Logic

## Primary ownership
puzzle mechanics, level schemas, difficulty, chapter content, validators, content logic, progression tuning

## Forbidden scope
Do not rewrite core engine architecture, presentation systems, UI, or build pipeline.

## Working contract
- Consume only released/frozen contracts.
- Prefer additive, reversible changes.
- Use mocks/stubs/fixtures when dependencies are not ready.
- Never invent missing repository facts.
- Search before creating a new semantic system, ID or asset reference.
- Report cross-track needs instead of silently editing another owner's files.
- Keep production behavior deterministic where the domain requires it.
- Measure rather than guess for performance-sensitive changes.

## Required self-audit
Before PR: inspect diff, run relevant validators/tests, verify ownership, check for duplicate IDs/systems, record evidence and provide rollback.


## CraftCube v7 expanded ownership
Puzzle/content focus: puzzle-linked equipment effects, anti-repetition, mastery challenges, discoveries, secret states and rewards.

## v7 content deliverables
AI-03 must maintain a Puzzle-to-Reward Matrix and a Puzzle-to-Equipment Interaction Matrix so equipment never becomes detached from puzzle design and no chapter repeats the same challenge pattern without justification.
