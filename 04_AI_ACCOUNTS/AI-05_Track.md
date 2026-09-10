# AI-05 Track — Environment Art / World / Materials / Lighting

## Primary ownership
environment art direction, modular world kits, materials, lighting, LODs, biome presentation

## Forbidden scope
Do not change gameplay logic, core simulation, UI navigation, audio systems, or build settings except documented art import requirements.

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
World focus: living biome states, world-memory presentation and environment-driven narrative cues.
