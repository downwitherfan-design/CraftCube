# Cross-Track Interaction Contracts

## State contract
Gameplay exposes a read-only presentation state for UI and audio. UI cannot mutate simulation state directly.

## Command contract
Input produces commands; Application layer validates/queues them; Domain executes them.

## Content contract
Biome/Creature/Chapter definitions are data, not hardcoded switch statements wherever possible.

## Error contract
Use stable typed failure reasons:
- InvalidMove
- LockedAxis
- ContentNotFound
- SaveMigrationFailed
- ServiceUnavailable
- BuildConfigurationError

## Compatibility
Consumers must tolerate additive fields when possible. Breaking schema changes require migration or MAJOR version bump.
