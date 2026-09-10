# Contract-First Integration Rules

## Contract families
- Simulation API
- Runtime state DTOs
- Event bus IDs
- Content schemas
- Save schema
- Localization keys
- Asset IDs
- Audio cue IDs
- Analytics event names
- Build/environment contracts

## Example interface
```csharp
public interface IPuzzleEngine
{
    PuzzleState GetState();
    MoveResult Apply(Move move);
    IReadOnlyList<Move> GetLegalMoves();
    ReplaySnapshot GetReplaySnapshot();
}
```

## Consumer rule
Consumers code only against interfaces and DTOs. Implementations can change behind the interface without forcing every Track to rewrite.

## Schema rule
Serialized data must include schema version. Never deserialize unversioned live save data in production.

## Event rule
Events use stable IDs:
`game.bloom.started`
`game.bloom.completed`
`game.collapse.warning`
`game.collapse.applied`
`companion.ability.used`

## Asset rule
Every asset reference is ID-based. File paths may move without breaking content definitions.

## Integration test rule
A Contract Test Suite runs against:
1. Fake implementation
2. Real implementation
3. Representative content data

All three must satisfy the same behavior expectations.
