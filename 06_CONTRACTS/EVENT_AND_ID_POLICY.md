# Event and ID Policy

## Stable IDs
IDs are semantic identifiers, not filenames. Once released they are immutable.

## New IDs
Before creation: search repository → verify absent → assign canonical owner → record meaning → add consumer/producer tests.

## Events
Events should document producer, payload schema, ordering expectations, delivery guarantees, and whether duplication is possible.

## Collision prevention
CI should fail on duplicate canonical IDs where deterministic registry validation is possible.
