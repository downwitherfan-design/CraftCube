# 13-Account Matrix

| Account | Role | Primary Ownership | Allowed Dependencies | Required Handoff |
|---|---|---|---|---|
| AI-01 | Product / Game Direction | GDD, product vision, scope, pillars, progression, acceptance criteria, IP/product decisions | Versioned contracts + mocks only | Artifacts + tests + contract versions + evidence + risks |
| AI-02 | Core Simulation / Systems Architecture | pure C# domain, deterministic puzzle engine, game-state rules, save-domain contracts | Versioned contracts + mocks only | Artifacts + tests + contract versions + evidence + risks |
| AI-03 | Puzzle Design / Level & Content Logic | puzzle mechanics, level schemas, difficulty, chapter content, validators, content logic | Versioned contracts + mocks only | Artifacts + tests + contract versions + evidence + risks |
| AI-04 | Gameplay / Camera / Touch / Interaction | Unity runtime gameplay, touch controls, camera, interaction orchestration, haptics hooks | Versioned contracts + mocks only | Artifacts + tests + contract versions + evidence + risks |
| AI-05 | Environment Art / World / Materials / Lighting | environment art direction, modular world, materials, lighting, LODs, biome kits | Versioned contracts + mocks only | Artifacts + tests + contract versions + evidence + risks |
| AI-06 | Characters / Creatures / Animation / VFX | creature assets, animation, reactions, VFX, visual feedback, technical integration metadata | Versioned contracts + mocks only | Artifacts + tests + contract versions + evidence + risks |
| AI-07 | UI/UX / Motion / Accessibility | mobile UI, HUD, menus, onboarding, motion, accessibility, localization-safe layout | Versioned contracts + mocks only | Artifacts + tests + contract versions + evidence + risks |
| AI-08 | Audio / Music / Adaptive Sound | SFX, music, adaptive layers, audio events, mixing, accessibility options | Versioned contracts + mocks only | Artifacts + tests + contract versions + evidence + risks |
| AI-09 | Narrative / Lore / Localization | story, environmental narrative, dialogue, terminology, localization keys, narrative beats | Versioned contracts + mocks only | Artifacts + tests + contract versions + evidence + risks |
| AI-10 | QA / Automation / Quality Engineering | automated tests, regression, content validation, bug triage, device QA plans | Versioned contracts + mocks only | Artifacts + tests + contract versions + evidence + risks |
| AI-11 | Performance / Android / Device Optimization | profiling, memory, CPU/GPU, thermal, battery, Android device matrix, optimization | Versioned contracts + mocks only | Artifacts + tests + contract versions + evidence + risks |
| AI-12 | Build / CI/CD / Release / Store | Unity build pipeline, GitHub Actions, signing, APK/AAB, release channels, store compliance | Versioned contracts + mocks only | Artifacts + tests + contract versions + evidence + risks |
| AI-13 | Integration / Technical Production / Architecture Governance | cross-track integration, contract governance, merge sequencing, architecture health, risk register | Versioned contracts + mocks only | Artifacts + tests + contract versions + evidence + risks |

## Non-overlap rule
No two AI accounts co-own implementation files. Shared contracts are owned by AI-13 as governance unless a contract explicitly names another owner. Consumers use released contract versions and local mocks.

## Shared integration owner
AI-13 does not replace the work of other accounts. It validates, assembles, resolves integration sequencing, and rejects changes that violate ownership, contracts, build health, or quality gates.

## CraftCube v7 expanded responsibility matrix

| AI | Added responsibility |
|---|---|
| AI-01 | product identity, narrative/equipment purpose, progression, retention, gates |
| AI-02 | world memory, item/equipment state, affinity, persistence |
| AI-03 | puzzle-linked equipment, chapter variety, mastery, discovery |
| AI-04 | runtime item/world interaction and feel |
| AI-05 | living biome and world-memory presentation |
| AI-06 | companion/item reactions, transformation VFX |
| AI-07 | inventory/equipment/discovery/story UX |
| AI-08 | narrative/item/discovery/companion audio |
| AI-09 | story bible, characters, lore, item lore, secrets, narrative events |
| AI-10 | story/item/discovery/save QA and playtest instrumentation |
| AI-11 | performance budgets for new systems |
| AI-12 | content validation and release packaging |
| AI-13 | cross-domain contract governance and unified integration |
