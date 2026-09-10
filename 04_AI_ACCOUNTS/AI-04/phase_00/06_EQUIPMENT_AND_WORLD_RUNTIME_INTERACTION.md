# AI-04 Phase 00 — Equipment & World Runtime Interaction Principles

Status: PROPOSED (runtime interaction model). Item semantics, slot count and effects are **not** decided here.
Owner: AI-04 (runtime use, targeting, feedback, arm/disarm). Effects and legality: AI-02 (`EquipmentEffect`). Item design: AI-03/AI-09/AI-01. Inventory/loadout UI: AI-07. Companion reactions: AI-06.
Phase: 00 — Product/IP Lock
Source alignment: `01_PREPRODUCTION/EQUIPMENT_ITEM_MASTER_BIBLE_V7.md`; `02_ARCHITECTURE/NARRATIVE_EQUIPMENT_SYSTEM_ARCHITECTURE_V7.md` "Capability model", "Equipment effect model"; DD-002, DD-012; V7.1 §5.4 "Loadout tension … switching must remain friction-light".

## 1. What "equipment interaction" means for AI-04

AI-04 owns the **moment of use**: how a player, with a phone in hand, selects an equipped item's action and applies it to a target (the Cube, a Tile, a Layer, a world Anchor, or the companion), and what they feel when it happens. AI-04 does not own what the item *does*; that is an `EquipmentEffect` (AI-02) driven by data (AI-03/AI-09).

This mirrors the architecture rule: "UI consumes state and commands; it does not redefine game rules." AI-04's runtime is a command producer, not a rule holder.

## 2. Runtime interaction model: ARM → TARGET → USE → RESPOND

```
ARM     player selects an equipped item's runtime action (from AI-07 loadout UI or a bound gesture)
          -> AI-04 enters armed state for that itemId; shows target affordances for valid targets
          -> affordance set comes from a capability query: CanPlayerInteractWith(target, state, loadout) (AI-02 model)
TARGET  next qualifying touch is classified by the arbiter as `equipment` if it lands on a valid target
          -> invalid target: soft refusal affordance; stays armed (one retry) then auto-disarms
USE     Command equipment.use { itemId, targetRef, source } emitted once
          -> armed state cleared immediately on emit (no repeat-fire from a held finger)
RESPOND domain returns accepted / typed failure
          -> accepted: haptic.equipment.use, presentation cue at target, then world/puzzle response events
          -> failure: haptic.puzzle.twist_reject class feedback, no state change
```

Design consequences:
- **Single-shot by default.** One arm → one use. Continuous or channelled effects (e.g., a hold-to-stabilize Field Module) are a different action type (`equipment.channel.begin/end`) that must be explicitly declared by the item definition; AI-04 will not infer hold behavior from a tap-type item.
- **Arm is cancellable** by tapping empty background, by any interruption (see `05_INTERRUPTION_AND_RECOVERY.md`), or by starting a Twist (puzzle wins: pillar P1). Starting a Twist while armed disarms silently and performs the Twist.
- **No modal takeover.** Arming changes which targets light up; it does not disable camera Orbit/Zoom, so the player can look around for the right Anchor while armed.

## 3. Target types AI-04 will support in the runtime command

| targetRef kind | Example | Notes |
|---|---|---|
| `cube` | whole-cube resonance | no sub-address |
| `tile` | a specific Tile | address form is AI-02's `PuzzleState` addressing once released; AI-04 uses an opaque string until then |
| `layer` | a Layer along an Axis | same as above |
| `anchor` | world Anchor id | id namespace owned by AI-05 (world presentation) / AI-02 (world state); AI-04 passes it through opaquely |
| `companion` | the companion (e.g., Nox per Story Bible; name is AI-09's) | reaction handled by AI-06 via `CompanionReaction` |
| `none` | self-use / passive toggle | e.g., a Memory-Lens style reveal that has no point target |

Item candidates in `01_PREPRODUCTION/ITEM_CATALOG_STARTER_SET.md` map onto these kinds (INFERRED, for feasibility only — the catalog is a design seed set, not approved content):
- Memory Lens / Echo Compass style reveals → `none` or `cube` (information effects, likely a toggle with visible duration).
- Tuning Fork / Wayfinder Shard style sensing → `none` with directional affordance; AI-04 provides the affordance channel, AI-03 the logic.
- Rootweave Gauntlet / Ember Dial / Fracture Seal style world manipulation → `anchor`.
- Prism Key style gate → `anchor` with capability gate.
- Nox Harness style companion gear → `companion`.
- Quiet Coil style timing/precision → potential `equipment.channel.*` (hold) — flagged as the one case needing the channel action type.

This confirms the ARM→TARGET→USE model covers every starter candidate without an item-specific input scheme. If a future item cannot be expressed as tap-target or channel-hold, it needs a Product review before AI-04 adds a third action type (anti-bloat).

## 4. Protecting puzzle mastery at the input layer (DD-002 / DD-012)

- `equipment.use` never carries a puzzle move payload. An item cannot "twist for you" through AI-04's command surface; if an approved item legitimately alters puzzle state, it does so inside AI-02's `EquipmentEffect` under contract, with AI-03's approval, and AI-04 only shows the result.
- Ghost Preview is never enhanced by equipment into a solution display. An item may add *information* (e.g., highlight Tiles with a property), but the preview of the pending move remains the same for all players. Any hint-like behavior is an AI-03 assist feature, surfaced as a distinct command (`puzzle.assist.request`, if approved), so it can be counted in mastery metrics (`01_PREPRODUCTION/PROGRESSION_AND_MASTERY_BIBLE_V7.md` "optional assist usage").
- Every `equipment.use` carries `source` (which gesture/UI path triggered it) so AI-10/AI-01 can evaluate whether equipment is being used as intended or as a crutch.

## 5. World interaction (Anchors)

- **Tap Anchor** → `world.anchor.tap`. Meaning is data-driven (inspect, activate, collect record). Domain decides.
- **Hold Anchor** → `world.anchor.hold` → inspect affordance (short contextual reveal; text/UI is AI-07/AI-09). Releasing ends hold. No world-state change from a hold alone unless the item/anchor definition says so.
- **Drag from Anchor** → camera Orbit (not a world action). This keeps "look around" cheap and avoids accidental world actions.
- Anchors near screen edges respect `EDGE_INSET_DP` for tap reliability; presentation (AI-05) should avoid placing critical Anchors in the inset, which AI-04 will communicate as a layout constraint request.

## 6. Tactile feedback (haptics hooks) for equipment/world

From `03_INTERACTION_TERMINOLOGY.md` §6: `haptic.equipment.use`, `haptic.world.anchor_touch`, `haptic.world.answer`, `haptic.discovery.found`.

Rules:
- Hooks fire on **domain-confirmed** results, never on gesture alone (except `anchor_touch`, which is a pure touch acknowledgment).
- Discovery haptic fires once per discovery id per profile; the once-ness is a domain flag (AI-02/AI-03), not AI-04 memory (`05_INTERRUPTION_AND_RECOVERY.md` §6).
- All hooks are scaled by the haptic intensity preference and are fully suppressible.

## 7. Accessibility and reach

- Armed-state target affordances scale with the larger-touch-target preference.
- Loadout selection UI is AI-07's; AI-04 requests that the *arm* action be reachable one-handed in portrait (bottom third of the screen) — recorded as a UX request, not an AI-04 layout decision.
- Optional gesture binding for arming (e.g., Hold on the companion, or a swipe-up from a loadout edge) is **not** proposed in Phase 00. Product/UX should first validate the UI path; a gesture shortcut is a later, evidence-driven addition.

## 8. Anti-bloat check (V7.1 §2.2, §16)

New runtime concepts introduced by this document: `armed` state, `equipment.use` command, optional `equipment.channel.*` pair, `world.anchor.tap/hold` commands. That is one state and at most five command IDs to cover all six item families and world interaction. No per-item input code. This is the complexity budget AI-04 commits to for the Vertical Slice.

## 9. Open decisions surfaced (see `08_OPEN_DECISIONS_AND_INTEGRATION_REQUESTS.md`)

- Slot count and whether any slot has a quick-use gesture (Product/UX).
- Whether any approved item requires channelled (hold) use in the Vertical Slice (AI-03/AI-01).
- Anchor id namespace owner and format (AI-02 vs AI-05) — AI-04 consumes opaquely either way.
- Whether `puzzle.assist.request` exists and under which IP-safe name (AI-03/AI-01/AI-09).

## 10. Status of facts

- VERIFIED: item families, slot suggestion ("exact slot count is a Product/UX decision"), capability model and effect model exist in the cited bibles/architecture.
- INFERRED: mapping of starter candidates to target kinds (§3) is a feasibility exercise only.
- UNKNOWN: all items listed in §9.
