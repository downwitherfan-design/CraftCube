# AI-10 Track — QA / Automation / Quality Engineering

## Primary ownership
automated tests, regression, content validation, bug triage, device QA strategy, quality evidence

## Forbidden scope
Do not silently fix another account’s production code; defects are returned to the owning track unless the fix is explicitly within QA-owned tooling/tests.

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
QA focus: story progression, item/equipment, reward duplication, discovery, world-memory, migration and abuse-case testing plus playtest instrumentation.
