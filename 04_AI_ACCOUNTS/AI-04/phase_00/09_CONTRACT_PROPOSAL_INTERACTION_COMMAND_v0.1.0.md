# Contract Proposal — CC.INTERACTION.COMMAND v0.1.0

Status: **DRAFT — NOT FROZEN, NOT RELEASED, NOT CONSUMABLE** (per `06_CONTRACTS/CONTRACT_REGISTRY_TEMPLATE.md`)
Proposer: AI-04
Governance owner for release: AI-13 (per `04_AI_ACCOUNTS/ACCOUNT_MATRIX.md` "Shared contracts are owned by AI-13 as governance")
Intended freeze phase: 01 — Contract & Architecture Freeze
Phase of proposal: 00

## Registry entry (template fields)

- Contract ID: `CC.INTERACTION.COMMAND`
- Owner: AI-04 (producer semantics); AI-13 (versioning/governance)
- Version: 0.1.0
- Status: DRAFT
- Consumers (intended): AI-02 (Application/Domain accepts puzzle/world/equipment commands), AI-07 (may emit `camera.recenter`, arm requests), AI-08 (haptic/audio hook IDs), AI-10 (fixtures/tests), AI-11 (cost), AI-13 (registry)
- Compatibility promise: none until FROZEN. After release: additive fields only within MAJOR 1.
- Breaking-change policy: per `01_GOVERNANCE/CHANGE_CONTROL_AND_DECISION_LOG.md`
- Test suite: to be provided by AI-04 in Phase 01 (arbiter replay tests against fixture format §5); AI-10 owns cross-track validation
- Fixture set: `fixtures/touch_sequence_fixture.schema.v0.1.0.json` (this proposal, §5) + `fixtures/interaction_terminology_registry.v0.1.0.json`
- Migration required: NO (nothing released)
- Change decision ID: none yet — requires AI-13 decision at Phase 01

## 1. Purpose

Defines the **typed commands** AI-04's runtime emits from classified touch, the **notifications** it publishes for observers, and the **deterministic fixture format** for testing the arbiter without a device. Consumers depend on these IDs and payload shapes, not on AI-04 implementation.

This contract does **not** define: puzzle legality, move semantics, world state, equipment effects, save data, UI. It is the boundary named "Command contract" in `06_CONTRACTS/INTERACTION_CONTRACTS.md`: *Input produces commands; Application layer validates/queues them; Domain executes them.*

## 2. Envelope (all commands)

```
Command {
  schemaVersion : "0.1.0"          // string; MAJOR.MINOR.PATCH
  commandId     : string           // stable ID from §3, e.g. "puzzle.layer.twist"
  sequenceId    : uint32           // touch-sequence id from arbiter; monotonic per session
  emittedAtMs   : uint64           // monotonic ms clock; NOT wall clock; for ordering/latency only
  source        : string           // gesture ID (gesture.twist | gesture.flick | gesture.tap | ...) or "ui" 
  payload       : object           // per-command, §3
}
```

Ordering: commands from one sequenceId are emitted in order; at most one *state-changing* command per sequence (Twist, Reorient, Tap, Use). Camera deltas are many-per-sequence and are not state-changing.

Delivery: synchronous handoff to Application layer; AI-04 does not buffer across interruption (`05_INTERRUPTION_AND_RECOVERY.md` §4).

## 3. Command catalog (PROPOSED IDs)

| commandId | payload | State-changing? | Consumer |
|---|---|---|---|
| `puzzle.layer.twist` | `{ layerRef: string, axisRef: string, direction: "cw"\|"ccw" }` | yes (domain) | AI-02 |
| `puzzle.cube.reorient` | `{ fromFace: string, toFace: string }` | presentation-only by default; **UNKNOWN** pending AI-02 | AI-04 / AI-02 |
| `puzzle.tile.tap` | `{ tileRef: string }` | domain decides (may be no-op) | AI-02 / AI-03 |
| `puzzle.preview.request` | `{ layerRef, axisRef, direction }` | no (query) | AI-02 legality pre-check |
| `camera.orbit.delta` | `{ yawDeg: float, pitchDeg: float }` | no | AI-04 rig |
| `camera.zoom.delta` | `{ distanceDelta: float }` | no | AI-04 rig |
| `camera.recenter` | `{}` | no | AI-04 rig |
| `world.anchor.tap` | `{ anchorRef: string }` | domain decides | AI-02 / AI-03 |
| `world.anchor.hold` | `{ anchorRef: string, phase: "begin"\|"end" }` | no unless data says so | AI-02 / AI-07 (inspect UI) |
| `equipment.arm` | `{ itemRef: string }` | no (AI-04 armed state) | AI-04; emitted by AI-07 UI |
| `equipment.disarm` | `{ reason: string }` | no | AI-04 |
| `equipment.use` | `{ itemRef: string, target: TargetRef }` | yes (domain `EquipmentEffect`) | AI-02 |
| `equipment.channel.begin` / `equipment.channel.end` | `{ itemRef, target }` | yes | AI-02 — only if an approved item declares channelled use |

`TargetRef = { kind: "cube"|"tile"|"layer"|"anchor"|"companion"|"none", ref: string }`

All `*Ref` strings are **opaque to AI-04**; their format is defined by the owning contract (`PuzzleState` for layer/axis/tile — AI-02; anchor namespace — UNKNOWN AI-02/AI-05; `ItemDefinition` — AI-02). AI-04 never parses them.

Reserved / not proposed: `puzzle.assist.request` — depends on AI-03/AI-01 Phase 00 decision on assist features (`08_OPEN_DECISIONS_AND_INTEGRATION_REQUESTS.md`).

## 4. Notifications (observer-only; not commands)

| notificationId | payload | Purpose |
|---|---|---|
| `interaction.intent.<puzzle\|camera\|world\|equipment\|ui_passthrough\|undecided>` | `{ sequenceId }` | test/QA classification assertions |
| `interaction.preview.shown` / `.hidden` | `{ sequenceId }` | SC-B3 |
| `interaction.command.committed` | `{ sequenceId, commandId }` | latency measurement |
| `interaction.command.rejected` | `{ sequenceId, commandId, reason: InvalidMove\|LockedAxis\|ContentNotFound\|... }` | reason set = existing typed failures in `INTERACTION_CONTRACTS.md` |
| `interaction.settle.started` / `.completed` | `{ sequenceId }` | SC-F2/SC-F3 |
| `interaction.lock.begin` / `.end` | `{ reason }` | SC-F5 |
| `interaction.recovery.completed` | `{ interruptionClass: "I-A".."I-F", priorState }` | `05_INTERRUPTION_AND_RECOVERY.md` §10 |
| `camera.framing.home` / `camera.framing.reaction` | `{ contextRef }` | comfort tests |
| `haptic.*` (see terminology §6) | `{ intensityClass: light\|medium\|strong, modifier?: double\|pattern }` | AI-08 / device adapter |

Notifications are fire-and-forget, may be observed by many, never mutate state.

## 5. Deterministic touch-sequence fixture format (for AI-10 / arbiter replay)

Schema file: `fixtures/touch_sequence_fixture.schema.v0.1.0.json` (JSON Schema draft 2020-12).

```
TouchSequenceFixture {
  schemaVersion : "0.1.0"
  fixtureId     : string            // e.g. "fx.arbiter.twist_commit_45deg"
  description   : string
  tunables      : { <TUNABLE_NAME>: number, ... }   // full set from 04_GESTURE_ARBITRATION_MODEL.md §5
  viewport      : { widthDp: number, heightDp: number, safeInsetsDp: {top,bottom,left,right} }
  scene         : { cubeHitRegion: Rect, anchors: [ { anchorRef, hitRect } ] }   // 2D stand-ins for raycast
  events        : [ { t: uint32(ms), pointer: uint8, type: "down"|"move"|"up"|"cancel", x: number, y: number } ]
  expected      : { intents: [ { sequenceId, intent } ], commands: [ { commandId, payload? } ] }
}
```

Determinism contract: same `events` + same `tunables` + same `scene` ⇒ identical `commands` (SC-R4). The 2D hit regions stand in for 3D raycast so the arbiter's classification logic can be unit-tested in pure C# without Unity scene dependencies (consistent with the blueprint's "Domain must know nothing about Unity" spirit applied to the classification core).

## 6. Versioning and failure behavior

- Unknown `commandId` → consumer returns `ContentNotFound`-class failure; AI-04 surfaces reject feedback. Never silently ignored.
- Unknown `schemaVersion` MAJOR → consumer rejects the whole command. No silent downgrade.
- Additive payload fields within MAJOR are tolerated by consumers (`INTERACTION_CONTRACTS.md` "Compatibility").

## 7. Anti-duplication check

Searched baseline `584141c` for `interaction.`, `gesture.`, `camera.`, `haptic.`, `puzzle.`, `world.`, `equipment.` ID stems in all text files: none exist. Existing stems (`game.*`, `companion.*`, `biome.*`, `creature.*`, `chapter.*`, `event.*`) are not reused or shadowed.

## 8. What must happen before this can be FROZEN (Phase 01)

1. AI-02 confirms `layerRef/axisRef/tileRef` addressing and whether `puzzle.cube.reorient` is domain or presentation.
2. AI-02/AI-05 name the anchor namespace owner.
3. AI-03/AI-01 decide on assist features → add or drop `puzzle.assist.request`.
4. AI-07 confirms `equipment.arm` is emitted from loadout UI and that `AccessibilityPreference` has a change notification.
5. AI-13 assigns a change-decision ID and registers the contract.
