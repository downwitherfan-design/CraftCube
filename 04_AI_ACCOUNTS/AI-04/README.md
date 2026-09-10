# AI-04 — Gameplay / Camera / Touch / Interaction — Deliverable Index

Owner: AI-04
Track contract: `04_AI_ACCOUNTS/AI-04_Track.md`
Branch: `ai-04-gameplay`

This directory holds AI-04's phase deliverables. It is a **design/contract-proposal space**, not a production runtime path. Nothing in here is a Unity asset or shipped code. When Unity runtime code exists (Phase 02+), it will live in the runtime ownership path agreed in Phase 01 and be referenced from here.

## Ownership statement

AI-04 owns: runtime interaction orchestration, camera rig behavior, touch gesture interpretation, world interaction at runtime, item/equipment use at runtime, tactile feedback (haptics hooks), input interruption and recovery.

AI-04 does **not** own: puzzle simulation truth (AI-02), puzzle/content rules (AI-03), UI design system and HUD (AI-07), art assets (AI-05/06), audio content (AI-08), narrative terminology (AI-09), CI/build (AI-12), QA suites (AI-10), performance budgets (AI-11), contract governance (AI-13).

## Conventions used in this directory

- Every document declares a `Status` line: `DRAFT`, `PROPOSED`, `LOCKED-BY-AI-04`, or `SUPERSEDED`. `LOCKED-BY-AI-04` means AI-04 will build against it; it does **not** mean another account or the human product authority has approved it.
- Facts about the repository are labeled VERIFIED. Design intent is labeled INFERRED or ASSUMED. Anything not knowable from the repository is labeled UNKNOWN. Cross-track conflicts are labeled CONFLICT. This follows `05_PROMPTS/ANTI_HALLUCINATION_ADDENDUM.md`.
- Stable IDs proposed by AI-04 use lowercase dotted form consistent with existing repository examples (`game.bloom.started`, `biome.overworld.meadow`). AI-04 IDs are prefixed `interaction.`, `gesture.`, `camera.`, `haptic.` and are **PROPOSED** until Phase 01 contract freeze. No AI-04 ID is released.
- Contract proposals are versioned `0.x.y` and marked `DRAFT`. Per `06_CONTRACTS/CONTRACT_REGISTRY_TEMPLATE.md`, a contract is not consumable until FROZEN or RELEASED.

## Phase index

| Phase | Directory | Status |
|---|---|---|
| 00 — Product/IP Lock | `phase_00/` | IN_PROGRESS |
