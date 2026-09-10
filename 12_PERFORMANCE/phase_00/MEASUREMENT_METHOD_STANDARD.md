# CraftCube — Performance Measurement Method Standard v1.0.0 — AI-11

| Field | Value |
|---|---|
| Owner | AI-11 |
| Document ID | `CC.PERF.METHOD` |
| Version | 1.0.0 |
| Status | READY_FOR_REVIEW |
| Extends | `08_QA_RELEASE/EVIDENCE_STANDARD.md` ("Performance claim → profiler metric, scene/content, device and measurement method") |

## 1. Purpose

`EVIDENCE_STANDARD.md` says a performance claim needs a metric, scene, device and method. This
document fixes **which** metric, **which** scene, **which** device fields and **which** method, so
two people measuring the same build on the same device produce comparable numbers, and so a
reviewer can reject a claim that is missing any part.

A number that does not follow this standard is a **note**, not evidence, and may not change any
`PERF-###` status from `HYPOTHESIS` to `MEASURED`.

## 2. The evidence record (minimum fields)

Every measurement produces one record. Missing any `required` field → the validator rejects it.

| Field | Required | Content |
|---|---|---|
| `perf_id` | yes | The `PERF-###` being measured. |
| `scene_id` | yes | One of the `perf.scene.*` IDs in `ANDROID_DEVICE_TIER_MATRIX_V1.md` §4. |
| `device_id` | yes | Stable anonymised ID from the device record (§5 of the matrix doc). |
| `device_tier` | yes | `low` / `mid` / `high` (classified, not guessed). |
| `quality_tier` | yes | The quality tier the build was running. |
| `build_id` | yes | Build identifier exposed by AI-12's pipeline. `UNKNOWN` is not accepted. |
| `os_version` | yes | Android version string and API level. |
| `method_version` | yes | This document's version. |
| `tool` | yes | Profiler/tool and version used (see §4 — must be one of the approved classes; the exact tool version is recorded, never assumed). |
| `window` | yes | Capture window in seconds, and warm-up excluded. |
| `metric` | yes | Name and unit, e.g. `frame_time_p95_ms`. |
| `value` | yes | Number. |
| `result` | yes | `PASS` / `FAIL` against the fixture ceiling for that tier. Computed, not typed by hand. |
| `artifact_path` | yes | Repository-relative path to the raw capture (trace/log/CSV) or the location where it is archived if too large for git. |
| `captured_by` | yes | Account (`AI-11`, `AI-10`, human name/role). |
| `date` | yes | ISO date. |
| `thermal_state_start` / `_end` | for `soak_30` | Platform thermal status at capture start and end. |
| `battery_start_pct` / `_end_pct` | for `soak_30` | Battery percentage. |
| `screen_brightness` | for `soak_30` | Fixed value used. |
| `notes` | no | Anything that could bias the reading (charger connected, background apps, dev overlay enabled). |

## 3. Metric definitions (so nobody argues about what "p95" means)

| Metric | Definition | Unit |
|---|---|---|
| `frame_time_pNN_ms` | The NN-th percentile of per-frame **presentation interval** (time between consecutive frames reaching the display, as reported by the platform frame-timing source), over the window, warm-up excluded. Percentile is computed on the raw sample list, nearest-rank method. | ms |
| `hitch_count` | Number of frames in the window whose presentation interval exceeds the tier's `PERF-004` bound. | count |
| `max_frame_ms` | Largest single presentation interval in the window. | ms |
| `touch_to_visual_ms` | Time from the OS touch-down event timestamp to the first frame that presents a pixel change attributable to that touch. Primary method: platform frame-timing + instrumented marker written by the runtime at the first draw of the response. Secondary (calibration) method: external high-speed camera ≥ 240 fps filming screen and finger. | ms |
| `resident_memory_mb` | Process total resident memory as reported by the platform's per-process memory summary (the PSS-class total that includes native, graphics and managed), sampled every 1 s over the window; the **maximum** sample is the reported value. | MB |
| `texture_memory_mb` | Engine-reported texture memory for loaded assets at the checkpoint. | MB |
| `managed_alloc_bytes_per_frame` | Managed heap bytes allocated per frame, averaged over the window, warm-up excluded. Reported alongside the **maximum** single-frame allocation. | B/frame |
| `draw_calls` | Engine frame-debugger/profiler draw call count at a stable frame; median of 10 samples. | count |
| `cold_start_ms` | From launch intent to first accepted touch on an interactive screen. Measured by platform launch-time reporting plus a runtime marker at "input enabled". | ms |
| `load_ms` | From continue-tap to first accepted puzzle touch, runtime markers. | ms |
| `thermal_status_transitions` | Ordered list of platform thermal status values with timestamps during `soak_30`. | list |
| `battery_drain_pct_30min` | `battery_start_pct - battery_end_pct` over exactly 30 min at fixed brightness, charger disconnected. | % |
| `save_write_block_ms` | Time the render thread is blocked (no frame presented) attributable to a save write. Target is 0; measured as the largest presentation interval within ±500 ms of the save marker minus the window's p50. | ms |

## 4. Approved tool classes

AI-11 does not name a specific tool version here because none has been installed or verified in the
repository. The record must state the exact tool and version used. Approved **classes**:

1. Engine-integrated profiler (CPU/GPU/memory/allocations) — primary for allocations, draw calls,
   texture memory.
2. Platform frame-timing / system trace tooling — primary for frame-time percentiles and
   touch-to-visual, because it observes actual presentation, not engine-side estimates.
3. Platform per-process memory summary — primary for resident memory.
4. Platform thermal and battery status APIs / shell tooling — primary for `soak_30`.
5. External high-speed camera — calibration only for `touch_to_visual_ms`.

Engine-side "FPS counters" are **not** acceptable evidence for frame-time budgets.

## 5. Capture protocol (the procedure, step by step)

1. **Device prep**: release-configuration build (not editor, not a development-overlay-heavy build
   unless the overlay's cost is separately measured and subtracted); charger disconnected for
   `soak_30`; screen brightness fixed and recorded; airplane mode ON (offline core, DD-015 — also
   removes network jitter); no other foreground apps; device idle-cooled to the platform's lowest
   thermal status before start.
2. **Build identity**: read `build_id` from the running app and from the artifact manifest; both
   must match.
3. **Warm-up**: 5 s after the scene is reached; excluded from all windows.
4. **Scene execution**: run the scene by its ID; scripted scenes use the deterministic move list
   (AI-02 replay / AI-04 command path) so captures are repeatable.
5. **Repeat**: 3 runs per scene per device minimum; report the **median run** for percentiles and
   the **worst run** for hitch count and max frame. All three raw captures are archived.
6. **Compute** `result` against the fixture ceiling for the device's tier; never hand-type it.
7. **Record** using the §2 fields; run `tools/validate_performance_budget.py` on the updated fixture.
8. **Archive** raw artifacts under `12_PERFORMANCE/evidence/<build_id>/<device_id>/` (or the
   documented external archive if >5 MB, with hash recorded in the record).

## 6. What may and may not be claimed

| Claim | Allowed when |
|---|---|
| "PERF-001 PASS on `low`" | ≥ 2 classified `low` devices, ≥ 3 runs each, median p95 within ceiling, records validated. |
| "PERF-001 MEASURED" (status change) | At least one valid record exists, regardless of PASS/FAIL. |
| "Low tier is supported" | Every `PERF-###` marked `gate: true` in the fixture PASSES on the minimum device count of `ANDROID_DEVICE_TIER_MATRIX_V1.md` §6. |
| "No regression" | Same device, same scene, same method version, newer build; p95 and p99 not worse by more than the noise band established from the 3-run spread of the baseline. Widening the noise band to pass is forbidden (Test Integrity Rule). |
| "Optimisation improved X" | Before and after records on the same device/scene/method, both archived; behaviour-preservation test (AI-10) green on the after build. |

## 7. Development overlay (requirement, not implementation)

A development-only overlay must be able to show, at minimum: current quality tier, active fallback
reason (or `none`), frame-time p95 over the last 2 s, resident memory, thermal status. It must be
mechanically stripped from release builds (`ASSET_PIPELINE.md` "No placeholder leakage" applies to
debug UI as well). Owner of the implementation: AI-11 (runtime performance adapter) in Phase 02+,
consuming AI-07's HUD layer only for placement, never for logic.

## 8. Relationship to other tracks

- **AI-10** automates §5 and emits §2 records; AI-11 defines the pass criteria and reviews records.
- **AI-12** provides `build_id`, artifact size, and CI hooks that can run `perf.scene.boot` and
  `perf.scene.puzzle_idle` on a connected device where available; CI-run results are evidence only if
  the CI device is a classified device in the matrix.
- **AI-02 / AI-04** provide the deterministic scripted move path.
- **AI-01** consumes `PASS/FAIL/UNMEASURED/UNDERPOWERED` per `IGM-006b/e`.
