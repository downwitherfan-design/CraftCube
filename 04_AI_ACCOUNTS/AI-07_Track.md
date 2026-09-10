# AI-07 Track — UI/UX / Motion / Accessibility

## Primary ownership
mobile UI, HUD, menus, onboarding, motion, accessibility, localization-safe layout and UX

## Forbidden scope
Do not alter domain rules, gameplay logic, asset source files, audio, or CI except UI-related configuration explicitly owned here.

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
UX focus: inventory, equipment, upgrades, discovery ledger, story presentation, accessibility and low-cognitive-load mobile flows.

## v7 UX deliverables
AI-07 must design the inventory/equipment experience around fast recognition, meaningful comparison, lightweight discovery, contextual item lore and accessible mobile interaction; avoid RPG menu overload.
