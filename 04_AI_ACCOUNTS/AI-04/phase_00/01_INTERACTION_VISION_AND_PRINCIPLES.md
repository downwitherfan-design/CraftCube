# AI-04 Phase 00 — Interaction Vision & Principles

Status: LOCKED-BY-AI-04 (pending Product/Human approval of dependent decisions listed in `08_OPEN_DECISIONS_AND_INTEGRATION_REQUESTS.md`)
Owner: AI-04
Phase: 00 — Product/IP Lock
Source alignment: `00_CONTROL/CRAFTCUBE_GAME_MASTER_BIBLE.md` §2, §3, §5, §13; `00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md` §9, §14; `00_CONTROL/V7_DESIGN_DECISION_REGISTER.md` DD-001, DD-002, DD-010

## 1. Purpose of this document

Phase 00 locks product vision. AI-04's contribution is to lock the **interaction vision**: what the player's hands do, what the camera does, how the two never fight, and what "feels right" means in measurable terms for a phone held in one or two hands.

Nothing here defines puzzle rules, UI layout, art, or audio. It defines the runtime interaction layer that sits between the player's fingers and the domain simulation owned by AI-02.

## 2. One-sentence interaction promise

**"The cube answers my fingers instantly and the world answers the cube — I never fight the camera to see what I did."**

This is the AI-04 restatement of the Game Master Bible core fantasy ("I am learning the language of a mysterious living cube, and every time I master it, the world answers me") from the perspective of touch.

## 3. Interaction pillars (protected)

Ordered. A lower pillar may never degrade a higher one.

### P1 — Puzzle manipulation is sacred
A deliberate puzzle gesture must always be interpreted as a puzzle gesture. The camera, world, equipment and companion layers yield to it. This is the runtime expression of DD-001 (puzzle is the protected core).

### P2 — No accidental moves
A twist the player did not intend is worse than a twist that takes slightly longer to register. Mis-fires destroy trust in the puzzle language. Cancellation is always available before commit.

### P3 — Camera is a window, not a participant
The camera exists so the player can see the cube and the world's answer. It never blocks input, never auto-moves during a live puzzle gesture, and never causes motion discomfort. Camera comfort settings are a requirement, not a polish item (V7.1 §9).

### P4 — One coherent hand model
Touch on the cube, touch on the world, equipment use and camera control are one input system with one arbitration model. They are not four separate scripts that each grab the touch first. See `04_GESTURE_ARBITRATION_MODEL.md`.

### P5 — Feedback is immediate, layered and redundant
Every accepted command produces visual response in the same frame it is accepted (presentation start, not simulation completion), plus haptic and audio hooks. Feedback channels are redundant so that a player with haptics off, audio off, or reduced motion on still perceives the result.

### P6 — Interruption never loses a committed action and never commits an uncommitted one
Phone call, app switch, notification shade, screen rotation, low-memory kill: a move that was committed to the domain stays committed; a gesture that was in progress is cancelled cleanly. No half-turned cube on resume.

### P7 — Equipment and world interaction use the same hand
Using a Resonator, Tool or Field Module at runtime (item families per `01_PREPRODUCTION/EQUIPMENT_ITEM_MASTER_BIBLE_V7.md`) must feel like part of the same tactile language, not a detour through menus. Equipment may change *what a touch can target* or *what the world reveals*; it may never alter puzzle truth (DD-002). AI-04 exposes equipment use as commands; AI-02 decides their effect.

### P8 — Accessible by default
Larger touch-target mode, one-hand reach considerations, motion reduction, haptic intensity and screen-shake intensity are first-class runtime parameters read from the `AccessibilityPreference` contract (owner AI-07, per `06_CONTRACTS/WORLDCLASS_CONTRACTS_V7_1.md`). AI-04 consumes them; it does not define the settings UI.

## 4. Emotional targets mapped to interaction

From Game Master Bible §5, the interaction layer is directly responsible for:

| Bible emotional target | AI-04 runtime responsibility |
|---|---|
| tactile satisfaction | twist commit timing, snap/settle animation curve ownership, haptic hook cadence |
| "I figured it out" | ghost preview of a pending twist so the player can *see* the plan before committing |
| visible consequence | camera framing hand-off so the world's answer is visible without the player hunting for it |
| curiosity / discovery | world-touch affordances (inspect, resonate) that are discoverable by trying, not by reading |
| mastery | zero-friction input at speed: expert players can chain twists without the camera or arbitration getting in the way |

## 5. Core interaction loop (runtime view)

```
TOUCH DOWN
  -> classify intent (puzzle / camera / world / equipment / ui-passthrough)
  -> show intent affordance (ghost preview, highlight, focus ring)
  -> TOUCH MOVE: refine, allow cancel
  -> TOUCH UP or threshold: COMMIT or CANCEL
  -> emit Command to Application layer (per 06_CONTRACTS/INTERACTION_CONTRACTS.md "Command contract")
  -> domain (AI-02) validates/executes; AI-04 receives typed result (accepted / InvalidMove / LockedAxis ...)
  -> presentation feedback: motion + haptic hook + audio hook
  -> world reaction visible (camera framing assist if configured)
```

The classification step is the single point where camera/puzzle conflicts are prevented. It is specified in `04_GESTURE_ARBITRATION_MODEL.md`.

## 6. What AI-04 will and will not do at runtime

**Will:**
- interpret raw touch into typed Commands with stable IDs;
- own camera rig behavior, framing assists and comfort limits;
- own the moment-to-moment feel: gesture thresholds, ghost preview, snap curves, cancel affordances;
- expose haptic hooks keyed by stable IDs for AI-08/AI-07 to map to device behavior and settings;
- own interruption/recovery behavior for in-progress gestures;
- expose runtime equipment-use and world-interaction commands.

**Will not:**
- decide whether a move is legal (AI-02);
- decide puzzle objectives, assist levels, or difficulty (AI-03);
- design HUD/menus/inventory screens (AI-07);
- author haptic *patterns* as audio-design content or SFX (AI-08) — AI-04 fires hooks, does not author the sound;
- set performance budgets (AI-11) — AI-04 measures against them;
- release contracts (AI-13 governance).

## 7. Non-goals (interaction-specific)

Consistent with Game Master Bible §12:

- No virtual joystick or on-screen D-pad for cube manipulation. Direct manipulation only.
- No gyroscope/tilt as a *required* input path. Tilt may be an optional comfort/expression feature only if Product approves; it is not in Phase 00 scope.
- No "auto-solve" or "auto-rotate-to-solution" gesture. A hint gesture may exist only as an AI-03-owned assist feature exposed through a command; AI-04 does not decide when hints are available.
- No camera cinematics that lock out input for longer than the measurable boundary set in `07_SUCCESS_CRITERIA_AND_MEASURABLE_BOUNDARIES.md`.
- No gesture that requires three or more simultaneous fingers for any core action.

## 8. IP-safe direction (interaction layer)

`10_SOURCE_REFERENCE/SOURCE_GDD_NOTES.md` records that the source GDD used a third-party proprietary game's presentation and naming. In the interaction layer AI-04 commits to:

- no block-placement/mining gesture vocabulary;
- no crosshair-centered first-person interaction model;
- no quick-slot-bar swipe as the equipment model — equipment use is a deliberate, named runtime action on the cube or world;
- terminology in `03_INTERACTION_TERMINOLOGY.md` is original; no proprietary product names appear in IDs or player-facing strings owned by AI-04.

Player-facing *words* remain AI-09's to finalize; AI-04 supplies the internal semantic vocabulary and stable IDs.

## 9. Relationship to Investment Gate C

`01_PREPRODUCTION/INVESTMENT_GATE.md` Gate C requires proof that "Core interaction feels good", "Touch input is reliable" and "Feedback is satisfying". AI-04 owns the measurable definitions of these three statements. They are written in `07_SUCCESS_CRITERIA_AND_MEASURABLE_BOUNDARIES.md` so that AI-10 can instrument them and AI-01 can accept or reject against numbers rather than adjectives.

## 10. Status of facts in this document

- VERIFIED: all file paths and quoted principles exist in the repository at commit `584141c` (baseline) as inspected by AI-04.
- INFERRED: the mapping of Bible emotional targets to runtime responsibilities (§4) is AI-04's design interpretation.
- ASSUMED: Unity 6 + URP + Android target per `02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md`; no Unity project exists in the repository yet, so no input-system package version is asserted here.
- UNKNOWN: exact equipment slot count (Product/UX decision per Equipment Bible); exact assist model (AI-03). Both are recorded as open decisions.
