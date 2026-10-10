# CraftCube — Engine & Build (Godot 4.x, Android-first)

| Field | Value |
|---|---|
| Status | ACTIVE — first playable Android slice builds and passes tests |
| Engine | **Godot 4.x stable** (pinned working version: **4.7.2-stable**, commit `ed1daf0bf`) |
| Language | **GDScript** (typed GDScript; no Mono/C#) |
| Target | **Android-first** (arm64-v8a), offline-capable, mobile-first UI |
| Renderer | `mobile` (Vulkan/GLES3 mobile; ETC2/ASTC textures) |
| Project root | `game/` |
| Supersedes | The Unity 6 + URP direction of `PD-025` (see "Migration" below) |

## 1. Authority and scope

The **Human Project Owner** issued an *engine change directive*: move the project to
**Godot 4.x stable + GDScript** and keep **Android-first** deployment as the primary
target, to avoid the Unity licence/CI dependency. This document records the technical
facts of that migration. The corresponding dated product-decision record (owned by
AI-01) is `01_PREPRODUCTION/PRODUCT/PRODUCT_DECISION_REGISTER.md` — this file only
describes *how the engine is used*, not the product decision itself.

## 2. Architecture (kept engine-independent where it matters)

```
game/
  project.godot            # config, mobile renderer, Android orientation
  export_presets.cfg        # Android export preset (arm64-v8a)
  icon.svg
  scenes/Main.tscn          # scene tree only (no game logic)
  scripts/
    domain/                 # PURE truth layer — no scene/UI/engine-node dependency
      cube_state.gd         #   NxN geometry, moves-as-permutations, solidity
      move_table.gd         #   named face turns -> (axis, layer, cw) primitives
      puzzle_engine.gd      #   rules, legal moves, deterministic scramble, solve predicate
      level_catalog.gd      #   Chapter 01 data (AI-03 IDs)
    game/                   # orchestration + persistence (RefCounted services)
      game_state.gd         #   progression (levels, discoveries, equipment, loadout)
      save_manager.gd       #   versioned JSON save/load (user://)
      story_content.gd      #   hooks, rewards, equipment, discovery text
      game_controller.gd    #   Node3D: binds domain <-> view <-> UI
      hud.gd                #   mobile HUD (touch-sized, accessibility toggle)
    presentation/           # view only
      cube_view.gd          #   procedural 3D cube (primitive meshes, no assets)
      world_view.gd         #   procedural world-reaction markers
  tests/run_tests.gd        # headless test runner (exit 0/1)
  ci/build_android.sh       # import -> test -> smoke boot -> export APK
  docs/evidence/            # captured run logs
```

The `domain/` layer is deliberately engine-light: it uses only `RefCounted`,
`Vector3i`, and basic math, and is covered by headless tests. This preserves the
original architecture rule ("the simulation is engine-independent") even though the
engine itself changed.

## 3. Determinism contract

- A scramble is `f(seed, depth, level_rules)` and produces the **same** configuration
  on every run (verified by a test comparing two engines with the same seed).
- A scramble never leaves the level already solved, and every scramble is proven
  solvable by replaying it in reverse (test: `verify_scramble_solvable`).
- Move legality comes only from a level's `level_rules`; rules change *what is legal*,
  never *what is true* about the cube.

## 4. Pinned versions and why

| Component | Pinned value | Notes |
|---|---|---|
| Godot | 4.7.2-stable | Latest stable at time of writing; `godot --version` => `4.7.2.stable.official.ed1daf0bf` |
| Export templates | 4.7.2-stable | `~/.local/share/godot/export_templates/4.7.2.stable/` |
| Android build-tools | 34.0.0 | provides `apksigner`/`aapt2` used by the exporter |
| Android platform | android-34 | installed platform |
| JDK | 21 | required by Godot's Android export and `keytool` |
| APK | package `com.downwitherfandesign.craftcube`, minSdk 24, arm64-v8a | debug, signed with the local debug keystore |

The **project** deliberately does not hard-code a numeric engine version in product
documents; the version above is an engineering pin, recorded here and in CI.

## 5. Reproducing the build

```bash
# 1. engine (Linux x86_64 example)
curl -L -o godot.zip \
  https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip
unzip godot.zip -d /opt/godot && chmod +x /opt/godot/Godot_*

# 2. export templates (required for any export)
#    download Godot_v4.7.2-stable_export_templates.tpz and unzip into
#    ~/.local/share/godot/export_templates/4.7.2.stable/

# 3. Android SDK + JDK, then point Godot at them (Editor Settings, or edit
#    ~/.config/godot/editor_settings-4.7.tres):
#      export/android/java_sdk_path = "<JDK 21 path>"
#      export/android/android_sdk_path = "<Android SDK path>"

# 4. build + test
bash game/ci/build_android.sh
```

## 6. Verification evidence

| Check | Command | Result |
|---|---|---|
| Unit tests | `godot --headless --path game --script res://tests/run_tests.gd` | **166 passed, 0 failed** |
| Scene smoke boot | `godot --headless --path game --quit-after 30` | clean, no errors |
| Android export | `godot --headless --path game --export-debug Android dist/CraftCube.apk` | **signed APK produced (~27 MB)** |
| Full CI | `bash game/ci/build_android.sh` | **PASS** |

Logs: `game/docs/evidence/{unit_tests_run,main_scene_boot,android_export_run}.log`.

## 6a. Generated artifact (debug)

| Field | Value |
|---|---|
| Path | `dist/CraftCube.apk` (gitignored build output) |
| Size | 28,338,657 bytes (~27.0 MB) |
| SHA-256 | `0ebcefbbca3cfbcd5a0b2a2ade25e03229037846a4ce34ed874126138b025ab9` |
| Package | `com.downwitherfandesign.craftcube` |
| Version | name `0.1.0`, code `1` |
| min / target SDK | 24 / 36 |
| ABI | arm64-v8a only |
| Signer | `CN=Android Debug, O=Android, C=US` (local throwaway debug keystore; not committed) |

The checksum changes on every rebuild (APK timestamps/signing), so treat it as an
artifact fingerprint, not a reproducible-input hash. **This APK was built by CI on the
hardened commit; it has not been run on a physical device in this environment.**

## 7. Known limitation — not a store release

The APK is a **debug** build signed with a throwaway local keystore. A store-ready
build needs the owner's **release keystore** and the project's Google Play signing
custody. The export *pipeline* is proven; the *signed release* is an owner-gated step.

The app has not been run on a physical Android device in this environment (no device
attached). The headless tests and the successful export are the available evidence.
