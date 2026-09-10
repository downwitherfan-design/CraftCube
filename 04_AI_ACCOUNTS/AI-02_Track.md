# AI-02 Track — Core Simulation / Systems Architecture

## Primary ownership
pure C# domain, deterministic puzzle engine, state rules, save-domain contracts, system architecture

## Forbidden scope
Do not own Unity presentation, UI, VFX, audio, narrative content, or build infrastructure.

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
Systems focus: deterministic world memory, item/equipment state, affinity, reward and narrative-flag semantics plus save persistence.

## v7 state deliverables
AI-02 must define deterministic semantics for narrative flags, item ownership/equipped state, upgrades, affinity evaluation, companion reaction triggers, discovery records and world-memory transitions using existing architecture patterns where available.
