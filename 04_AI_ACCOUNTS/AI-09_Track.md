# AI-09 Track — Narrative / Lore / Localization

## Primary ownership
story, environmental narrative, dialogue, terminology, localization keys, narrative beats

## Forbidden scope
Do not own runtime architecture, UI composition, asset creation, audio implementation, or CI.

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
Narrative focus: complete story bible, three acts, chapter arcs, characters, mysteries, environmental storytelling, item/equipment lore, secrets, narrative rewards and localization terminology.

## v7 required narrative deliverables
AI-09 must maintain the Story Bible, Chapter Beat Map, Character/Companion Arc Register, Mystery/Foreshadowing Register, Narrative Item Ledger, and Localization Terminology Bible. All must use stable IDs and be consumable independently by other AI tracks.
