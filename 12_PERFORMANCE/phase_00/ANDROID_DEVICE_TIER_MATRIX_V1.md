# CraftCube — Android Device Tier Matrix v1.0.0 (Phase 00) — AI-11

| Field | Value |
|---|---|
| Owner | AI-11 |
| Document ID | `CC.PERF.DEVICE_MATRIX` |
| Version | 1.0.0 |
| Status | READY_FOR_REVIEW — **definitions only; zero devices measured** |
| Supersedes | nothing. `08_QA_RELEASE/DEVICE_MATRIX_TEMPLATE.csv` remains as the QA template it is; this document defines the *tiers* that template's `DeviceTier` column refers to. AI-11 does not edit that file (see `C11-01`). |

## 1. Why there are no device names in this document

A device matrix with model names implies those models were chosen for a reason and, eventually,
measured. At commit `584141c` the repository contains no engine project, no build and no
measurement. Listing "Device X = Low tier" would therefore be an invented repository fact
(`ANTI_HALLUCINATION_ADDENDUM.md`: never invent device results).

Instead, Phase 00 locks **what makes a device Low, Mid or High** — a capability classification that
a real device is sorted into *after* it is measured with the standard in
`MEASUREMENT_METHOD_STANDARD.md`. Named devices enter this matrix in Phase 02 (first build) at the
earliest, each with a measurement record.

## 2. Tier definitions (capability classes)

Each tier is defined by **three** things: a hardware-class description (to pick candidate devices),
a **classification test** (to sort a real device once measured), and the **quality tier** it maps to
by default.

| Device tier | Hardware class (guidance for choosing candidates) | Classification test (MEASURED, decides the tier) | Default quality tier | Product role |
|---|---|---|---|---|
| **`low`** | Entry-level SoC (few performance cores or all efficiency cores), 2–4 GB RAM, 60 Hz panel, often ≤ 1080p, Android version `latest-2` or older still in market support. Frequently OEM-skinned with aggressive background kill. | Running the **reference scene** (§4) at quality `low`: frame-time p95 ≤ 33.3 ms **and** resident memory ≤ 350 MB **and** cold start ≤ 5 s. A device that **fails** these at quality `low` is **below minimum spec** and is recorded as `unsupported`, not as a new tier. | `low` | The floor. Bible §13 "performant across Android tiers" is proven here first. AI-01 `IGM-006b` is measured here. |
| **`mid`** | Mainstream SoC with dedicated performance cores, 4–8 GB RAM, 60–120 Hz panel, 1080p-class. Android `latest-1`. The volume segment. | Reference scene at quality `mid`: frame-time p95 ≤ 16.7 ms **and** resident memory ≤ 600 MB **and** cold start ≤ 3 s. A device that passes `low` classification but fails `mid` is `low`. | `mid` | The default authoring target. Blueprint "60 FPS mid-tier" lives here. Investment Gate mobile feasibility is judged here and on `low`. |
| **`high`** | Flagship-class SoC, ≥ 8 GB RAM, 120 Hz panel, 1080p–1440p-class, Android `latest`. | Reference scene at quality `high`: frame-time p95 ≤ 16.7 ms at native resolution with all `high` tunables **and** p99 ≤ 20 ms **and** thermal capture (`PERF-020`) shows no downgrade in 30 minutes. | `high` | Proves the presentation ceiling and thermal behaviour under maximum load. Never the authoring target. |

### 2.1 Layout classes are not tiers

`Tablet` in `08_QA_RELEASE/DEVICE_MATRIX_TEMPLATE.csv` is a **layout/ergonomics class** (owner AI-07
for layout; AI-01 marks tablet/landscape as LATER scope). A tablet is classified into `low`/`mid`/
`high` exactly like a phone for performance purposes. AI-11 keeps `PERF-033` at three quality tiers
and does not add a tablet quality tier.

### 2.2 Foldables, high-refresh and unusual aspect ratios

Classified by the same tests. Refresh rate does **not** change the tier; it changes only the
`high` target (8.3 ms p95 target on 120 Hz, `PERF-001`). Safe-area/cutout handling is AI-07's
concern; AI-11 only requires that render-resolution scaling (`PERF-019`) respects the safe area
(no resolution scale applied to UI).

## 3. Minimum specification (what "unsupported" means)

AI-11 does **not** set the minimum Android API level or minimum RAM in Phase 00 — that is a store
policy + audience decision (`U11-01`, `PERFORMANCE_PRODUCT_LOCK_AI11.md` §8). What AI-11 locks is the
**rule**:

> A device is *supported* if and only if it passes the `low` classification test at quality `low`
> with the release build. There is no "below-low" quality tier. Content is never removed to fit a
> device.

This protects PP-5 (Low tier is a first-class player) and prevents an unbounded tail of
compatibility work.

## 4. Reference scene (what gets measured)

Every classification and every `PERF-###` measurement runs the **same** scene set so numbers are
comparable across devices and over time. The scenes are defined by *content role*, not by asset
name, because no assets exist yet. AI-10 owns the automation harness; AI-11 owns the scene definition
and the pass criteria.

| Scene ID | Content | Window | Budgets exercised |
|---|---|---|---|
| `perf.scene.boot` | Cold start from launcher to first accepted touch on title/continue. | Single event | `PERF-023`, `PERF-025` (artifact size, AI-12) |
| `perf.scene.load_chapter` | Continue → Hearthwild (Gold Slice biome per AI-05) → first accepted puzzle touch. | Single event | `PERF-024` |
| `perf.scene.puzzle_idle` | Cube in view, HUD visible, Nox present and idle, no transition. 60 s steady state after 5 s warm-up. | 60 s | `PERF-001`, `PERF-002`, `PERF-010`, `PERF-012`, `PERF-013`, `PERF-015` |
| `perf.scene.puzzle_twist_loop` | Scripted sequence of legal twists at a fixed cadence (deterministic move list, AI-02 replay), 120 s. | 120 s | `PERF-001`, `PERF-002`, `PERF-004`, `PERF-005`, `PERF-007`, `PERF-008`, `PERF-012`, `PERF-017` |
| `perf.scene.world_transition` | Solve → biome transformation tier 0→1 VFX + Reaction Framing camera + Nox reaction. Captured from solve confirm to input unlock. | Single event, repeated 5× | `PERF-003`, `PERF-009`, `PERF-016`, `PERF-018` |
| `perf.scene.inventory` | Open loadout UI, equip/unequip one item, close. Repeated 10×. | 10 events | `PERF-013`, `PERF-029` |
| `perf.scene.save_reload` | Trigger save, background app, foreground, verify identical state (state check is AI-10's). | Single event | `PERF-026`, `PERF-014` |
| `perf.scene.soak_30` | Loop `puzzle_twist_loop` + `world_transition` for 30 minutes at fixed screen brightness. | 30 min | `PERF-020`, `PERF-021`, `PERF-022` |

Scene IDs use the `perf.scene.*` namespace. Search over all branches for `perf.` found no existing
namespace; it is **proposed** for registration with AI-13 event/ID governance in Phase 01
(`IR-AI11-005`), not released.

## 5. Matrix record format (what a measured device row looks like)

When a device is measured, it is added to `12_PERFORMANCE/devices/` as one JSON record (Phase 02+).
The **shape** is locked now so AI-10/AI-12 can build harness output against it:

```json
{
  "schema": "DeviceRecord",
  "schema_version": "0.1.0",
  "device_id": "dev.<anonymised-stable-id>",
  "model_marketing_name": "UNKNOWN until measured",
  "soc_class": "low | mid | high (guidance only)",
  "ram_gb": 0,
  "panel": {"refresh_hz": 60, "resolution": "0x0"},
  "android_version": "0",
  "android_api": 0,
  "classified_tier": "low | mid | high | unsupported",
  "classified_by": {
    "build_id": "UNKNOWN",
    "scene_results": [],
    "evidence_path": "12_PERFORMANCE/evidence/<build_id>/<device_id>/",
    "method_version": "MEASUREMENT_METHOD_STANDARD 1.0.0",
    "date": "YYYY-MM-DD"
  }
}
```

No such record exists yet. The folder `12_PERFORMANCE/devices/` is intentionally **not** created in
Phase 00 so that its absence is itself evidence that nothing has been measured.

## 6. How many devices (target lab size — a plan, not a fact)

| Tier | Minimum devices for Phase 06 Gold Slice gate | Minimum for Phase 12 Device Lab | Rationale |
|---|---|---|---|
| `low` | 2 | 3 | Two different SoC vendors/OEM skins to avoid a single-device fluke; the Investment Gate is decided here. |
| `mid` | 2 | 4 | Include one 120 Hz and one 60 Hz panel. |
| `high` | 1 | 2 | Thermal ceiling and presentation ceiling. |

If the lab has fewer devices than the Phase 06 minimum, the gate result for `IGM-006b` is
`UNDERPOWERED` (AI-01's own term), never `PASS`.

## 7. Cross-track consequences

- **AI-10**: harness must emit the §5 record shape and the §4 scene IDs; pass/fail per `PERF-###`.
- **AI-12**: every build must expose a stable `build_id` retrievable at runtime and in the artifact
  manifest, or no measurement can be attributed (`IR-AI11-002`).
- **AI-04**: `perf.scene.puzzle_twist_loop` needs a deterministic scripted move list driven through
  the same Command path as touch, so latency can be measured without a human finger. AI-04 already
  requires replayable arbiter input; AI-11 requests it be exposed to the harness (`IR-AI11-006`).
- **AI-05 / AI-06**: `perf.scene.world_transition` requires the Hearthwild tier 0→1 transition and
  one Nox reaction to exist in the slice; both are already Gold Slice content in their Phase 00 docs.

## 8. Known limitations

- Hardware-class descriptions in §2 are **guidance for choosing candidates**, based on general
  Android market structure, not on a market survey stored in the repository. They are ASSUMED and
  are not used to classify; only the measured test classifies.
- No minimum API level → no definitive "unsupported" boundary yet (`U11-01`).
- Emulators are **not** valid classification devices; they may be used for functional smoke only.
