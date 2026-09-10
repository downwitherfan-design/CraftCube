# CraftCube v7 — 13-AI Execution Manual

## Why the project is split into 13 AIs

The split exists to gain speed through parallel work while preserving specialist quality. Each account is an independent production cell, not a subordinate worker for another AI.

## Universal output contract

Every AI handoff must contain:
1. task and phase,
2. owned files,
3. contracts consumed/changed,
4. stable IDs added,
5. artifacts produced,
6. tests/validators run,
7. evidence paths,
8. known risks,
9. integration steps,
10. rollback steps.

## Ownership map

### AI-01 — Product / Game Direction
Owns product decisions, scope, pillars, feature priority, acceptance criteria, investment gates, retention philosophy, product economics and final design decisions.

### AI-02 — Core Simulation / Systems Architecture
Owns deterministic puzzle logic, world-state transitions, persistent domain state, item/equipment state rules, progression state and core domain contracts.

### AI-03 — Puzzle / Content Design
Owns puzzle mechanics, chapter puzzle design, difficulty, challenge variants, puzzle objectives, mastery rules, puzzle-linked rewards and anti-repetition design.

### AI-04 — Gameplay / Camera / Touch / Interaction
Owns runtime interaction, camera, touch gesture interpretation, world interaction, item use at runtime, tactile feel and input recovery.

### AI-05 — Environment / World / Lighting
Owns environment production, biome presentation, world-state visual transitions, modular world kits, traversal presentation and visual readability.

### AI-06 — Characters / Creatures / Animation / VFX
Owns creatures, companions presentation, character animation, reactions, transformations, VFX and emotional visual feedback.

### AI-07 — UI/UX / Motion / Accessibility
Owns HUD, onboarding, inventory, equipment management, upgrade presentation, quest/discovery UX, accessibility and mobile ergonomics.

### AI-08 — Audio / Music / Adaptive Sound
Owns SFX, music, adaptive layers, audio events, world/puzzle audio feedback, equipment and discovery audio.

### AI-09 — Narrative / Lore / Localization
Owns Story Bible, lore, character arcs, mysteries, dialogue, item lore, narrative events, terminology, localization keys and environmental storytelling content.

### AI-10 — QA / Automation / Quality Engineering
Owns automated tests, content validators, progression validation, save/recovery tests, equipment interaction tests, regression and player-test instrumentation.

### AI-11 — Performance / Android / Device Optimization
Owns budgets, profiling, low/mid/high device behavior, memory/CPU/GPU/thermal/battery controls and performance acceptance evidence.

### AI-12 — Build / CI/CD / Release
Owns reproducible Unity builds, validation pipelines, content checks, APK/AAB production, release channels, versioning and store-readiness infrastructure.

### AI-13 — Integration / Technical Production / Governance
Owns cross-track contract governance, merge order, integration validation, architecture health, dependency graph, risk register and final assembly.

## Independence rule

A dependency is blocking only when the contract itself is missing or incompatible.

If implementation is not ready, use a mock, fake provider, fixture or adapter. Do not wait.

## Forbidden behavior

- stealing another AI's implementation files,
- changing another AI's ownership as a shortcut,
- silently changing contracts,
- creating duplicate managers/systems/IDs,
- claiming integration because branches exist,
- treating compilation as proof of feature correctness.

## Integration sequence

`Contract -> Mock -> Independent Build -> Evidence -> Integration Request -> Integration Branch -> Full Validation -> Merge`

## Human approval gates

The owner (human product authority) must explicitly approve:
- product identity changes,
- major scope expansion,
- monetization direction,
- story canon replacement,
- release-blocking risk acceptance,
- removal of the protected puzzle core.

AI-13 cannot approve these by itself.
