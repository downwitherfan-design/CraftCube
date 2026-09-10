# Technical Blueprint

## Engine
Unity 6 + URP + Android target configured for current Google Play policy at release time.

## Layering
Presentation → Application → Domain/Simulation → Data → Platform Services

### Domain/Simulation
Pure C#; no UnityEngine references.
Modules:
- PuzzleTopology
- PuzzleState
- MoveEngine
- ScrambleGenerator
- Replay
- Vitality
- Bloom/Collapse
- Synergy
- Companion rules
- Difficulty model

### Presentation
- CubeView
- Sticker/TileView
- CreatureView
- EnvironmentView
- VFX controllers
- Camera rig
- Animation orchestration

### Data
- BiomeSpec
- CreatureSpec
- ChapterSpec
- EffectSpec
- CompanionSpec
- Localization keys
- Balance tables

### Services
- SaveService
- AnalyticsService
- DailySeedService
- LeaderboardService
- RemoteConfigService
- IAP/Entitlement abstraction

## Dependency rule
Domain must know nothing about Unity, Android, networking, input devices or UI.
Adapters live outside Domain.

## Determinism
Same seed + same move list + same ruleset version => same logical result.
Store `rulesetVersion` with replays and daily challenge results.

## Save design
Save contains:
- schemaVersion
- profileId
- chapterProgress
- collection state
- settings
- economy
- replay metadata when required

Save writes are atomic and migration-tested.

## Performance budgets
Baseline budgets are hypotheses until measured:
- Mid-tier Android: 60 FPS target
- Low-power mode: 30 FPS
- No input-to-feedback delay noticeable in normal play
- Memory ceiling defined per test device after profiling
- UI transitions should not allocate heavily per frame
- Asset bundles/chapter packs loaded on demand where practical

## Asset addressing
Every runtime asset has a stable ID and owner metadata. Use Addressables or the selected Unity content pipeline consistently; do not mix ad-hoc Resources usage with dynamic content without an explicit exception.

## UI architecture
Safe-area aware, resolution independent, state-driven, localization-ready, reduced-motion aware.

## Testing architecture
- Domain Unit Tests
- Property Tests
- Golden Replay Tests
- Content Validation Tests
- PlayMode Tests
- UI Smoke Tests
- Device Smoke Tests
- Build Verification
