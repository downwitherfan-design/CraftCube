# AI-04 Phase 00 — Gesture Arbitration Model

Status: LOCKED-BY-AI-04 (model); threshold *values* are TUNABLE and marked as initial hypotheses
Owner: AI-04
Phase: 00 — Product/IP Lock
Depends on terminology: `03_INTERACTION_TERMINOLOGY.md`

## 1. Problem statement

The phase prompt requires: "Prevent camera/puzzle gesture conflicts and make all cross-domain actions contract-driven." On a phone, one finger on one screen must be able to twist a Layer, orbit the camera, touch a world Anchor, or use equipment. If each system listens to touches independently, they race. This document defines **one** arbiter with **one** decision, made once per touch sequence.

## 2. Design commitments

1. **Single arbiter.** Exactly one runtime component receives raw touches and assigns an Intent. Every other system receives typed Commands or Intent notifications, never raw touches. (Anti-duplication rule: no second touch-consumer may exist for gameplay.)
2. **Decide once, then own.** Once a touch sequence is assigned an Intent, that Intent owns the sequence until touch-up or Cancel. Intent is never re-assigned mid-sequence.
3. **Puzzle wins ties.** When classification is ambiguous and the touch began on the Cube, Intent resolves to `puzzle` (pillar P1).
4. **Undecided is a real state.** Before thresholds are crossed, Intent is `undecided`; nothing moves except a lightweight affordance. This is what makes "no accidental moves" (P2) possible.
5. **Camera never starts on the Cube.** Orbit requires the touch to begin off the Cube. Therefore a puzzle Twist and a camera Orbit can never be confused by start position alone. Cube Reorient (two-finger on Cube) is how the player changes the visible Face without moving the camera.
6. **Second finger during a Twist = Cancel.** Adding a finger while a Twist is in progress cancels the Twist rather than converting to Zoom. Converting would risk a partial twist plus a zoom; cancelling is predictable.
7. **Time is in milliseconds.** No threshold is in frames (device matrix spans 60–120 Hz).
8. **Equipment and world are commands with the same arbiter.** Equipment use does not install a modal input scheme that hijacks all touches; it registers an *armed* state that changes how `world`/`puzzle` intents are interpreted for the next qualifying touch, with an explicit disarm. See `06_EQUIPMENT_AND_WORLD_RUNTIME_INTERACTION.md`.
9. **UI passthrough is decided first.** If the touch lands on an AI-07-owned UI element, Intent is `ui_passthrough` and the arbiter does nothing else. UI hit-testing is AI-07's responsibility; the arbiter only asks "was this consumed by UI?"

## 3. Intent classification (single-touch)

```
touch_down(pos, t0)
  if ui_consumed(pos):                  -> Intent = ui_passthrough  (stop)
  hit = raycast(pos)                    // Cube face? Anchor? nothing?
  Intent = undecided
  record start_pos, start_face, start_tile, hit_anchor

touch_move(pos, t)
  if Intent == undecided:
     d  = distance(pos, start_pos)
     dt = t - t0
     if hit is CubeFace and d >= TWIST_START_PX       -> Intent = puzzle (Twist)
     if hit is none      and d >= ORBIT_START_PX      -> Intent = camera (Orbit)
     if hit is Anchor    and d >= ORBIT_START_PX      -> Intent = camera (Orbit)  // dragging off an anchor orbits; tapping it interacts
     if dt >= HOLD_MS and d < TAP_MOVE_PX             -> Intent = (hit is CubeFace ? puzzle(Hold-preview) : world(Hold-inspect) or camera-noop)
  else: forward to owning handler

touch_up(pos, t)
  if Intent == undecided:
     if (t - t0) <= TAP_MS and d < TAP_MOVE_PX:
        hit is Anchor   -> Intent = world (Tap)  -> Command world.anchor.tap
        hit is CubeFace -> Intent = puzzle (Tap) -> Command puzzle.tile.tap   // e.g. select/inspect tile; domain decides meaning
        hit is none     -> no-op (or camera Recenter if double-tap enabled; see §7)
     else -> Cancel
  else: owning handler decides Commit or Cancel
```

Two-finger rules (second touch_down while first is active):

```
if Intent == puzzle (Twist in progress)       -> Cancel Twist; Intent = undecided_multi
if Intent == camera (Orbit in progress)       -> Intent = camera (Zoom takes over; orbit continues blended)
if Intent == undecided and both on Cube       -> Intent = puzzle (Cube Reorient)
if Intent == undecided and any off Cube       -> Intent = camera (Zoom)
```

Multi-touch beyond two fingers: ignored (extra touches are not consumed by gameplay).

## 4. Twist commit rule

A Twist in progress tracks projected rotation angle θ of the selected Layer along the axis inferred from drag direction on the Face.

- **Axis inference:** The two candidate axes tangent to the touched Face are compared against the drag direction; the axis whose rotation direction best matches is chosen once |drag| ≥ `TWIST_START_PX` and locked for the sequence. Domain (AI-02) is queried for legality of both candidate moves *before* commit so a `LockedAxis` can be shown as a refusal affordance immediately (INFERRED usage of the existing typed failure list).
- **Ghost Preview** shows the Layer at the quantized target (nearest quarter turn) while θ is being dragged.
- **Commit** when touch_up occurs and either |θ| ≥ `TWIST_COMMIT_DEG` **or** release velocity ≥ `FLICK_VEL_DEG_PER_S` (Flick).
- **Cancel** when touch_up occurs with |θ| < `TWIST_CANCEL_DEG`, or on OS touch-cancel, or on second-finger.
- Between `TWIST_CANCEL_DEG` and `TWIST_COMMIT_DEG` with low velocity: snap back (Cancel) — the "dead band" prevents hesitant half-drags from committing.
- On Commit, the arbiter emits exactly one Command (`puzzle.layer.twist` with layer, axis, direction, source=`gesture.twist|gesture.flick`). Presentation Settle runs from the current θ to the target, not from zero, so there is no visual pop.

## 5. Initial threshold hypotheses (TUNABLE — not measured)

These are starting values to make the model concrete for AI-10 test writing and AI-11 measurement. They are **hypotheses**, to be tuned on the device matrix in Phase 04. They are expressed in density-independent units (dp) and milliseconds.

| Tunable | Initial value | Rationale |
|---|---|---|
| `TAP_MS` | 180 ms | Below typical hold-intent; above touch jitter |
| `TAP_MOVE_PX` | 8 dp | Finger tremor tolerance |
| `HOLD_MS` | 350 ms | Distinguishes intent to inspect from a slow tap |
| `TWIST_START_PX` | 12 dp | Enough travel to infer axis reliably; below this, `undecided` |
| `ORBIT_START_PX` | 10 dp | Camera can start slightly earlier since it is reversible and non-destructive |
| `TWIST_COMMIT_DEG` | 45° | Half a quarter-turn: intuitive "past the midpoint" |
| `TWIST_CANCEL_DEG` | 30° | Dead band 30°–45° snaps back unless flicked |
| `FLICK_VEL_DEG_PER_S` | 240°/s | Fast release commits even with short travel |
| `EDGE_INSET_DP` | 24 dp | Keep puzzle-critical drags off Android system-gesture edges; UNKNOWN true value until measured (`02_PLATFORM_AND_INPUT_ASSUMPTIONS.md` IA-04) |
| `REACTION_FRAMING_MAX_MS` | 1200 ms | Upper bound on camera Reaction Framing before input unlock; skippable by tap |

Every tunable is a named constant in one data asset (owned by AI-04) so AI-10 can vary them in tests and AI-11 can profile them. None is hard-coded in multiple places (anti-duplication).

## 6. Camera behavior contract (AI-04 internal)

- Orbit and Zoom are clamped to the **Comfort Envelope** read from `AccessibilityPreference` (AI-07). Defaults are AI-04's; overrides are the player's.
- Camera never auto-moves while Intent is `puzzle`.
- **Reaction Framing** (world answers the cube) may move the camera only after Settle completes, is time-bounded by `REACTION_FRAMING_MAX_MS`, is skippable by any tap, and respects motion-reduction (reduced-motion → cut instead of glide).
- **Recenter** returns to Home Framing; it is a command (`camera.recenter`) so UI (AI-07) can expose a button and so a double-tap on background can bind to it if Product approves.
- No camera shake is applied when `AccessibilityPreference` shake intensity is zero. Shake intensity is a multiplier, never a boolean hidden inside an effect.

## 7. Bindings that are proposals, not commitments

The following are optional bindings AI-04 recommends but does not lock; each needs an AI-01/AI-07 decision:

- Double-tap on background → `camera.recenter`.
- Long Hold on Cube → Ghost Preview of *both* candidate axes (teaching aid; may overlap with AI-03 assist design).
- Tap on Tile → `puzzle.tile.tap` (meaning is AI-02/AI-03's; may be no-op in early phases).

## 8. Intent ownership table (who consumes what)

| Intent | Commands emitted (PROPOSED IDs) | Consumer of the command |
|---|---|---|
| `puzzle` | `puzzle.layer.twist`, `puzzle.cube.reorient`, `puzzle.tile.tap`, `puzzle.preview.request` | Application → AI-02 domain (twist legality/truth); AI-04 presentation (reorient/preview are presentation-only unless AI-02 says otherwise) |
| `camera` | `camera.orbit.delta`, `camera.zoom.delta`, `camera.recenter` | AI-04 camera rig only |
| `world` | `world.anchor.tap`, `world.anchor.hold` | Application → AI-02 (world state) / AI-03 (discovery) via released contracts |
| `equipment` | `equipment.use` (with itemId + target) | Application → AI-02 `EquipmentEffect` |
| `ui_passthrough` | none | AI-07 |

Note on `puzzle.cube.reorient`: whether reorienting the whole Cube is a domain move (changes state representation) or a presentation-only view change is an AI-02 decision. AI-04 treats it as presentation-only by default and flags this as an open decision.

## 9. Determinism and testability

- Given the same ordered list of `(touch_event, pos, t)` tuples and the same tunables, the arbiter must produce the same ordered list of Commands. No frame-time dependency. This allows AI-10 to write replay tests for the arbiter without a device.
- The arbiter emits `interaction.intent.<value>` notifications with the touch sequence id so tests can assert classification separately from command emission.
- AI-04 will provide a deterministic fixture format for touch sequences in Phase 01 (proposed in `09_CONTRACT_PROPOSAL_INTERACTION_COMMAND_v0.1.0.md`).

## 10. Conflict cases this model resolves (for AI-10 test matrix)

| Case | Expected outcome |
|---|---|
| Player starts drag on Cube, drifts off Cube | `puzzle` (Intent locked at start) |
| Player starts drag on background, drifts onto Cube | `camera` (Intent locked at start) |
| Drag on Cube shorter than `TWIST_START_PX` then lift | Tap or no-op; never a twist |
| Drag to 40° slowly and lift | Cancel (dead band) |
| Drag to 20° and flick | Commit (velocity path) |
| Second finger lands mid-Twist | Twist cancelled, no zoom, no partial rotation persists |
| Two fingers land on Cube at once | Cube Reorient, camera untouched |
| Touch on UI button over Cube | `ui_passthrough`; Cube untouched |
| OS touch-cancel mid-Twist | Cancel; snap back; no Command |
| World reaction plays and player taps | Reaction Framing skipped; input unlocked |
| Tap on Anchor while equipment armed | `equipment.use` targeting Anchor; arm state cleared |

## 11. Status of facts

- VERIFIED: typed failure names `InvalidMove`, `LockedAxis` exist in `06_CONTRACTS/INTERACTION_CONTRACTS.md`; "Command contract" layering exists there; `AccessibilityPreference` contract is registered to AI-07 in `06_CONTRACTS/WORLDCLASS_CONTRACTS_V7_1.md`.
- INFERRED: that AI-02 will expose a legality pre-check usable before commit (the illustrative `GetLegalMoves()` in `CONTRACT_FIRST_RULES.md` suggests it, but no contract is released). Recorded as an integration request.
- ASSUMED: threshold values in §5.
- UNKNOWN: whether Cube Reorient is domain or presentation (§8 note).
