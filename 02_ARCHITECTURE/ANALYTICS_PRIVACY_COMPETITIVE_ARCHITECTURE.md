# CraftCube v7.1 — Analytics, Privacy & Competitive Integrity Architecture

## Scope
This architecture is optional for offline core gameplay but mandatory as a design consideration before leaderboards, telemetry or remote content are shipped.

## Telemetry principles
- Minimal collection.
- Purpose-bound events.
- Versioned event schemas.
- No sensitive content.
- No core gameplay dependency.
- Clear retention policy.
- Safe failure when analytics is unavailable.

## Competitive integrity
Scores must identify their trust level:
- Local
- Device-verified
- Server-verified

Use deterministic challenge definitions and legal-state validation. Never place signing secrets in the client.

## Remote content
Every remote content package must be versioned, integrity checked and reversible.
Broken optional content must fail closed without blocking offline core gameplay.

## Ownership
AI-12 owns transport/build/release integration. AI-10 owns validation. AI-11 owns runtime cost. AI-13 owns contracts/governance. Product/legal decisions remain human-approved.
