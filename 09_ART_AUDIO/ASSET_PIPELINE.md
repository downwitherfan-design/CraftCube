# Asset Pipeline

## Naming
`<type>_<system>_<semantic>_<variant>_<lod/version>`

Example:
`vfx_bloom_meadow_a_v01`

## Required metadata
- assetId
- type
- owner
- source
- license
- version
- target platform
- memory estimate
- dependencies

## Art workflow
Concept → blockout → style approval → low-poly/mobile mesh → texture/material → animation → VFX integration → optimization → final QA.

## Audio workflow
Reference → cue design → dry asset → mix → adaptive layer mapping → mobile compression/format → integration → QA.

## No placeholder leakage
Placeholders are allowed only in development and must be mechanically detectable before release.
