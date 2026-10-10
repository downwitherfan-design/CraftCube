# AI-04 Phase 00 — Platform & Input Assumptions

Status: LOCKED-BY-AI-04 (assumptions; each row carries its evidence class)
Owner: AI-04
Phase: 00 — Product/IP Lock

This document records the platform and input assumptions AI-04 will design against. Each assumption is tagged VERIFIED / INFERRED / ASSUMED / UNKNOWN per `05_PROMPTS/ANTI_HALLUCINATION_ADDENDUM.md`. Assumptions that turn out false must be revised through the change-control process, not silently.

## 1. Platform

| # | Assumption | Class | Source / note |
|---|---|---|---|
| PA-01 | Primary platform is Android phones. | VERIFIED (as product intent) | `00_CONTROL/V7_DESIGN_DECISION_REGISTER.md` DD-010; Game Master Bible §13 |
| PA-02 | Engine direction is Unity 6 + URP. | VERIFIED (as architecture intent) | `02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md` "Engine" |
| PA-03 | No Unity project, `Packages/manifest.json`, or `ProjectSettings/` exists in the repository yet. | VERIFIED | Repository tree inspected at baseline `584141c`: only planning directories present. |
| PA-04 | The Unity input package (legacy `Input` vs `com.unity.inputsystem`) and its version are not yet chosen. | UNKNOWN | Not in repository. AI-04 will request the decision in Phase 01 (owner of `Packages/manifest.json` protected zone is governance per `01_GOVERNANCE/MULTI_AI_OPERATING_MODEL.md` اصل 5). AI-04's design is package-agnostic: it defines gesture semantics, not API calls. |
| PA-05 | Portrait is the primary orientation. | ASSUMED | Consistent with one-hand mobile puzzle play and the mobile-first rule. Not stated explicitly in any repository document. Flagged as a decision for AI-01/AI-07 in `08_OPEN_DECISIONS_AND_INTEGRATION_REQUESTS.md`. Landscape support is a Product decision, not an AI-04 default. |
| PA-06 | Device tiers Low / Mid / High / Tablet exist as a QA template. | VERIFIED | `08_QA_RELEASE/DEVICE_MATRIX_TEMPLATE.csv` |
| PA-07 | Target frame rates: 60 FPS mid-tier target, 30 FPS low-power/safe mode. | VERIFIED (as hypothesis, not measurement) | `02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md` "Performance budgets are hypotheses until measured"; `00_CONTROL/MASTER_ROADMAP.md` Phase 12 gate. |
| PA-08 | Display refresh rates of 60 Hz and up to 120 Hz must be handled. | VERIFIED | Device matrix lists 60, 60-120, 120. Interaction timing therefore must be expressed in milliseconds, never in frames. |
| PA-09 | Safe area / display cutout handling is required. | VERIFIED | V7.1 §9 "safe-area/device-cutout handling"; `08_QA_RELEASE/WORLDCLASS_QA_EXPANSION.md` UX QA. |
| PA-10 | Offline core play is mandatory; no interaction feature may depend on network. | VERIFIED | DD-015; Game Master Bible §12. |

## 2. Input hardware

| # | Assumption | Class | Note |
|---|---|---|---|
| IA-01 | Capacitive multi-touch is the only *required* input. | ASSUMED (design commitment) | Consistent with Game Master Bible §13 "responsive on touch devices". Mouse/keyboard support for editor testing is a development convenience, not a product feature. |
| IA-02 | At most two simultaneous touches are required for any core action. | LOCKED-BY-AI-04 | Interaction non-goal §7 of `01_INTERACTION_VISION_AND_PRINCIPLES.md`. Three-finger gestures are excluded for one-hand reach and for devices/OS gesture-navigation conflicts. |
| IA-03 | Vibration/haptic hardware may be absent, disabled by the user, or limited to on/off with no amplitude control. | ASSUMED (defensive) | AI-04 haptic hooks therefore carry semantic intent (e.g. `haptic.puzzle.twist_commit`) and an intensity class, not raw waveform parameters. Mapping to device capability is a runtime adapter concern; product must remain fully playable with haptics off (pillar P5 redundancy). |
| IA-04 | Android system gesture navigation (edge swipes for back/home) occupies screen edges. | ASSUMED (platform knowledge, version-dependent) | AI-04 will keep puzzle-critical swipe start zones away from screen edges by a margin to be tuned on device. The exact inset is UNKNOWN until measured on the device matrix and is recorded as a tunable, not a constant. |
| IA-05 | Gyroscope/accelerometer are present on most target devices but are **not** used for any required interaction. | LOCKED-BY-AI-04 | Non-goal. |
| IA-06 | Stylus and external controllers are out of scope for the core loop. | LOCKED-BY-AI-04 | May be revisited only through a Product decision. |

## 3. OS / lifecycle behavior AI-04 must survive

| # | Event | Required AI-04 behavior class |
|---|---|---|
| LC-01 | Incoming call / app to background mid-gesture | In-progress gesture cancelled; committed commands preserved. See `05_INTERRUPTION_AND_RECOVERY.md`. |
| LC-02 | Notification shade pulled down mid-gesture (touch cancel delivered by OS) | Treated as gesture cancel, never as commit. |
| LC-03 | Screen rotation (if landscape is ever approved) | Gesture cancelled; camera state re-framed deterministically. |
| LC-04 | Process killed by OS while backgrounded | Recovery relies on AI-02 save-domain state; AI-04 restores only presentation/camera state and must never hold the sole copy of a committed move. |
| LC-05 | Touch driver "palm rejection" / spurious touch cancel | Same handling as LC-02. |
| LC-06 | Frame hitch > one frame during gesture | Gesture thresholds are time-based (ms), so a hitch does not change classification; presentation catches up, simulation is unaffected. |

## 4. Layering assumptions

| # | Assumption | Class | Source |
|---|---|---|---|
| LA-01 | Input produces Commands; Application validates/queues; Domain executes. | VERIFIED | `06_CONTRACTS/INTERACTION_CONTRACTS.md` "Command contract" |
| LA-02 | Domain is pure C# with no UnityEngine, input-device or UI knowledge. | VERIFIED | `02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md` "Dependency rule" |
| LA-03 | Failures come back as stable typed reasons (`InvalidMove`, `LockedAxis`, `ContentNotFound`, ...). | VERIFIED | `06_CONTRACTS/INTERACTION_CONTRACTS.md` "Error contract". AI-04 will map each to a distinct feedback response. |
| LA-04 | Presentation state for UI/audio is read-only; AI-04 does not let UI mutate simulation. | VERIFIED | `06_CONTRACTS/INTERACTION_CONTRACTS.md` "State contract" |
| LA-05 | The domain interface shape is illustrative only (`IPuzzleEngine` example) and is **not** a released contract. | VERIFIED | `06_CONTRACTS/CONTRACT_FIRST_RULES.md` labels it "Example interface"; `00_CONTROL/PROGRESS.md` lists all contract baselines as "TBD 1.0.0". AI-04 will mock against its own draft (`09_CONTRACT_PROPOSAL_INTERACTION_COMMAND_v0.1.0.md`) until AI-02 releases. |

## 5. Explicitly UNKNOWN (must not be guessed)

- Exact Unity version string and input package version.
- Minimum Android API level.
- Whether landscape orientation is in scope.
- Equipment slot count and whether equipment use is a hold, tap or drag at runtime (Product/UX decision; AI-04 has proposed a default in `06_EQUIPMENT_AND_WORLD_RUNTIME_INTERACTION.md`).
- Whether Smart Assist / Cube Pulse / Golden Trail from the source GDD (`10_SOURCE_REFERENCE/SOURCE_GDD_NOTES.md`) survive Product Phase 00 review, and under which IP-safe names (AI-01 / AI-09).
- Performance budget numbers for input latency beyond the "no noticeable delay" statement (AI-11 owns; AI-04 proposes measurable targets in `07_SUCCESS_CRITERIA_AND_MEASURABLE_BOUNDARIES.md` for AI-11 to confirm or replace).

## 6. Consequence for design

Because PA-04, PA-05 and the equipment-slot decision are UNKNOWN, every AI-04 Phase 00 artifact is written so that it remains valid regardless of how those are decided:

- gesture semantics are expressed as intent + thresholds, not API calls;
- layouts are described as reach zones relative to the cube, not absolute pixel positions;
- equipment use is a command with a stable ID; the triggering gesture is a tunable binding.
