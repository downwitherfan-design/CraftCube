# AI-04 Phase 00 — Interruption & Recovery Requirements

Status: LOCKED-BY-AI-04 (requirements); implementation deferred to Phase 04+
Owner: AI-04 (runtime interaction recovery). Save/domain persistence is AI-02. Reward idempotency is AI-02/AI-03. Save/recovery *tests* are AI-10.
Phase: 00 — Product/IP Lock
Source alignment: Game Master Bible §13 "stable under interruption"; AI-04 Track "interruption and recovery"; `08_QA_RELEASE/STORY_ITEM_TEST_MATRIX.md` "interruption during acquisition", "termination during save".

## 1. Principle

Restated from pillar P6: **a committed action is never lost; an uncommitted gesture is never committed.**

Everything in this document follows from that sentence plus one architectural fact: AI-04 never holds the only copy of game truth. Truth lives in the AI-02 domain and its versioned save. AI-04 holds *presentation and gesture state*, which is disposable by design.

## 2. Interruption classes

| Class | Examples | Detectable by |
|---|---|---|
| I-A Soft focus loss | notification shade, split-screen resize, transient dialog, permission prompt | app pause/focus-lost callback; OS touch-cancel |
| I-B Background | phone call, home button, app switch, screen lock | app pause; later app resume |
| I-C Process death | OS memory reclaim while backgrounded, crash | absence of runtime state on next launch; only persisted state exists |
| I-D Input anomaly | palm rejection cancel, touch driver reset, >2 fingers, glove/wet-screen jitter | OS touch-cancel, impossible touch deltas |
| I-E Time anomaly | frame hitch, GC spike, thermal throttle slowing frame delivery | large frame delta while a gesture is live |
| I-F Configuration change | orientation change (if ever enabled), accessibility setting changed mid-session, display cutout change (foldables) | configuration callback; `AccessibilityPreference` change event |

## 3. Required behavior per gesture state

The arbiter (`04_GESTURE_ARBITRATION_MODEL.md`) has a small state space. Behavior on interruption is defined per state so it is testable.

| Gesture state at interruption | Required behavior |
|---|---|
| `undecided` | Discard. No Command. No visual change persists. |
| `puzzle` Twist in progress (pre-commit) | **Cancel.** Layer snaps back to rest (or cuts back under reduced motion). No Command is emitted. Ghost Preview hidden. Haptic: none (do not vibrate on interruption). |
| `puzzle` Twist committed, Settle in progress | **Preserve.** The Command was already sent; domain state is final. On resume, presentation is rebuilt from domain state, so the Layer appears at rest in its committed position. Settle animation is not resumed mid-way; it is skipped. |
| `camera` Orbit/Zoom in progress | Freeze at current pose; on resume, keep pose if within Comfort Envelope, else Recenter to Home Framing. No Command semantics (camera is presentation-only). |
| `world` Hold-inspect | Discard inspect affordance. No Command unless already committed. |
| `equipment` armed (awaiting target) | **Disarm.** Player must re-arm after resume. Prevents accidental use on the first touch after coming back. |
| Input Lock active (world reaction playing) | On resume, Input Lock is **ended**; Reaction Framing is skipped; camera goes to Home Framing. Never resume into a locked state. |

## 4. Command boundary rule (why "committed" is safe)

- A Command becomes "committed" only when the Application layer has accepted it and handed it to the domain. Whether the domain then persists it is AI-02's save policy.
- AI-04 must **not** buffer Commands across an interruption. If a Command was not accepted before the pause, it is dropped and the gesture is treated as cancelled. Reason: replaying a stale intent after the player has looked away is the definition of an accidental move.
- Corollary for AI-02 (integration request, not an AI-04 decision): the domain's accept step should be synchronous and cheap so "accepted" and "persist-eligible" are the same instant from the player's point of view.

## 5. Resume sequence (required order)

```
1. Read AccessibilityPreference (AI-07 contract) — motion, haptics, shake, touch-target size may have changed.
2. Query domain presentation state (AI-02 read-only state contract).
3. Rebuild Cube presentation from domain state (no animation).
4. Camera -> Home Framing for current context unless a valid pre-pause pose exists within Comfort Envelope.
5. Arbiter -> reset to idle; discard any touch sequence ids; disarm equipment.
6. Emit interaction.recovery.completed (with reason class I-A..I-F).
7. Re-enable input.
```

Input is not re-enabled before step 7. Between steps 1–6 there is no window where a touch could be interpreted against stale presentation.

## 6. Process death (I-C) specifics

- AI-04 persists **nothing** that is required for correctness. Camera pose and last Intent are not saved.
- Optional: AI-04 may persist a tiny presentation hint (e.g., last Home Framing context id) via whatever settings/save channel AI-02/AI-07 release. If unavailable, cold-start uses defaults. This must never be a dependency.
- Reward/acquisition idempotency (e.g., a discovery haptic must not fire twice on relaunch) is enforced by domain state flags (AI-02/AI-03), not by AI-04 remembering "I already vibrated". AI-04 fires `haptic.discovery.found` only in response to a domain/discovery event, never speculatively.

## 7. Input anomaly (I-D) specifics

- Any OS touch-cancel → Cancel path, identical to lifting the finger inside the dead band.
- Touch deltas exceeding a plausibility ceiling (e.g., > half the screen in one event) → treat the sequence as cancelled rather than as a Flick. Ceiling is a tunable (`MAX_PLAUSIBLE_DELTA_DP`, initial hypothesis 400 dp) in the same tunables asset as the arbiter thresholds.
- Third and further simultaneous touches are ignored; they neither commit nor cancel.

## 8. Time anomaly (I-E) specifics

- Because thresholds are time-based, a single long frame does not misclassify a gesture.
- Velocity for Flick is computed over a sliding window of the last `FLICK_WINDOW_MS` (initial hypothesis 80 ms) of touch samples, not from the last two frames, so a hitch cannot fabricate a flick.
- If frame delta > `HITCH_MS` (initial hypothesis 100 ms) during a live Twist, the arbiter suppresses Flick for that sequence and only allows the angle-based Commit path. The player keeps control; nothing is auto-committed.

## 9. Configuration change (I-F) specifics

- Accessibility preference change mid-session is applied at the next arbiter idle state, never mid-gesture.
- Orientation change is treated as I-B (cancel + resume sequence). Landscape itself is out of scope unless Product approves (`02_PLATFORM_AND_INPUT_ASSUMPTIONS.md` PA-05).

## 10. Observable outputs for QA (AI-10 can instrument these)

- `interaction.recovery.completed` with reason class and the pre-interruption gesture state.
- Count of Commands emitted between pause and resume must be zero.
- After resume, presentation cube state equals domain cube state (assertable by comparing Tile layout to domain `PuzzleState`, once that contract is released).
- No haptic hook fires during the resume sequence.

## 11. What AI-04 needs from other tracks (integration requests, recorded in `08_OPEN_DECISIONS_AND_INTEGRATION_REQUESTS.md`)

- AI-02: read-only presentation state query cheap enough to call on every resume; synchronous Command accept semantics; confirmation that `puzzle.cube.reorient` is presentation-only.
- AI-07: `AccessibilityPreference` change notification (not just a getter) so resume step 1 and §9 are possible.
- AI-10: adopt the interruption cases in §3 and the observables in §10 into the save/recovery test plan.
- AI-11: confirm `HITCH_MS` and the resume-sequence cost budget.

## 12. Status of facts

- VERIFIED: the repository requires interruption stability (Game Master Bible §13), lists interruption cases as QA concerns, and assigns save schema to AI-02.
- ASSUMED: numeric hypotheses in §7–§8.
- UNKNOWN: whether any settings channel is available to AI-04 for optional presentation hints (§6). Designed as non-dependency.
