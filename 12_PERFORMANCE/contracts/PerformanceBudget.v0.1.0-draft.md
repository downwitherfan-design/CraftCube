# Contract: PerformanceBudget

Registry row (per `06_CONTRACTS/CONTRACT_REGISTRY_TEMPLATE.md`):

- Contract ID: `PerformanceBudget`
- Owner: AI-11 (registered in `06_CONTRACTS/V7_MASTER_CONTRACT_REGISTER.md`, row "PerformanceBudget | AI-11 | all runtime tracks")
- Version: `0.1.0`
- Status: **DRAFT** — not consumable as a released contract until FROZEN in Phase 01. Tracks may design against the fixture now as a labelled hypothesis.
- Consumers (registered): all runtime tracks (AI-02, AI-03, AI-04, AI-05, AI-06, AI-07, AI-08, AI-09, AI-10, AI-12, AI-13)
- Compatibility promise: additive-only within MAJOR 0.x → 1.x freeze; unknown keys preserved and ignored by readers; a missing per-tier value is a **validation error**, not a default (a budget with no number is not a budget).
- Breaking-change policy: per `01_GOVERNANCE/CHANGE_CONTROL_AND_DECISION_LOG.md`; any value change is recorded as `D-PERF-##` in `12_PERFORMANCE/phase_00/INTEGRATION_REQUESTS_AND_UNKNOWNS.md`.
- Test suite: `12_PERFORMANCE/tools/validate_performance_budget.py` (stdlib-only, deterministic).
- Fixture set: `12_PERFORMANCE/fixtures/performance_budget/*.json`
- Migration required: NO (first version)
- Change decision ID: none yet (DRAFT)

Design source: `12_PERFORMANCE/phase_00/PERFORMANCE_PRODUCT_LOCK_AI11.md` §4.

---

## 1. Semantics

`PerformanceBudget` is a **versioned, read-only table of per-tier ceilings** plus the evidence status
of each ceiling. It answers, for any runtime track: "what is the most I may cost on `low` / `mid` /
`high`, and has anyone actually measured it yet?"

It contains **no gameplay truth**. Nothing in the domain (AI-02) may read it. Changing any value must
never alter puzzle legality, scoring, progression, world memory or save content (PP-3).

Two things are deliberately **not** in this contract:

- The *current runtime quality tier* (a runtime state, to be defined in Phase 01/02 as a separate,
  tiny read-only state contract so presentation systems can query it — proposed name
  `QualityTierState`, not yet registered; see `IR-AI11-007`).
- Device records (separate `DeviceRecord` shape, `ANDROID_DEVICE_TIER_MATRIX_V1.md` §5).

## 2. Schema (JSON representation; engine-side DTO to mirror exactly)

```json
{
  "schema": "PerformanceBudget",
  "schema_version": "0.1.0",
  "budget_version": "0.1.0-hypothesis",
  "method_version": "1.0.0",
  "tiers": ["low", "mid", "high"],
  "entries": [
    {
      "id": "PERF-001",
      "category": "frame_time",
      "metric": "frame_time_p95_ms",
      "unit": "ms",
      "direction": "max",
      "scene_ids": ["perf.scene.puzzle_idle", "perf.scene.puzzle_twist_loop"],
      "gate": true,
      "values": {"low": 33.3, "mid": 16.7, "high": 16.7},
      "status": "HYPOTHESIS",
      "rationale": "Blueprint 30/60 FPS hypotheses expressed as p95 ms.",
      "product_links": ["TECHNICAL_BLUEPRINT.md#performance-budgets"],
      "adopted_from": [],
      "evidence": []
    }
  ]
}
```

### 2.1 Top-level fields

| Field | Type | Required | Rules |
|---|---|---|---|
| `schema` | string | yes | Exactly `"PerformanceBudget"`. |
| `schema_version` | semver string | yes | `"0.1.0"` for this draft. |
| `budget_version` | string | yes | Version of the *numbers*; suffix `-hypothesis` while any gate entry is unmeasured. |
| `method_version` | semver string | yes | Version of `MEASUREMENT_METHOD_STANDARD.md` the evidence must follow. |
| `tiers` | array of string | yes | Exactly `["low","mid","high"]` in this order (PERF-033). |
| `entries` | array of Entry | yes | ≥ 1; IDs unique. |

### 2.2 Entry fields

| Field | Type | Required | Rules |
|---|---|---|---|
| `id` | string | yes | Matches `^PERF-[0-9]{3}$`; unique; immutable once released. |
| `category` | enum | yes | `frame_time`, `latency`, `memory`, `rendering`, `thermal`, `battery`, `load`, `system`, `complexity`. |
| `metric` | string | yes | One of the metric names in `MEASUREMENT_METHOD_STANDARD.md` §3, or `method_only` for thermal/battery rows without a numeric ceiling yet, or `count` for complexity rows. |
| `unit` | string | yes | `ms`, `MB`, `KB`, `B/frame`, `count`, `ratio`, `pct`, `none`. |
| `direction` | enum | yes | `max` (value is a ceiling) or `min` (value is a floor) or `exact` (must equal, e.g. 0 B/frame). |
| `scene_ids` | array of string | yes | Each matches `^perf\.scene\.[a-z0-9_]+$`. May be empty only for `category: complexity`. |
| `gate` | bool | yes | `true` if this entry participates in "tier supported" claims (`MEASUREMENT_METHOD_STANDARD.md` §6). |
| `values` | object | yes | Keys are exactly the `tiers`; each value is a number, or the string `"method_only"` for rows whose numeric ceiling is deliberately deferred (thermal/battery), or a two-element `[min,max]` array for range tunables (`PERF-019`). Missing key → error. |
| `status` | enum | yes | `HYPOTHESIS` or `MEASURED`. `MEASURED` **requires** `evidence` to be non-empty and every evidence item to be complete (§2.3). |
| `rationale` | string | yes | Non-empty. |
| `product_links` | array of string | yes | ≥ 1 reference to a repository document/ID that motivates the ceiling. |
| `adopted_from` | array of string | no | Sibling-track IDs whose value this entry adopts verbatim (e.g. `AI-07:UXM-11`). Provenance, so the origin track can see its hypothesis was honoured. |
| `evidence` | array of Evidence | yes | May be empty **only** when `status == HYPOTHESIS`. |

### 2.3 Evidence item fields (mirrors `MEASUREMENT_METHOD_STANDARD.md` §2)

Required: `scene_id`, `device_id`, `device_tier`, `quality_tier`, `build_id` (≠ `"UNKNOWN"`),
`os_version`, `method_version`, `tool`, `window_s`, `value`, `result` (`PASS`|`FAIL`),
`artifact_path`, `captured_by`, `date`. Optional: `thermal_state_start`, `thermal_state_end`,
`battery_start_pct`, `battery_end_pct`, `screen_brightness`, `notes`.

## 3. Reader rules

- A reader encountering a **higher MAJOR** `schema_version` must refuse and surface a development
  error; it must not fall back to hard-coded numbers silently (no silent fallbacks).
- A reader must treat `status: HYPOTHESIS` as "design constraint, not evidence" and must not present
  such a number to a human as a measured result.
- The domain layer (AI-02) must not have a reader at all.

## 4. Change event

None in this version. The budget is static data loaded at build time. If a runtime quality-tier
change event is needed it belongs to the future `QualityTierState` contract (`IR-AI11-007`), not here.

## 5. Fixtures

| File | Purpose |
|---|---|
| `fixtures/performance_budget/budget_hypothesis_v0.json` | The complete `PERF-001..035` table from the Product Lock, all `HYPOTHESIS`, no evidence. Golden positive fixture. |
| `fixtures/performance_budget/_expect_invalid/measured_without_evidence.json` | **Negative** — one entry claims `MEASURED` with empty `evidence`. Validator must reject. |
| `fixtures/performance_budget/_expect_invalid/missing_tier_value.json` | **Negative** — one entry lacks the `high` value. Validator must reject (no defaults for budgets). |
| `fixtures/performance_budget/_expect_invalid/duplicate_id.json` | **Negative** — two entries share `PERF-001`. Validator must reject. |
| `fixtures/performance_budget/_expect_invalid/unknown_build_id.json` | **Negative** — `MEASURED` entry whose evidence has `build_id: "UNKNOWN"`. Validator must reject. |

Negative fixtures live under `_expect_invalid/` and the validator requires each of them to **fail**;
a negative fixture that passes is itself a validator failure (never silently skipped).

## 6. ID governance

- `PERF-###` stem: searched over all 14 remote branches at `origin/*` via `git grep`; absent →
  assigned to AI-11. Requested for registration in AI-13's ID registry (`IR-AI11-005`).
- `perf.scene.*` namespace: same search; absent → proposed (`IR-AI11-005`). Existing dotted IDs in
  the repo are `game.bloom.*`, `game.collapse.*`, `companion.ability.used` (VERIFIED in
  `06_CONTRACTS/CONTRACT_FIRST_RULES.md`) and AI-07's proposed `ux.accessibility.changed`.

## 7. Out of scope

- Audio voice/memory budgets (deferred to Phase 01 pending AI-08's cue list; will be added as
  `PERF-036+` entries, additive).
- Network/remote budgets (no online core; any optional service budget is Phase 13).
- Asset-level metadata `memory estimate` (owned by `09_ART_AUDIO/ASSET_PIPELINE.md` per asset; this
  contract sets the *ceiling* those estimates must sum under).
