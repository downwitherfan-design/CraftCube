# AI-04 Phase 00 — Open Decisions & Integration Requests

Status: PROPOSED (register of items AI-04 cannot decide alone; nothing here is resolved)
Owner: AI-04 (register). Decision owners named per row.
Phase: 00 — Product/IP Lock

Per the Master Control Prompt "Ownership firewall": when a required change belongs to another account, AI-04 does not edit it; it files an actionable request stating file/contract, required behavior, contract impact and acceptance test. This document is that filing. AI-13 may aggregate it per `00_CONTROL/CRAFTCUBE_START_SEQUENCE.md` Step 4.

Classification: **OD** = Open Decision (Product/Human or another owner must decide). **IR** = Integration Request (an owner is asked to provide/confirm something). **CONFLICT** = two repository sources disagree.

## A. Open decisions blocking contract freeze (Phase 01)

| ID | Decision needed | Owner | AI-04 default until decided | Why it matters to AI-04 |
|---|---|---|---|---|
| OD-04-01 | Portrait-only vs. landscape support | AI-01 (Product), AI-07 (UX) | Portrait-only | Reach zones, safe-area handling, orientation-change recovery path (`02_PLATFORM_AND_INPUT_ASSUMPTIONS.md` PA-05) |
| OD-04-02 | Equipment slot count and whether any slot gets a quick-use gesture | AI-01, AI-07 | Arm from AI-07 loadout UI only; no gesture shortcut in Phase 00 | Determines whether AI-04 must bind a gesture and defend it against Twist/Orbit (`06_EQUIPMENT_AND_WORLD_RUNTIME_INTERACTION.md` §7) |
| OD-04-03 | Do source-GDD assist concepts ("Smart Assist", "Cube Pulse", "Golden Trail") survive, and under which IP-safe names? | AI-01 (keep/cut), AI-03 (assist rules), AI-09 (names) | Not implemented; `puzzle.assist.request` reserved-not-proposed in registry | Whether a hint command exists; mastery metrics must count assist usage |
| OD-04-04 | Is `puzzle.cube.reorient` a domain move or presentation-only? | AI-02 | Presentation-only | If domain: it becomes state-changing, needs undo semantics and save impact |
| OD-04-05 | Is any Vertical Slice item channelled (hold-to-use)? | AI-03, AI-01 | Single-shot ARM→TARGET→USE only | Decides whether `equipment.channel.begin/end` enters the frozen catalog |
| OD-04-06 | Optional bindings: double-tap background → Recenter; long Hold → dual-axis preview | AI-01, AI-07 | Not bound | Both are teaching/comfort aids; long Hold may overlap AI-03 assist design |
| OD-04-07 | Unity input package choice (legacy Input vs. Input System) and version | AI-13 governance (protected `Packages/manifest.json`), AI-12 build | None; design is package-agnostic | Phase 02 bootstrap dependency; AI-04 cannot write runtime code before this |
| OD-04-08 | Minimum Android API level | AI-12, AI-11 | UNKNOWN | Affects haptic API availability and gesture-navigation inset behavior |

## B. Integration requests to other accounts

| ID | To | Request | Contract impact | Acceptance test AI-04 proposes |
|---|---|---|---|---|
| IR-04-01 | AI-02 | Expose a **synchronous, cheap legality pre-check** for a candidate move (illustrated by `GetLegalMoves()` in `06_CONTRACTS/CONTRACT_FIRST_RULES.md`, not yet a released contract) so `LockedAxis`/`InvalidMove` can be shown as a refusal affordance *before* commit. | `PuzzleState`/engine contract (AI-02) | Given a locked axis, `puzzle.preview.request` returns the typed failure within one frame; no state change. |
| IR-04-02 | AI-02 | Define `layerRef`, `axisRef`, `tileRef` string formats in `PuzzleState` so AI-04 can pass them opaquely. | `PuzzleState` 1.0.0 | Fixture round-trip: refs emitted by AI-04 are accepted by a fake engine without parsing on AI-04's side. |
| IR-04-03 | AI-02 | Confirm Command accept semantics are synchronous ("accepted" == persist-eligible) so AI-04's no-buffering rule on interruption is safe (`05_INTERRUPTION_AND_RECOVERY.md` §4). | Application/Command contract | Kill app immediately after accept → committed move present on relaunch. |
| IR-04-04 | AI-02 | Read-only presentation state query cheap enough to call on every resume (`05_INTERRUPTION_AND_RECOVERY.md` §5 step 2). | State contract (`INTERACTION_CONTRACTS.md` "State contract") | Resume-to-input ≤ 300 ms (SC-F6) on low tier. |
| IR-04-05 | AI-02 / AI-05 | Name the **Anchor id namespace owner** and format. | New or existing `WorldState` sub-contract | `world.anchor.tap` with a fixture anchorRef resolves in a fake world provider. |
| IR-04-06 | AI-07 | `AccessibilityPreference` must include a **change notification**, not only a getter; and must carry: motion reduction, haptic intensity (0..1), shake intensity (0..1), larger-touch-targets flag, camera comfort mode. | `AccessibilityPreference` (AI-07) | Toggle each setting at runtime → SC-C1..C5 assertions pass without restart. |
| IR-04-07 | AI-07 | Loadout UI emits `equipment.arm { itemRef }` and the arm control is reachable one-handed in portrait (bottom third). | Consumes CC.INTERACTION.COMMAND (DRAFT) | SC-C7 moderated reach test. |
| IR-04-08 | AI-07 | UI hit-testing exposes "touch consumed by UI" so the arbiter can assign `ui_passthrough` first (`04_GESTURE_ARBITRATION_MODEL.md` §2.9). | UI/input boundary | Fixture: tap on UI rect over Cube → zero puzzle commands. |
| IR-04-09 | AI-05 | Avoid placing interaction-critical Anchors inside `EDGE_INSET_DP` and device unsafe insets (layout constraint). | none (layout guidance) | SC-C6 zero violations on matrix devices. |
| IR-04-10 | AI-08 | Map `haptic.*` hook IDs and intensity classes to authored haptic/audio content; AI-04 fires hooks only. | Audio cue ID family (AI-08) | Every hook ID in registry has a mapped cue or an explicit "silent" entry. |
| IR-04-11 | AI-06 | `CompanionReaction` consumes `equipment.use` with `target.kind == companion` and puzzle/world result events; AI-04 does not animate companions. | `CompanionReaction` (AI-06) | Fixture: use companion-gear item → reaction event emitted by AI-06 fake. |
| IR-04-12 | AI-10 | Adopt: arbiter replay fixture format (`fixtures/touch_sequence_fixture.schema.v0.1.0.json`), conflict-case matrix (`04_…` §10), interruption matrix (`05_…` §3, §10), success criteria SC-* (`07_…`). | Test plan | AI-10 test IDs reference SC-* IDs one-to-one. |
| IR-04-13 | AI-11 | Confirm or replace proposed budgets SC-P1..P4 and timing hypotheses (`HITCH_MS`, SC-F1 latency targets) in `PerformanceBudget`. | `PerformanceBudget` (AI-11) | Published numbers referenced by ID from `07_…` §6. |
| IR-04-14 | AI-13 | Register `CC.INTERACTION.COMMAND` 0.1.0 as DRAFT in the contract registry; assign change-decision ID at Phase 01 freeze; confirm AI-04 owns namespaces `gesture.`, `interaction.`, `camera.`, `haptic.`, `puzzle.`(command side), `world.anchor.`, `equipment.`(runtime side). | Registry | Registry row exists; namespace table published. |
| IR-04-15 | AI-13 | Confirm the branch naming discrepancy (see CONFLICT-04-01) and the PR target branch. | Governance | Documented decision. |
| IR-04-16 | AI-09 | Provide IP-safe player-facing names / localization keys for Twist, Orbit, Recenter, Arm/Use when they appear in tutorials; AI-04 will reference keys only. | `LocalizationKey` (AI-09) | Keys exist for each term listed in `03_INTERACTION_TERMINOLOGY.md` §3 that is shown on screen. |

## C. Conflicts detected in the repository (VERIFIED)

| ID | Conflict | Sources | AI-04 handling |
|---|---|---|---|
| CONFLICT-04-01 | Branch model names `ai-04/gameplay-mobile`; actual remote uses `ai-04-gameplay`. At AI-04's initial inspection the `integration` branch was **absent** (only `ai-13-integration` existed); on re-check before PR it **exists** at baseline `584141c`. | `07_GITHUB/GITHUB_MODEL.md` vs. `git ls-remote --heads origin` (two inspections) | RESOLVED for PR routing: PR targets `integration` as the phase prompt requires. Remaining discrepancy is naming only (`ai-04/gameplay-mobile` vs `ai-04-gameplay`); AI-13 asked to align the model doc or branch names (IR-04-15). |
| CONFLICT-04-02 | `07_GITHUB/CODEOWNERS_EXAMPLE.txt` and `validate_ownership.py` map `Assets/Art/`, `Assets/VFX/` to AI-04 and `src/Presentation/` to AI-03, contradicting the account matrix (AI-04 = runtime/interaction; AI-05/06 = art/VFX). | `07_GITHUB/*` vs. `04_AI_ACCOUNTS/ACCOUNT_MATRIX.md` | Both files are self-labeled "example/conceptual". AI-04 follows the account matrix and asks AI-13/AI-12 to correct the examples before any CI enforcement (Phase 01/02). |
| CONFLICT-04-03 | `08_QA_RELEASE/DEVICE_MATRIX_TEMPLATE.csv` assigns device-tier ownership to AI-07/AI-05, while the account matrix assigns device matrix to AI-11 and QA to AI-10. | CSV vs. account matrix | Template predates v7 renumbering (INFERRED). AI-04 treats AI-11 as device-matrix owner; flagged to AI-13. |

## D. Items AI-04 explicitly did **not** decide (anti-guessing record)

- Any numeric threshold or budget as final — all are hypotheses (`04_…` §5, `07_…`).
- Player-facing wording (AI-09).
- Whether haptics are on by default (AI-07 settings default; AI-04 only consumes).
- Whether Nox or any companion has touch interaction beyond `target.kind == companion` (AI-06/AI-09).
- Any Unity package, version or API name (none exist in repository).

## E. Human approval required (per `00_CONTROL/13_AI_EXECUTION_MANUAL.md` "Human approval gates")

None of AI-04's Phase 00 artifacts change product identity, scope, monetization or story canon. No human gate is triggered by AI-04 alone. OD-04-01 and OD-04-03 may trigger a Product decision if AI-01 treats orientation or assist features as scope items.
