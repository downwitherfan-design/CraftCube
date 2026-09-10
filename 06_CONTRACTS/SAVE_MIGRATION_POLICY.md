# Save & Migration Policy

Every production save schema has an explicit version.

Rules:
- never silently deserialize a newer save with an older reader;
- keep representative fixtures for every released schema;
- migrations must be deterministic and idempotent where practical;
- test corrupted, truncated, missing-field and future-version cases;
- retain rollback/recovery guidance;
- delete/rename fields only through a documented migration.
