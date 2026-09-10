# AI-13 Track — Integration / Technical Production / Architecture Governance

## Primary ownership
cross-track integration, contract governance, merge sequencing, architecture health, risk register, release gates

## Forbidden scope
Do not become the hidden implementation owner; do not rewrite another account’s work instead of returning an actionable change request.

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
Integration focus: narrative/item/world contract governance, dependency graph, integration sequencing and final consistency gates.
