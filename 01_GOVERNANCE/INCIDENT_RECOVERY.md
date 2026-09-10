# Incident Recovery

Use this for broken integration, corrupted builds, unexpected data changes or release blockers.

## Incident flow
DETECT → FREEZE RISKY CHANGES → REPRODUCE → CLASSIFY → ASSIGN OWNER → PATCH MINIMALLY → REGRESSION TEST → DOCUMENT → RESUME

Keep the last known-good integration artifact. Never destroy the only reproducible build or migration fixture.
