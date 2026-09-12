# AI-04 Phase 00 — Success Criteria & Measurable Boundaries (Interaction)

Status: PROPOSED (targets are hypotheses for AI-01 acceptance and AI-11 budget confirmation; measurement methods are LOCKED-BY-AI-04)
Owner: AI-04 (definitions and measurement methods). Acceptance authority: AI-01. Budget authority: AI-11. Instrumentation: AI-10.
Phase: 00 — Product/IP Lock
Source alignment: `01_PREPRODUCTION/INVESTMENT_GATE.md` Gate C; `08_QA_RELEASE/QUALITY_AND_RELEASE.md` Gate B, Gate E; `08_QA_RELEASE/EVIDENCE_STANDARD.md`; `00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md` §9, §14, §15.

## 1. Why numbers

Investment Gate C says the prototype must show "Core interaction feels good", "Touch input is reliable", "Feedback is satisfying". Those are adjectives. AI-04's Phase 00 job is to turn them into quantities that can pass or fail, so that Phase 06 Gold Slice evidence is real evidence (`08_QA_RELEASE/EVIDENCE_STANDARD.md`: "Evidence must match the claim").

Every criterion states **what is measured, how, on what, and the initial target.** Targets are hypotheses until measured on the device matrix. **No result is claimed here — nothing has been built or measured.** This document is the yardstick, not the reading.

## 2. Reliability criteria ("Touch input is reliable")

| ID | Criterion | Measurement method | Initial target | Boundary (fail) |
|---|---|---|---|---|
| SC-R1 | Accidental twist rate | Moderated playtest: Twists the player reports as unintended ÷ total Twists. Instrumented proxy: Twists undone within 1.5 s of commit. | ≤ 2 % unintended (proxy ≤ 4 %) | > 5 % |
| SC-R2 | Missed twist rate | Intended Twists that ended in Cancel (dead band). Proxy: Cancel followed by same-direction Twist within 1.5 s. | ≤ 5 % | > 10 % |
| SC-R3 | Camera/puzzle misclassification | Arbiter replay tests on labeled touch-sequence fixtures; % mismatched Intent. | 0 % on fixture set | any mismatch |
| SC-R4 | Arbiter determinism | Same fixture + same tunables replayed N times → identical Command list. | 100 % identical over 1000 runs | any divergence |
| SC-R5 | Edge-zone tap reliability | Taps on Anchors at the `EDGE_INSET_DP` boundary register on all device-matrix devices. | 100 % register | any device < 98 % |
| SC-R6 | Multi-touch cancel correctness | Second finger during Twist → zero Commands, Layer returns to rest. | 100 % in automated PlayMode test | any partial rotation persists |

## 3. Responsiveness criteria ("feels good")

Timings are wall-clock milliseconds measured **on device**, never in editor. "Visual response" = first frame in which the Layer/Ghost Preview visibly moves in response to the touch.

| ID | Criterion | Measurement method | Initial target | Boundary |
|---|---|---|---|---|
| SC-F1 | Touch-to-visual latency (Twist drag) | High-speed camera (≥ 240 fps) or on-device input timestamp vs. frame-present timestamp; median over 50 drags. | Mid tier ≤ 50 ms; Low tier ≤ 83 ms (median) | Mid > 83 ms; Low > 120 ms |
| SC-F2 | Commit-to-Settle start | Touch-up commit to first Settle frame. | ≤ 1 frame at 60 Hz (≤ 16.7 ms) | > 2 frames |
| SC-F3 | Settle duration (quarter turn from rest) | Designed constant, verified by PlayMode test. | 140–220 ms (tunable within band) | outside band without decision record |
| SC-F4 | Haptic hook dispatch latency | Commit → haptic hook call (device actuation is outside AI-04 control). | ≤ 1 frame | > 2 frames |
| SC-F5 | Input Lock duration | Any `interaction.lock.begin`→`end` interval. | ≤ `REACTION_FRAMING_MAX_MS` (initial 1200 ms); always skippable | non-skippable lock; any lock > 2000 ms |
| SC-F6 | Resume-to-input-enabled | App resume callback → arbiter accepting input (`05_INTERRUPTION_AND_RECOVERY.md` §5). | ≤ 300 ms after presentation state available | > 1000 ms |
| SC-F7 | Expert chaining | Consecutive Twist commits with no idle by an experienced tester. | ≥ 4 commits/s without dropped inputs | dropped or merged inputs |

## 4. Comfort & accessibility criteria (V7.1 §9)

| ID | Criterion | Measurement method | Initial target | Boundary |
|---|---|---|---|---|
| SC-C1 | Camera max angular speed (Orbit) | Instrumented °/s clamp, sourced from `AccessibilityPreference`. | Default ≤ 180°/s; comfort ≤ 90°/s | clamp not applied |
| SC-C2 | Reduced motion respected | Reduced-motion on: Reaction Framing cuts (no glide); Settle uses short non-overshoot curve; no shake. PlayMode assertions. | 100 % of motion paths honor flag | any path ignores flag |
| SC-C3 | Haptic intensity respected | Intensity 0 → zero actuation calls forwarded to device adapter. | 100 % | any actuation at 0 |
| SC-C4 | Shake intensity respected | Shake multiplier 0 → amplitude 0. | 100 % | any shake at 0 |
| SC-C5 | Larger touch targets | Flag on → Anchor and armed-target hit areas ≥ 48 dp minimum dimension. | 100 % of targets | any target < 48 dp |
| SC-C6 | Safe-area / cutout | No interaction-critical affordance inside device-reported unsafe insets on all matrix devices. | 0 violations | any violation |
| SC-C7 | One-hand reach (portrait) | Core loop (Twist, Orbit, Recenter, Arm via UI) completable with one thumb on a 6.5"-class device in moderated test. | 100 % of core actions | any core action needs second hand |

## 5. Feedback criteria ("Feedback is satisfying")

Satisfaction is subjective; AI-04 makes *presence and coherence* of feedback testable and leaves quality judgment to moderated playtests (AI-01/AI-10).

| ID | Criterion | Measurement method | Initial target | Boundary |
|---|---|---|---|---|
| SC-B1 | Feedback redundancy | Every accepted Command produces ≥ 2 of: motion, haptic hook, audio hook. Hook-table static check + PlayMode assertion. | 100 % of Commands | any Command < 2 channels |
| SC-B2 | Reject distinct from accept | `InvalidMove`/`LockedAxis` produce distinct motion + haptic class from success. | 100 % | indistinguishable |
| SC-B3 | Ghost Preview presence | Preview visible before commit for every Twist above `TWIST_START_PX`. | 100 % | missing preview |
| SC-B4 | Playtest "felt in control" | 5-point Likert after moderated session (wording owned by AI-01/AI-10). | median ≥ 4 on mid tier | median ≤ 3 |

## 6. Performance boundaries (proposed to AI-11 — AI-11 owns the final budget)

| ID | Boundary | Rationale |
|---|---|---|
| SC-P1 | Arbiter per-frame CPU ≤ 0.2 ms on low tier | Negligible vs. 33 ms frame at 30 FPS |
| SC-P2 | Zero managed allocations per touch event in steady state | Gate E: "no repeated GC spikes in common loop" |
| SC-P3 | Camera rig update ≤ 0.3 ms on low tier | Same rationale |
| SC-P4 | Haptic hook dispatch allocation-free | `twist_tick` fires frequently |

If AI-11 publishes different numbers in `PerformanceBudget`, AI-11's numbers win and this table is updated by reference, not by silent edit.

## 7. First-session interaction criteria (V7.1 §14)

| ID | Criterion | Target |
|---|---|---|
| SC-S1 | Time to first intentional Twist commit by a new player, no text instruction | ≤ 30 s median (moderated) |
| SC-S2 | Time to first successful Orbit | ≤ 60 s median |
| SC-S3 | New players who drag on the Cube expecting camera and are confused | measured and reported; no Phase 00 target — informs whether Cube Reorient needs teaching |

## 8. Investment Gate C mapping

| Gate C statement | Operationalized by |
|---|---|
| Core interaction feels good | SC-F1, SC-F2, SC-F3, SC-F7, SC-B4 |
| Touch input is reliable | SC-R1–SC-R6 |
| Feedback is satisfying | SC-B1–SC-B4, SC-F4 |
| (implicit) comfort & accessibility | SC-C1–SC-C7 |

## 9. Evidence format AI-04 will produce (Phase 04/06)

Per `08_QA_RELEASE/EVIDENCE_STANDARD.md`:
- Reliability: fixture set path + exact test command + pass/fail counts.
- Latency: device model, OS version, build id, method (camera fps or timestamp API), sample count, median/p95.
- Comfort: PlayMode test names + results + device list.
- Playtest: session id, device, participant count (no personal data), Likert distribution.

No evidence exists yet. This section defines format only.

## 10. Status of facts

- VERIFIED: Gate C wording; Gate B/E wording; V7.1 §9/§14 requirements; device matrix tiers and refresh rates.
- ASSUMED: every numeric target (hypotheses pending AI-11 and AI-01).
- UNKNOWN: no measurement taken; no device tested; no build exists.
