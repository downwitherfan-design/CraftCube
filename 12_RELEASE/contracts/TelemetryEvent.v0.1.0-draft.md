# Contract: TelemetryEvent

Registry row (per `06_CONTRACTS/CONTRACT_REGISTRY_TEMPLATE.md`):

- Contract ID: `TelemetryEvent`
- Owner: AI-12 (registered in `06_CONTRACTS/WORLDCLASS_CONTRACTS_V7_1.md` — VERIFIED). AI-12 owns the **envelope schema, transport and build-time configuration**. The *questions* telemetry must answer are AI-01's (V7.1 §10); privacy validation is AI-10's; runtime cost is AI-11's; the legal/privacy stance is a Human decision (V7.1 §17, RD-007).
- Version: `0.1.0`
- Status: **DRAFT** (not consumable until FROZEN/RELEASED)
- Consumers (registered): AI-01, AI-10, AI-11, AI-13
- Compatibility promise: additive-only within MAJOR; unknown envelope keys preserved and ignored by the sink; a sink MUST drop (and count) events whose `schema_version` MAJOR exceeds its own.
- Breaking-change policy: `01_GOVERNANCE/CHANGE_CONTROL_AND_DECISION_LOG.md`
- Test suite: `12_RELEASE/tools/validate_release_fixtures.py` (check `RG-017`)
- Fixture set: `12_RELEASE/fixtures/telemetry_event/*.json` (an event **catalogue** fixture — list of event definitions — plus negative cases)
- Migration required: NO (first version)
- Change decision ID: none yet (DRAFT)

Design source: `00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md` §10; `02_ARCHITECTURE/ANALYTICS_PRIVACY_COMPETITIVE_ARCHITECTURE.md` §Telemetry principles; `08_QA_RELEASE/WORLDCLASS_QA_EXPANSION.md` §Analytics QA; DD-015; PD-010; Direction Lock §9.1.

---

## 1. Semantics

Two artifacts share this contract:

1. **Event catalogue** (build-time, validated by `RG-017`): the closed list of event definitions a given build may emit. A build cannot emit an event that is not in its catalogue; the catalogue is stamped into the build and its digest is recorded in `BuildProvenance` (Phase 01 additive field, OI-BP-01 family).
2. **Event instance** (runtime): a single emitted record conforming to one catalogue definition.

Telemetry is **optional for core play** and **fails silently to the player** (never a dialog, never a block). Failure is not invisible to the team: the client keeps a local `dropped_events` counter per drop reason so a broken pipeline is detectable without hiding the defect.

## 2. Event catalogue schema

```json
{
  "schema": "TelemetryEventCatalogue",
  "schema_version": "0.1.0",
  "fixture_kind": "PRODUCTION",
  "catalogue_version": "0.1.0",
  "events": [
    {
      "event_id": "telemetry.onboarding.step_completed",
      "event_version": "0.1.0",
      "purpose": "onboarding_abandonment",
      "retention_class": "aggregate_90d",
      "owner_question": "AI-01",
      "fields": [
        { "name": "step_id", "type": "string_id", "required": true },
        { "name": "elapsed_ms", "type": "int", "required": true },
        { "name": "assist_level", "type": "int", "required": false }
      ]
    }
  ]
}
```

### Field rules — catalogue

| Field | Rule |
|---|---|
| `schema` | MUST equal `"TelemetryEventCatalogue"`. |
| `schema_version`, `catalogue_version` | semver. |
| `fixture_kind` | `PRODUCTION` \| `MOCK` (MOCK requires `_mock_notice`; `RG-010`). |
| `events[]` | MAY be empty (a build with telemetry OFF ships an empty catalogue). `event_id` unique within the catalogue. |
| `event_id` | matches `^telemetry\.[a-z][a-z0-9_]*\.[a-z][a-z0-9_]*$` (`telemetry.<domain>.<verb_or_noun>`, Direction Lock §11). Immutable once released. |
| `event_version` | semver. |
| `purpose` | enum, closed, each mapping to a V7.1 §10 product question: `onboarding_abandonment` \| `tutorial_error` \| `item_misunderstanding` \| `quest_abandonment` \| `biome_revisit` \| `performance_drop` \| `crash_diagnostic`. Adding a purpose = MINOR bump + AI-01 sign-off. |
| `retention_class` | enum: `session_only` \| `aggregate_90d` \| `diagnostic_30d`. Anything longer or user-level needs a Human privacy decision and a new class. |
| `owner_question` | `^AI-(0[1-9]|1[0-3])$` — the track whose product/engineering question this event answers. |
| `fields[]` | `name` matches `^[a-z][a-z0-9_]*$`, unique per event; `type` ∈ {`bool`,`int`,`float`,`string_id`,`enum`,`duration_ms`}; `required` boolean. **`string_id` means a stable content/system ID, never free text.** There is deliberately no `string` (free text) type. |

### Forbidden field names (hard reject, `RG-017` + `RG-011`)

Any field whose `name` contains, case-insensitively: `email`, `phone`, `name` (as whole word `name`, `first_name`, `last_name`, `username`, `display_name`), `address`, `ip`, `imei`, `mac`, `advertising_id`, `adid`, `idfa`, `gaid`, `location`, `lat`, `lon`, `gps`, `password`, `secret`, `token`, `chat`, `free_text`, `raw_text`. The list is a floor; AI-10 privacy QA may extend it.

Also forbidden: any field of type `string_id` whose name suggests player-authored content (`custom_`, `user_input`). Player-authored content is never telemetry (V7.1 §10 "Do not log raw sensitive user content").

## 3. Event instance envelope (runtime)

```json
{
  "schema": "TelemetryEvent",
  "schema_version": "0.1.0",
  "event_id": "telemetry.onboarding.step_completed",
  "event_version": "0.1.0",
  "session_id": "<opaque, rotates per app session, not persisted across sessions>",
  "sequence": 17,
  "client_time_utc": "2026-01-01T00:00:00Z",
  "build": { "app_version": "0.1.0-internal", "build_number": 1, "content_version": "0.1.0" },
  "payload": { "step_id": "onboarding.step.first_twist", "elapsed_ms": 4200 }
}
```

Rules: `session_id` is per-session and never a device or account identifier; `sequence` is monotonic within a session (lets the sink detect drops); `build` mirrors `BuildProvenance` fields so every event is attributable to a build; `payload` keys MUST be a subset of the catalogue `fields` with all `required` present and types matching. Unknown payload keys → event dropped at the client, `dropped_events.schema_mismatch++`.

## 4. Client behaviour (contract, not implementation)

| Condition | Required behaviour |
|---|---|
| `feature_flags.telemetry == false` | Emit is a compiled-out or no-op call. No queue, no network, no UI. |
| Player opted out (UX owned by AI-07; storage decision with AI-02 in Phase 01) | Same as flag OFF, decided at runtime; opt-out state itself is never sent. |
| Transport unavailable | Bounded local queue (size bound set by AI-11 in Phase 01). On overflow, drop oldest and `dropped_events.overflow++`. |
| Sink rejects event | `dropped_events.rejected++`; no retry storm (bounded backoff, AI-11 sets bounds). |
| Any telemetry failure | Never visible to the player; never affects save, progression or puzzle state. |

The `dropped_events` counters are local diagnostics, readable in the internal channel's debug surface; they are not themselves telemetry unless a catalogue event `telemetry.diagnostic.drop_summary` (purpose `crash_diagnostic`) is defined and approved.

## 5. Store/privacy linkage

The release pipeline derives data-safety declaration inputs from the **actual shipped catalogue** (Direction Lock §10). A catalogue containing any `retention_class` other than `session_only` while the human privacy decision (RD-007) is unrecorded → `RG-017` FAIL for `beta`/`production`. This keeps the declaration and the binary from contradicting each other.

## 6. Open items (Phase 01)

- OI-TE-01: initial event list — proposals from AI-01 (product questions), AI-10 (instrumentation), AI-11 (performance_drop); AI-12 validates and stamps. No event IDs are asserted as final in Phase 00; the fixture uses clearly MOCK examples.
- OI-TE-02: sink/vendor choice — deferred (RC-004); this contract is vendor-neutral by design.
- OI-TE-03: opt-out storage location — AI-07 + AI-02 (parallels `AccessibilityPreference` storage decision).
