# Contract: RemoteContentManifest

Registry row (per `06_CONTRACTS/CONTRACT_REGISTRY_TEMPLATE.md`):

- Contract ID: `RemoteContentManifest`
- Owner: AI-12 (registered in `06_CONTRACTS/WORLDCLASS_CONTRACTS_V7_1.md` — VERIFIED)
- Version: `0.1.0`
- Status: **DRAFT** (not consumable until FROZEN/RELEASED). **Feature is OFF at v1** (`PRODUCT_LOCK_V1.md` §7.3 "Later"; Direction Lock RC-002). The contract exists now so Phase 13 does not invent one and so the rollback semantics are fixed before any content is remote.
- Consumers (registered): AI-02, AI-10, AI-11, AI-13
- Compatibility promise: additive-only within MAJOR; unknown keys preserved and ignored; a client MUST reject a manifest whose `schema_version` MAJOR exceeds its own and keep the current known-good content (fail closed — V7.1 §12).
- Breaking-change policy: `01_GOVERNANCE/CHANGE_CONTROL_AND_DECISION_LOG.md`
- Test suite: `12_RELEASE/tools/validate_release_fixtures.py` (check `RG-016`)
- Fixture set: `12_RELEASE/fixtures/remote_content_manifest/*.json`
- Migration required: NO (first version)
- Change decision ID: none yet (DRAFT)

Design source: `00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md` §12; `02_ARCHITECTURE/ANALYTICS_PRIVACY_COMPETITIVE_ARCHITECTURE.md` §Remote content; `08_QA_RELEASE/WORLDCLASS_QA_EXPANSION.md` §Remote content QA; Direction Lock §9.2.

---

## 1. Semantics

A signed-or-checksummed, versioned list of **optional** content packages a client MAY download and activate. It is published by the release pipeline (AI-12) and consumed by a client-side content service (AI-02 domain boundary decides the adapter). Its defining property: **a broken, missing or rejected manifest changes nothing** — the client keeps playing the content it already has.

Remote content is never required for the critical path (DD-015). The schema enforces this: `required` exists as a field so that the validator can assert it is `false` for every package at v1, rather than leaving the rule implicit.

## 2. Schema

```json
{
  "schema": "RemoteContentManifest",
  "schema_version": "0.1.0",
  "fixture_kind": "PRODUCTION",
  "manifest_id": "content.manifest.<opaque-unique>",
  "content_version": "0.2.0",
  "published_utc": "2026-01-01T00:00:00Z",
  "compatible_app_versions": { "min_inclusive": "0.2.0", "max_exclusive": "1.0.0" },
  "rollback_to": "content.manifest.<previous-id-or-empty>",
  "integrity": { "algorithm": "sha256", "hex": "<64 hex chars — digest over the canonical package list>" },
  "packages": [
    {
      "package_id": "content.package.<slug>",
      "package_version": "0.2.0",
      "required": false,
      "enabled": true,
      "size_bytes": 0,
      "checksum": { "algorithm": "sha256", "hex": "<64 hex chars>" },
      "content_schema_version": "0.0.0",
      "min_save_schema_version": "0.0.0",
      "owner": "AI-03"
    }
  ]
}
```

### Field rules

| Field | Rule |
|---|---|
| `schema` | MUST equal `"RemoteContentManifest"`. |
| `schema_version` | semver. |
| `fixture_kind` | `PRODUCTION` \| `MOCK` (MOCK requires `_mock_notice`; `RG-010`). |
| `manifest_id` | matches `^content\.manifest\.[a-z0-9][a-z0-9_-]*$`; unique per publication; immutable. |
| `content_version` | semver; MUST be ≥ the `content_version` of the manifest named in `rollback_to` when both are known (monotonic forward; rollback is done by re-publishing the older manifest as a *new* `manifest_id`, never by decrementing). |
| `published_utc` | RFC 3339 UTC `Z`. |
| `compatible_app_versions` | `min_inclusive` and `max_exclusive` semver; `min_inclusive < max_exclusive`. A client outside the range MUST ignore the manifest. |
| `rollback_to` | `manifest_id` of the last known-good manifest, or `""` only for the very first manifest ever published. Non-empty value MUST match the `manifest_id` pattern. |
| `integrity` | digest over the canonical (sorted by `package_id`) JSON of `packages`; `sha256`, 64 hex. Client MUST verify before reading `packages`. |
| `packages[]` | MAY be empty (an empty list is the mechanism for "disable everything"). `package_id` matches `^content\.package\.[a-z0-9][a-z0-9_-]*$` and is unique within the manifest. `required` MUST be `false` (validator hard rule at v1; lifting it needs a Product decision + new PD). `enabled` boolean — `false` disables a package without removing its definition (safe disable, V7.1 §12). `size_bytes` ≥ 0. `checksum` sha256/64 hex. `content_schema_version` and `min_save_schema_version` semver (recorded from owners AI-03/AI-02; `0.0.0` = not released). `owner` matches `^AI-(0[1-9]|1[0-3])$`. |

Any key whose name contains `password`, `secret`, `keystore`, `private`, `token` → REJECT (`RG-011` in-record scan). Integrity uses a public checksum or a public-key signature (Phase 13 decision); never a shared secret in the client.

## 3. Client behaviour (contract, not implementation)

1. Fetch manifest → verify `schema`/`schema_version` MAJOR → verify `compatible_app_versions` → verify `integrity`. Any failure: **discard, keep current content, record a local diagnostic counter. No UI, no error dialog, no blocking.**
2. For each package with `enabled: true`: download → verify `checksum` → verify `content_schema_version` is readable by this build and `min_save_schema_version` ≤ current save schema → stage → atomically activate. Any failure: package stays on its previous version (or absent).
3. Rollback: publish a new manifest whose `packages` equal the last known-good set. Clients converge without an app update.
4. Never delete previously activated content on manifest failure.

## 4. Failure behaviour summary

| Condition | Required behaviour |
|---|---|
| Network absent | Indistinguishable from "no new manifest". |
| Manifest fails any check | Keep known-good; diagnostic counter increments. |
| Package checksum mismatch | That package only is rejected; others proceed. |
| `required: true` present | Validator FAIL at publish time (never reaches clients at v1). |
| Newer MAJOR schema | Client ignores manifest entirely. |

## 5. Open items (Phase 01/13)

- OI-RCM-01: signature vs. checksum for `integrity` and key-distribution approach — AI-12 with AI-13; human security review.
- OI-RCM-02: whether `packages[].owner` should reference the governance ID registry instead of a free `AI-NN` string — AI-13.
- OI-RCM-03: exact client-side adapter boundary (`RemoteConfigService` in `TECHNICAL_BLUEPRINT.md` §Services) — AI-02.
