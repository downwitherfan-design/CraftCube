# AI-04 Phase 00 — Interaction Terminology (IP-safe internal vocabulary)

Status: PROPOSED (internal semantic vocabulary and PROPOSED stable-ID stems; player-facing wording is AI-09's)
Owner: AI-04 (internal terms and ID stems) — player-facing names: AI-09 — final terminology approval: AI-01/Human
Phase: 00 — Product/IP Lock
Machine-readable mirror: `fixtures/interaction_terminology_registry.v0.1.0.json` (same directory tree)

## 1. Why this exists

Phase 00 must lock terminology. Thirteen accounts will refer to the same touch actions; if AI-07 calls something a "drag", AI-08 a "swipe", AI-10 a "slide" and AI-04 a "twist", tests, audio cues and UI copy drift apart. This glossary fixes the **internal** words and the **stable-ID stems** AI-04 will emit. It deliberately avoids proprietary vocabulary noted in `10_SOURCE_REFERENCE/SOURCE_GDD_NOTES.md`.

Rules:
- Terms are original or generic. No product-specific branding.
- Terms are language-neutral internally (English identifiers) so AI-09 can localize player-facing labels independently.
- Each term maps to a PROPOSED stable-ID stem following the repository's existing dotted lowercase style (`game.bloom.started`). IDs are PROPOSED, not RELEASED (`06_CONTRACTS/EVENT_AND_ID_POLICY.md`).
- Before adding any term, AI-04 searched the repository for existing equivalents. Results are in §6.

## 2. Objects the hands act on

| Term | Definition | Notes |
|---|---|---|
| **Cube** | The player-manipulated twisting puzzle object. | Generic word; already used across bibles. AI-02 owns its topology and truth. |
| **Face** | One of the flat outer sides of the Cube. | Generic geometric term. |
| **Layer** | A slice of the Cube that rotates as a unit about an axis. | "Slice" is a permitted synonym in prose but the ID stem is `layer`. |
| **Tile** | One colored/patterned unit on a Face. | Repository already uses "special tiles" and a `TileView` presentation module (`02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md`, which pairs it with a legacy synonym). AI-04 adopts **Tile** only; the legacy synonym is listed in §8 as not-used, to keep one word. |
| **Axis** | One of the Cube's rotation axes. | Domain concept; `LockedAxis` is an existing typed failure in `06_CONTRACTS/INTERACTION_CONTRACTS.md`. |
| **Anchor** | A world object the player can touch to interact with the environment (inspect, resonate, activate). | Original term. Chosen instead of "block" to stay clear of block-building vocabulary. |
| **Loadout** | The set of currently equipped items available for runtime use. | Already used in `00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md` §5.4. Reused, not invented. |

## 3. Gestures (what the finger does)

| Term | Definition | ID stem (PROPOSED) |
|---|---|---|
| **Twist** | A single-finger drag starting on a Face that rotates one Layer by a quarter turn. The canonical puzzle gesture. | `gesture.twist` |
| **Orbit** | A single-finger drag starting **off** the Cube (background) that rotates the camera around the Cube. | `gesture.orbit` |
| **Zoom** | Two-finger pinch/spread that changes camera distance within comfort limits. | `gesture.zoom` |
| **Tap** | Touch down and up within the tap time window without exceeding the drag threshold. | `gesture.tap` |
| **Hold** | Touch remains stationary beyond the hold time window. Used for inspect/preview, never for committing a Twist. | `gesture.hold` |
| **Flick** | A Twist with release velocity above the flick threshold; commits without needing full travel. Expert-speed path. | `gesture.flick` |
| **Cancel** | Any gesture ended by returning within the cancel radius, by OS touch-cancel, or by a second finger placed during a Twist. | `gesture.cancel` |
| **Cube Reorient** | Two-finger drag on the Cube that rotates the whole Cube (not the camera) — swaps which Face is front. | `gesture.reorient` |

Excluded on purpose: "swipe" (ambiguous between Twist and Orbit), "rotate" (ambiguous between Twist, Orbit and Reorient), "spin", "drag" as a standalone term. Prose may say "drag" only when describing raw touch motion before classification.

## 4. Interaction phases and states

| Term | Definition | ID stem (PROPOSED) |
|---|---|---|
| **Intent** | The classified purpose of an in-progress touch: `puzzle`, `camera`, `world`, `equipment`, `ui_passthrough`, `undecided`. | `interaction.intent.<value>` |
| **Ghost Preview** | Visual pre-visualization of where a Layer would land if the current Twist were committed. Repository already names "ghost preview" in `00_CONTROL/MASTER_ROADMAP.md` Phase 4; reused. | `interaction.preview.shown` / `interaction.preview.hidden` |
| **Commit** | The moment a gesture is converted into a Command sent to the Application layer. Irreversible from AI-04's side (undo is a domain feature owned by AI-02). | `interaction.command.committed` |
| **Settle** | The presentation animation from commit to rest. Simulation is already final when Settle begins. | `interaction.settle.started` / `interaction.settle.completed` |
| **Reject** | Domain returned a typed failure (`InvalidMove`, `LockedAxis`, ...). Presentation shows a non-punitive refusal. | `interaction.command.rejected` |
| **Input Lock** | A bounded period where puzzle input is not accepted (e.g., during a scripted world reaction). Must be measurable and short; see success criteria. | `interaction.lock.begin` / `interaction.lock.end` |
| **Recovery** | The post-interruption sequence that restores presentation to match domain state. | `interaction.recovery.completed` |

## 5. Camera vocabulary

| Term | Definition | ID stem (PROPOSED) |
|---|---|---|
| **Home Framing** | The default camera pose for the current Cube/world context. Deterministic per context. | `camera.framing.home` |
| **Reaction Framing** | A temporary camera pose that shows the world's answer to a solved state. Time-bounded and skippable. | `camera.framing.reaction` |
| **Comfort Envelope** | The allowed ranges of camera speed, distance, FOV and shake. Read from `AccessibilityPreference` (AI-07). | `camera.comfort.envelope` |
| **Recenter** | Player-triggered return to Home Framing. | `camera.recenter` |

## 6. Haptic hook vocabulary

Hooks are semantic; AI-04 fires them, an adapter maps them to device capability. AI-08 may author accompanying audio; AI-07 exposes intensity settings.

| Hook | Fires when | Intensity class | ID stem (PROPOSED) |
|---|---|---|---|
| Twist Tick | Layer passes a detent while dragging | light | `haptic.puzzle.twist_tick` |
| Twist Commit | Twist commits | medium | `haptic.puzzle.twist_commit` |
| Twist Reject | Domain rejects the move | light-double | `haptic.puzzle.twist_reject` |
| World Answer | World reaction begins after a solve/objective | strong (single) | `haptic.world.answer` |
| Anchor Touch | Player touches an interactable Anchor | light | `haptic.world.anchor_touch` |
| Equipment Use | Equipment command committed | medium | `haptic.equipment.use` |
| Discovery | Discovery recorded (source: AI-03 `DiscoveryDefinition`) | strong (pattern) | `haptic.discovery.found` |

Intensity classes are three-level (`light`, `medium`, `strong`) plus modifiers (`double`, `pattern`). This keeps the vocabulary small enough for devices with on/off-only vibration.

## 7. Repository search performed before proposing (anti-duplication)

Searched at baseline `584141c` across `*.md`, `*.json`, `*.py`, `*.csv`, `*.txt` for: gesture, swipe, pinch, haptic, camera, touch target, ghost preview, Smart Assist, Cube Pulse, Golden Trail, input.

Findings:
- No existing gesture glossary or gesture IDs exist. `gesture.*`, `interaction.*`, `camera.*`, `haptic.*` stems are absent. Safe to propose.
- "ghost preview", "haptics", "camera", "touch gestures" appear as Phase 4 deliverable nouns in `00_CONTROL/MASTER_ROADMAP.md` — reused as-is.
- "Smart Assist", "Cube Pulse", "Golden Trail" appear only in `10_SOURCE_REFERENCE/SOURCE_GDD_NOTES.md` as source-GDD concepts. AI-04 does **not** adopt these names; whether the concepts survive and under which IP-safe names is an AI-01/AI-09 Phase 00 decision (`08_OPEN_DECISIONS_AND_INTEGRATION_REQUESTS.md`). If approved, AI-04 will expose them as commands, e.g. a hint request, with IDs assigned then.
- "Loadout", "Tile", "Layer"-like language already present in bibles/blueprint; reused.
- Existing event examples: `game.bloom.started`, `game.collapse.warning`, `companion.ability.used`. AI-04 will not emit `game.*` or `companion.*` events; those namespaces belong to AI-02/AI-13 and AI-06 respectively.

## 8. Words AI-04 will not use (IP hygiene and ambiguity)

- Any proprietary game title or its creature/block/item names.
- "block", "mine", "craft", "hotbar", "crosshair" as interaction terms.
- "swipe", "rotate", "spin" as unqualified gesture names (see §3).
- "sticker" (use Tile).

## 9. Localization note

None of the terms above are player-facing strings owned by AI-04. If a term appears on screen (e.g., a tutorial says "Twist"), the string key belongs to AI-09's `LocalizationKey` contract and the UI to AI-07. AI-04 will reference such strings only by key once released.
