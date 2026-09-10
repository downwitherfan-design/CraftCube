# AI-11 Track — Performance / Android / Device Optimization

## Primary ownership
profiling, memory, CPU/GPU, thermal, battery, Android device matrix, optimization, fallback tiers

## Forbidden scope
Do not change product scope, puzzle rules, UI design, narrative, or release signing; performance fixes must preserve behavior.

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
Performance focus: budgets for narrative VFX, companions, inventory/collection data, world-state presentation and item systems on Android tiers.
