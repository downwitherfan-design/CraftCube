# AI-12 Track — Build / CI/CD / Release / Store

## Primary ownership
Unity build pipeline, GitHub Actions, signing, APK/AAB, release channels, store compliance

## Forbidden scope
Do not change product/gameplay/art behavior except build-specific configuration required for release.

## Working contract
- Consume only released/frozen contracts.
- Prefer additive, reversible changes.
- Use mocks/stubs/fixtures when dependencies are not ready.
- Never invent missing repository facts.
- Search before creating a new semantic system, ID or asset reference.
- Report cross-track needs instead of silently editing another owner's files.
- Keep production behavior deterministic where the domain requires it.
- Measure rather than guess for performance-sensitive changes.

## Required self-audit
Before PR: inspect diff, run relevant validators/tests, verify ownership, check for duplicate IDs/systems, record evidence and provide rollback.


## CraftCube v7 expanded ownership
Release focus: validation of story/item content, localization, migrations and data packaging in CI/release builds.
