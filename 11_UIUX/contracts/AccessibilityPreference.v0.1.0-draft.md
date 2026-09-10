# Contract: AccessibilityPreference

Registry row (per `06_CONTRACTS/CONTRACT_REGISTRY_TEMPLATE.md`):

- Contract ID: `AccessibilityPreference`
- Owner: AI-07
- Version: `0.1.0`
- Status: **DRAFT** (not consumable until FROZEN/RELEASED in Phase 01)
- Consumers (registered): AI-04, AI-08, AI-10, AI-11 (`06_CONTRACTS/WORLDCLASS_CONTRACTS_V7_1.md`)
- Consumers (proposed addition, IR-AI07-005): AI-05, AI-06
- Compatibility promise: additive-only within MAJOR 0.x → 1.x freeze; unknown keys are preserved and ignored by readers; missing keys resolve to defaults
- Breaking-change policy: per `01_GOVERNANCE/CHANGE_CONTROL_AND_DECISION_LOG.md`
- Test suite: `11_UIUX/tools/validate_a11y_fixtures.py` (schema/fixture validator, stdlib-only)
- Fixture set: `11_UIUX/fixtures/accessibility_preference/*.json`
- Migration required: NO (first version)
- Change decision ID: none yet (DRAFT)

Design source: `11_UIUX/phase_00/ACCESSIBILITY_COMFORT_BASELINE.md` §2.

---

## 1. Semantics

A single, versioned, player-owned preference block describing comfort and accessibility choices.
It is **read-only for all consumers except AI-07's settings UI**, which is the only writer.

It contains no gameplay truth. Changing any value must never alter puzzle legality, scoring or
progression state (DD-001/DD-002 spirit).

## 2. Storage decision (deferred to Phase 01 with AI-02)

Two compatible options; both use the identical block below:

- **Option A** — embedded as a sub-object of `SaveSchema.settings` (Technical Blueprint save
  design lists `settings`). Owner of the container: AI-02. Owner of the sub-object: AI-07.
- **Option B** — stored as a separate device-local file/key (survives profile deletion, applies
  before any save is loaded).

AI-07 recommendation: **Option B for storage, plus mirroring the block into the save on write**
so that a profile restored on a new device carries comfort settings. Final call belongs to the
Phase 01 contract freeze (AI-02 + AI-13).

## 3. Schema (JSON representation; engine-side DTO to mirror exactly)

```json
{
  "schema": "AccessibilityPreference",
  "schema_version": "0.1.0",
  "reduce_motion": false,
  "camera_comfort": "standard",
  "screen_shake_intensity": 0.5,
  "haptic_intensity": 0.5,
  "audio_cue_redundancy": true,
  "color_assist_indicators": false,
  "large_touch_targets": false,
  "handedness": "auto",
  "safe_area_mode": "system",
  "dialogue_text_speed": "normal",
  "text_scale": 1.0,
  "high_contrast_ui": false,
  "hold_to_confirm_destructive": true
}
```

### Field table

| Field | Type | Allowed values | Default | Required |
|---|---|---|---|---|
| `schema` | string | `"AccessibilityPreference"` | — | yes |
| `schema_version` | string (semver) | `"0.1.0"` | — | yes |
| `reduce_motion` | bool | — | `false` | no |
| `camera_comfort` | string enum | `standard`, `steady`, `minimal` | `standard` | no |
| `screen_shake_intensity` | number | `0.0`, `0.25`, `0.5`, `0.75`, `1.0` | `0.5` | no |
| `haptic_intensity` | number | `0.0`, `0.25`, `0.5`, `0.75`, `1.0` | `0.5` | no |
| `audio_cue_redundancy` | bool | — | `true` | no |
| `color_assist_indicators` | bool | — | `false` | no |
| `large_touch_targets` | bool | — | `false` | no |
| `handedness` | string enum | `right`, `left`, `auto` | `auto` | no |
| `safe_area_mode` | string enum | `system`, `extended_padding` | `system` | no |
| `dialogue_text_speed` | string enum | `slow`, `normal`, `fast`, `instant` | `normal` | no |
| `text_scale` | number | `1.0`, `1.15`, `1.3`, `1.5` | `1.0` | no |
| `high_contrast_ui` | bool | — | `false` | no |
| `hold_to_confirm_destructive` | bool | — | `true` | no |

Rules:
- `schema` and `schema_version` are the only required fields. Every other field falls back to
  its default when absent (forward/backward tolerance).
- A reader encountering a **higher MAJOR** version must refuse to apply and surface a
  user-visible notice, then use defaults (Save & Migration Policy: never silently deserialize
  a newer schema). MINOR/PATCH differences are read with unknown keys ignored.
- An **invalid value** (out of enum/set) is a defect signal: the reader applies the field
  default, logs a typed failure and flags the block as `degraded` to the UI so the Settings
  screen can show "some comfort settings were reset". No silent fallback.
- Float fields are compared with tolerance 1e-6 against the allowed set.

## 4. Change event (proposed ID, not yet registered)

When the settings UI commits a change, it emits:

`ux.accessibility.changed` — payload: full `AccessibilityPreference` block after change.

Producer: AI-07 settings UI. Delivery: in-process, at-least-once, idempotent (consumers re-read
full block). Ordering: latest wins.

ID search performed before proposal (`grep -rhoE` over repo): existing dotted IDs are
`game.bloom.*`, `game.collapse.*`, `companion.ability.used`. No `ux.*` namespace exists; this ID
is **proposed for registration** in Phase 01 via AI-13 event governance (IR-AI07-006). It is not
released.

## 5. Fixtures

| File | Purpose |
|---|---|
| `fixtures/accessibility_preference/default.json` | All defaults — golden fixture |
| `fixtures/accessibility_preference/max_comfort.json` | Every comfort aid enabled — smoke-test consumers |
| `fixtures/accessibility_preference/left_handed_large_targets.json` | Ergonomics case |
| `fixtures/accessibility_preference/minimal_keys_only.json` | Only required keys — tests default resolution |
| `fixtures/accessibility_preference/invalid_enum_case.json` | **Negative** fixture — must be rejected by validator; documents degraded handling |
| `fixtures/accessibility_preference/future_major_version.json` | **Negative** fixture — must be refused (higher MAJOR) |

Negative fixtures live in the same folder with an explicit `_expect_invalid` marker inside the
validator manifest (see `tools/validate_a11y_fixtures.py`), never silently skipped.

## 6. Out of scope

- Audio volume/mix (AI-08).
- Assist levels, hint frequency, undo depth (AI-03/AI-04 gameplay settings).
- Graphics quality tier / low-power mode (AI-11), although AI-11 may read `reduce_motion`.
- Language selection (AI-09 localization; the Settings UI hosts it but the value is not in this block).
