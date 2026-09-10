# Global Quality and Release Gates

## Gate A — Functional integrity
- core puzzle deterministic
- no progression blockers
- no soft-locks
- no save corruption
- no fatal scene transitions

## Gate B — UX
- first 60 seconds understandable
- touch targets reliable
- feedback coherent
- menus predictable
- localization safe
- reduced-motion option respected

## Gate C — Visual
- consistent art direction
- no placeholder assets in release
- no obvious UV/material errors
- VFX readability on mobile
- animation transitions clean

## Gate D — Audio
- no clipping
- no abrupt layer jumps
- music/SFX controls work
- important gameplay cues audible but not exhausting

## Gate E — Performance
- frame pacing stable on representative mid device
- low-end fallback works
- no repeated GC spikes in common loop
- memory remains within device budget
- thermal/battery behavior acceptable

## Gate F — Build
- clean clone build
- versioned artifact
- signed release outputs where applicable
- APK install/launch tested
- AAB upload validation tested

## Gate G — Store
- icon/screenshots/video finalized
- privacy/legal pages ready
- age/content declarations accurate
- metadata localized where planned
- no misleading IP claims

## Release candidate definition
A release candidate is a frozen artifact, not an active development branch. No feature changes after RC except release blockers through hotfix process.

## Required final artifacts
- `.apk`
- `.aab`
- checksum manifest
- release notes
- changelog
- build provenance
- QA report
- known issues
- rollback artifact


## Gate H — Narrative / Progression Integrity
- story beats trigger correctly and do not dead-end progression
- critical gameplay knowledge is not hidden behind lore text
- chapter replay does not corrupt narrative state
- item/equipment progression is understandable

## Gate I — Item / Equipment Integrity
- item/equipment definitions are valid and versioned
- equip/unequip/upgrades persist
- rewards cannot be duplicated through interruption/retry abuse
- equipment cannot bypass protected puzzle mastery rules

## Gate J — Discovery / World Memory
- discoveries persist correctly
- optional secrets cannot corrupt main progression
- world consequences are reproducible and save-safe
- migration preserves narrative/item/world states

## Gate K — World-class coherence
- first-session identity is clear
- story, puzzle and world reinforce each other
- important items are memorable and understandable
- no systemic bloat is required to enjoy core play
- accessibility/comfort settings work
- optional analytics/online/remote systems fail safely without blocking offline core

See `08_QA_RELEASE/WORLDCLASS_QA_EXPANSION.md` for expanded checks.
