# CraftCube v7 — Narrative / Equipment / World Architecture

## Ownership boundaries

AI-02: deterministic domain state and state transitions.
AI-03: puzzle/content rules.
AI-04: runtime use/interactions.
AI-05: world presentation.
AI-06: companion/creature presentation.
AI-07: player-facing UX.
AI-08: audio events.
AI-09: narrative meaning and content.
AI-10: validation.
AI-11: performance.
AI-13: integration.

## Data flow

`PuzzleState -> WorldStateEvent -> Narrative/Discovery State -> Reward -> Item/Equipment State -> Capability Query -> Future Content`

## Rules

- Domain state must remain deterministic.
- Narrative content must not directly own runtime implementation.
- Equipment definitions must be data-driven.
- Effects must expose stable IDs and explicit conditions.
- UI consumes state and commands; it does not redefine game rules.
- Save serialization is versioned.

## Capability model

A capability answers:

`CanPlayerInteractWith(target, state, loadout)?`

It should not directly hard-code UI or story text.

## Equipment effect model

Use composable effect definitions with:
- ID,
- trigger,
- condition,
- effect type,
- parameters,
- cooldown/charge if applicable,
- telemetry/debug label.

No effect should be allowed to mutate puzzle truth outside the contract.

## Narrative event model

Narrative events should provide:
- event ID,
- prerequisites,
- presentation payload,
- state changes,
- reward reference,
- localization references.

## Integration strategy

Every cross-domain feature ships first with fixtures and a mock path.
