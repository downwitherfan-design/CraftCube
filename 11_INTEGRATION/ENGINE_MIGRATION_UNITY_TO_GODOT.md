# Engine Migration — Unity 6 + URP → Godot 4.x (AI-13 record)

| Field | Value |
|---|---|
| Owner | AI-13 — Integration / Technical Production |
| Document ID | `CC.INTEGRATION.ENGINE_MIGRATION` |
| Status | **ACTIVE RECORD** — directive executed; product-register update **RESOLVED** by `PD-030` (AI-01, PR #12; CR-0013) |
| Supersedes (technical) | The Unity-specific *technical* execution of `PD-025`; the `PD-025` record itself is AI-01-owned and is **not** rewritten here |
| Evidence | `game/docs/ENGINE_AND_BUILD.md`, `game/docs/evidence/*.log` |

## 1. Directive

The **Human Project Owner** issued an official engine-change directive: move CraftCube
off Unity and onto **Godot 4.x stable + GDScript**, keeping **Android-first,
offline-capable** deployment. Rationale: remove the Unity licence/CI dependency and
produce a genuinely runnable build now.

## 2. What changed

| Area | Before (`PD-025`) | After (this directive) |
|---|---|---|
| Engine | Unity 6 + URP | **Godot 4.7.2-stable** (pinned working version) |
| Language | C# (Domain/Simulation "pure C#") | **GDScript** (typed) |
| Renderer | URP | **`mobile`** (Vulkan/GLES3 mobile) |
| Android build | Unity + Gradle | **Godot export preset** → signed APK |
| CI/build env | Unity licence custody (owner-gated) | **Free toolchain** (Godot + export templates + Android SDK + JDK) |
| Dependency rule | Domain assembly with zero `UnityEngine` refs | `game/scripts/domain/` uses only engine-light primitives; covered by headless tests |

The architecture principle survived the change: the simulation stays a thin,
engine-independent layer (`domain/`), with `game/` orchestration and `presentation/`
views separated from it.

## 3. What was actually built and verified (VERIFIED)

- A real Godot project: `game/project.godot`, `scenes/Main.tscn`, 11 GDScript classes.
- Deterministic NxN twisting-puzzle domain (geometry-derived move permutations,
  seeded scrambles, solve predicate, reverse-replay solvability proof).
- Playable Chapter 01 vertical slice (3 levels from AI-03's draft fixture) with
  progression, versioned save/load, world reaction, a reward + equipment grant,
  and one optional discovery.
- Mobile-first HUD (touch-sized controls, large-text accessibility toggle).
- Headless test suite: **166 passed / 0 failed** (`game/docs/evidence/unit_tests_run.log`), including a real-scene integration test, a deterministic scramble fuzz, and Chapter 01 rule-semantics regression tests.
- Clean main-scene headless boot (`main_scene_boot.log`).
- **Signed Android debug APK** built by the export pipeline:
  `com.downwitherfandesign.craftcube`, v0.1.0, minSdk 24, arm64-v8a
  (`game/docs/evidence/android_export_run.log`).
- `.github/workflows/craftcube-android.yml` drives the same pipeline in CI.

## 4. Explicit limitations (no over-claiming)

- The APK is a **debug** build signed with a throwaway local keystore. A store-ready
  release needs the owner's **release keystore / Play signing** — an owner-gated step
  still open (see `PD-029`; the signing-custody item is now Godot-scoped, not Unity).
- **No physical Android device** was available; no on-device run is claimed. Evidence
  is headless tests + a successful export.
- `PD-025`'s numeric-version ban and `PD-029` items 4–5 referenced **Unity**. This is now
  **RESOLVED**: AI-01 recorded **`PD-030`** (Godot 4.x + GDScript + Android-first), which
  supersedes `PD-025` and restates `PD-029` items 4–5 engine-neutrally (PR #12, branch
  `ai-01-product-godot`). `validate_product_lock.py` now checks the Godot decision; no
  numeric toolchain version is pinned in product documents.

## 5. Obligations created downstream

- **AI-01:** record the superseding product decision (Godot 4.x) in the PD register and
  restate `PD-029` items 4–5 engine-neutrally. CR-0013.
- **AI-02 / AI-12:** the architecture/build documents (C# domain, Unity RD-004, Unity
  licence custody) need a Godot-scoped revision. `game/docs/ENGINE_AND_BUILD.md` already
  defines the Godot project layout and pinned versions and can seed those revisions.
- **AI-10:** adopt `game/tests/run_tests.gd` + `game/ci/build_android.sh` as the
  measurable-build evidence source for the gate's `[BUILD]` rows.
- **AI-03:** the three Chapter 01 levels below are bound to authored draft rules; one
  draft rule (`axis_lock {X,Z}` + `align {U}`) is degenerate and was minimally changed
  for playability — needs AI-03 confirmation.

## 6. Chapter 01 level-binding note (needs AI-03 confirmation)

`game/scripts/domain/level_catalog.gd` binds `level.01.awaken`, `level.01.seed_bed` and
`level.01.hollow_stone` to the engine. The draft fixture's
`rule.axis_lock {axes:[X,Z]}` makes the `align {U}` objective true before the player
moves (locking X/Z leaves only U/D turns, which never disturb the U face), so those
levels were unplayable as authored. The binding instead uses **no axis lock** for the
first two levels and a **Y-axis lock** for the third. Objective families and IDs are
unchanged. AI-03 should confirm or supply replacement rules.
