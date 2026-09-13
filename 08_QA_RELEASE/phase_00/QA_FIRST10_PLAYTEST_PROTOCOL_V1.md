# CraftCube — First-10-Minutes Fresh-Install Playtest Protocol

| Field | Value |
|---|---|
| Owner | AI-10 — QA / Automation / Quality Engineering |
| Document ID | `CC.QA.PROTOCOL.FIRST10` |
| Version | 1.0.0-draft |
| Status | DRAFT — exit-question wording requires AI-01 review before it is frozen (delegated in `FIRST_10_MINUTES_PROOF.md` §Playtest protocol handoff: "verbatim wording to be frozen by AI-10 with AI-01 review") |
| Consumes | `CC.PRODUCT.FIRST10` 1.0.0 (`F10-001..007`), `CC.PRODUCT.IGM` 1.0.0 (`IGM-001..008`), `CC.PRODUCT.DECISIONS` 1.0.0 (`PD-001/002/003/005/007`) — all on `ai-01-product@2db84b5`, READY_FOR_REVIEW |
| Produces | one `playtest_session_record.schema.json` 1.0.0 record per participant |
| First executable | Phase 06 Gold Slice (needs a build from AI-12 and a device tier from AI-11) |
| Traceability | `QAT-019..029` in `QA_PHASE00_TRACEABILITY_REGISTER.json` |

## 1. What this protocol is for

The first ten minutes are the product's only guaranteed audience (`FIRST_10_MINUTES_PROOF.md`). This protocol turns the F10 proof points and IGM thresholds into a repeatable observation procedure so that Phase 06 gate numbers are **measured the same way every iteration**. It is a research instrument, not a marketing survey: the observer's job is to record, not to help.

Nothing in this document is a result. No CraftCube build exists at the time of writing; the protocol has never been run.

## 2. Honesty rules

1. A metric whose method could not be executed is reported `UNMEASURED`, never `PASS` (IGM honesty rule).
2. Cohort < 8 → every cohort-level metric is `UNDERPOWERED`; reported but not used to pass a gate.
3. Record `buildId` and `deviceTier` exactly as published by AI-12 / AI-11. If either is not published, write `UNKNOWN`; build-dependent metrics for that record become `UNDERPOWERED`.
4. Observers never invent timestamps. If a stopwatch was missed, the field is `null`.
5. Coded answers only. No verbatim quotes are stored (privacy §8).

## 3. Participants

- **Eligibility:** matches the primary audience in `PRODUCT_LOCK_V1.md` §4 (adults who play thoughtful mobile puzzle games). Secondary-audience participants (physical cube solvers) are tagged in `notes` as process notes only ("cohort: secondary") and analysed as a sub-group.
- **Exclusions:** anyone who has seen CraftCube footage, design documents or a prior build; anyone from the 13 tracks.
- **Cohort size:** minimum 8 per iteration (Phase 06), minimum 30 (Phase 15). Aim for at least 2 participants per AI-11 device tier where the matrix exists.
- **Consent:** verbal + written research consent covering observation and coded notes. No recording of face or voice is required by this protocol; if a team chooses screen capture, it is stored separately and never linked to the session record.

## 4. Setup (before the participant arrives)

| Step | Action | Why |
|---|---|---|
| S1 | Fresh install of the AI-12 test build on the target device; no prior save; airplane mode ON | F10 "fresh install"; `PD-010` offline core |
| S2 | Device in portrait, brightness normal, haptics ON, volume audible | Product Lock §5 portrait-first; F10-001 feedback |
| S3 | Observer starts a stopwatch at the moment the participant taps the app icon (`appStartAtMs = 0`) | all timing fields are relative to app start |
| S4 | Prepare the interruption trigger (see §6) | F10-007 |
| S5 | Prepare the session record with `sessionId`, `iteration`, `observer`, `buildId`, `deviceTier`, `protocolVersion` filled | schema required fields |

## 5. Observation script (0:00 → 10:00)

The observer says exactly one sentence at the start:

> "Please play as you normally would. You can think aloud if you like. I won't be able to answer questions until the end."

Then the observer is silent. No hints, no nods toward the screen, no reactions.

### 5.1 Timestamps to capture

| Field | Trigger | Traces |
|---|---|---|
| `firstDeliberateTwistAtMs` | First face rotation that the participant clearly intended (they look at the result). Accidental rotations do not count. | F10-001, QAT-019 |
| `firstSolveAtMs` | The moment the first pattern completes (world begins reacting). | F10-002, QAT-020 |
| `solvedPredicateTrueAtMs`, `firstWorldReactionAtMs` | Build-side log, not stopwatch. `null` until AI-02/AI-05 instrumentation exists. | F10-002 [BUILD], QAT-020 |

### 5.2 Booleans and tallies to capture

| Field | Rule |
|---|---|
| `unpromptedWorldChangeMention` | Participant says anything equivalent to "that changed / grew / opened / lit up" before being asked. |
| `unpromptedCreatureMention` | Participant mentions the creature (any word) before being asked. |
| `unpromptedQuestionVoiced` | Participant voices a why/what/who question about the world, cube or characters before being asked. |
| `accidentalInputsObserved` | Count of visible unintended rotations or camera moves (participant reacts with surprise/correction). Cross-check for AI-04's `unintendedActionsCounter`. |
| `menusForcedOpen` | Count of menus the game opened without the participant asking. Product requires 0. |
| `numericIndicatorSeen` | Any level, XP, score, currency number visible at any time. Product requires false. |
| `maxAssistUsed` | Participant reached the highest Smart Assist level at least once. |

### 5.3 Stop rule

At 10:00 the observer says:

> "That's the end of the guided part. You can stop here or keep going — it's up to you."

Set `continuation.offered = true`. Start a second stopwatch. If the participant keeps playing, record `continued = true` and `continuationDurationMs` when they stop or at 5:00 of continuation, whichever is first. `IGM-001` counts a continuation ≥ 3:00 (180000 ms).

## 6. Forced interruption (F10-007 / IGM-006c)

Exactly once, at a moment between **2:00 and 6:00** chosen before the session (vary across participants), the observer triggers an interruption that backgrounds the app for 20–30 s:

- Preferred: an incoming call to the test device from a second phone.
- Fallback: press Home, open the camera app, return.

Record `interruption.atMs` and, on return, `recoveryResult`:

| Value | Meaning |
|---|---|
| `EXACT` | Puzzle state, world state, position and any in-progress twist identical to before. |
| `LOST_TWIST_ANIMATION_ONLY` | The twist animation in flight was dropped; logical state intact. **Allowed** by F10-007. |
| `LOST_PUZZLE_STATE` / `LOST_WORLD_STATE` / `LOST_POSITION` / `LOST_LOADOUT` / `LOST_DISCOVERY_OR_FLAGS` | Data loss → **HARD_STOP** (`IGM-006c`). Stop the session's metric collection for build-dependent fields; complete the exit interview anyway. |
| `CRASH` | App did not return. HARD_STOP. |

## 7. Exit interview — frozen wording (pending AI-01 review)

Ask in this order, read verbatim, do not paraphrase, do not prompt with examples. Code each answer per §7.1. Where two raters are required, both code independently from the observer's coded summary, not from a quote.

| # | Verbatim question | Record in | Traces |
|---|---|---|---|
| Q1 | "In one sentence, what is this game about?" | `q1_whatIsGameAbout` (two raters) | IGM-003, F10-006, QAT-024 |
| Q2 | "What did solving the cube do?" | `q2_whatDidSolvingDo` (two raters) | IGM-007, F10-003, QAT-021 |
| Q3 | "Is there anything you want to find out?" | `q3_wantToFindOut` | IGM-005, F10-004, QAT-022 |
| Q4 | "Did any object you found let you do something new? What?" | `q4_objectLetYouDoNew` | IGM-004, F10-005, QAT-023 |
| Q4b | "Earlier you had more than one place you could go and fix. Which did you pick first?" | `q4b_recognizedChoice` (true if they name one) | F10-005, QAT-023 |
| Q5 | "How do you think you get better or progress in this game?" | `q5_howDoYouProgress` | F10-006, QAT-024 |
| Q6 | "Did anything feel confusing or fiddly?" | `q6_confusingOrFiddly.accidentalInputComplaint`, `.menuComplaint` | F10-001, PD-003, QAT-019/027 |
| Q7 | "Was there too much reading or too many cutscenes?" | `q7_tooMuchReading` | IGM-005b, QAT-022 |
| Q8 | "Would you play this again tomorrow if it were on your phone? Why?" | `q8_playAgainTomorrow.answer`, `.reasonCodes` | IGM-008, QAT-029 |
| Q9 | "Did you figure it out yourself, did the game do it for you, or a mix?" | `q9_solveOwnership` | IGM-001b, PD-007, QAT-026 |
| Q10 | "What do you remember most?" | `q10_rememberMost` | IGM-005c (SHOULD) |

Q1–Q6 wording is taken from `FIRST_10_MINUTES_PROOF.md` §Playtest protocol handoff. Q7–Q10 are taken from the corresponding IGM method text. Q4b is a QA addition to make the F10-005 "recognized a choice" pass condition measurable; it is flagged for AI-01 acceptance (finding `QAF-007`).

### 7.1 Coding rules

| Field | Codes | Rule |
|---|---|---|
| Q1 | `DISTINCT` / `GENERIC` / `COMPETITOR_FRAMED` / `UNCODABLE` | Lists owned by AI-01 (`IGM-003`). Until AI-01 publishes them, use the IGM text: distinct = cube changes world / restoring a world / mystery of why it broke / creature that reacts / tools that reveal; competitor-framed = a franchise name or "like [franchise]" as the *primary* description. |
| Q2 | `CONCRETE_WORLD_CHANGE` / `ABSTRACT_REWARD` / `UNSURE` | Concrete = names a thing in the world that changed. Abstract = points, progress, "I won". |
| Q3 | `STORY_WORLD_QUESTION` / `UI_QUESTION` / `NONE` | "Why did the world break?" = story/world. "How do I open the map?" = UI. |
| Q4 | `BEHAVIORAL` / `NUMERIC` / `SOLVED_FOR_ME` / `NONE` | Behavioral = see/reach/reveal/compare/stabilize. Numeric = stronger/faster/more. **`SOLVED_FOR_ME`** = "it made it easier / did it for me" — coded separately because it drives the IGM-004 HARD_STOP. |
| Q5 | `NUMBERS_LEVELS` / `SKILL_TOOLS_PLACES_STORY` / `OTHER` | |
| Q8 reasons | Bible §11 healthy list + `DARK_PATTERN` + `OTHER` | Any mention of a timer, streak, daily reward or fear of missing out → `DARK_PATTERN` (must be 0%; there is nothing in the build to cite). |
| Q9 | `ME` / `MIX` / `GAME` | |

Inter-rater agreement for Q1 and Q2 is reported per cohort (simple percent agreement; a third rater breaks ties). Agreement < 80% → the coding list is unclear; finding to AI-01.

## 8. Privacy and data handling

- Session records contain **no** name, contact, device identifier, voice, face or verbatim quote. `sessionId` is `PT-<iteration>-<participant>`; the mapping to a person is kept only on the consent form, stored separately, and destroyed after the cohort report is written.
- Records are stored as JSON validated against `fixtures/playtest_session_record.schema.json`. The schema's `additionalProperties: false` and the validator's D3 check are the technical guard against accidental personal fields.
- These records are player-research instrumentation, not telemetry. They never leave the research device/spreadsheet and are not subject to the `TelemetryEvent` contract; when in-build telemetry exists (Phase 13+), it is governed by `QAT-033`.

## 9. Cohort evaluation

For each metric, compute the cohort value exactly as the IGM method states (percent of participants, or median). Apply the IGM gate outcome rule (`PASS` / `CONDITIONAL` / `FAIL`) per metric; HARD_STOP conditions escalate immediately. Report as a table with: metric ID, threshold, cohort value, n, `MEASURED`/`UNMEASURED`/`UNDERPOWERED`, evidence path (records folder + build ID). Numbers are never rounded toward the threshold.

## 10. What this protocol does not cover

- Gold Slice tasks (`IGM-002b` loadout change, `IGM-004b` swap) are a **separate** Phase 06 task script appended after minute 10; F10 forbids forced menus in the first 10 minutes, so they cannot be inside this script. Fields exist in the schema under `goldSliceTasks`.
- Frame-time measurement (`IGM-006b`) is AI-11's profiler capture, run on the same build and device tier, reported as EVIDENCE.
- The `unintendedActionsCounter` is AI-04's build debug counter (`IGM-006` "AI-04 to provide"); until it exists the observer tally is the only source and the metric is `UNDERPOWERED`.

## 11. Open items for other owners

| ID | Item | Owner |
|---|---|---|
| QAF-007 | Accept/reject Q4b wording and Q7–Q10 wording so this document can move from `1.0.0-draft` to `1.0.0` | AI-01 |
| QAF-006 | Operational definition of "unintended action" + debug counter | AI-04 |
| QAF-003 | Device matrix so `deviceTier` can be filled | AI-11 |
| — | Build-side `solvedPredicateTrueAt` / `firstWorldReactionAt` log lines | AI-02 / AI-05 (Phase 03–05) |

## 12. Change control

Wording changes to Q1–Q10 after freeze are a minor version and invalidate cross-iteration comparison for the changed question; record the reason in the findings register. Adding an observation field is a patch to this document and follows the schema's version rules.
