# CraftCube — Release & Build Direction Lock v1.0.0 (Phase 00)

| Field | Value |
|---|---|
| Owner | AI-12 — Build / CI/CD / Release / Store |
| Document ID | `AI12-DOC-RELEASE-DIRECTION-LOCK` |
| Version | 1.0.0 |
| Status | READY_FOR_REVIEW (becomes LOCKED after AI-13 governance ratification; human-gated items in §12 stay open) |
| Phase | 00 — Product/IP Lock |
| Canonical intent sources | `00_CONTROL/CRAFTCUBE_GAME_MASTER_BIBLE.md`, `00_CONTROL/V7_1_WORLDCLASS_UPGRADE.md` §10–§13, `02_ARCHITECTURE/TECHNICAL_BLUEPRINT.md`, `02_ARCHITECTURE/ANALYTICS_PRIVACY_COMPETITIVE_ARCHITECTURE.md`, `08_QA_RELEASE/QUALITY_AND_RELEASE.md` (Gates F, G, K), `00_CONTROL/V7_DESIGN_DECISION_REGISTER.md` (DD-010, DD-015) |
| Product alignment | `01_PREPRODUCTION/PRODUCT/PRODUCT_LOCK_V1.md` on `origin/ai-01-product` (READY_FOR_REVIEW, not yet merged) — §5 platform assumptions, §7.3 "Later" (leaderboards, remote packs), PD-010, PD-013, PD-014 |

This document locks the **release, build and store direction** for CraftCube so that every other track can plan against a stable set of build/versioning/provenance/telemetry assumptions in Phase 01. It does not define gameplay, art, story or UX. Where a statement depends on an unverified fact it is labelled ASSUMED, UNKNOWN or HYPOTHESIS; nothing below is presented as a measured result.

Companion documents (same phase):
- `RELEASE_VALIDATION_GATE_POLICY.md` — how release packaging proves content-only changes cannot bypass validation.
- `../contracts/*.md` — DRAFT contract outlines for `BuildProvenance`, `RemoteContentManifest`, `TelemetryEvent`.
- `../handoffs/AI-12_PHASE00_HANDOFF.md` — evidence, risks, integration and rollback.

---

## 1. Release vision (one sentence)

**Every CraftCube artifact a player can install must be reproducible from a clean clone, traceable to the exact commit and content version that produced it, signed with material that never touches source control, and shippable without any network-dependent system being required for the core game.**

## 2. Release pillars (ranked)

| Rank | Pillar | Test | Fails if… |
|---|---|---|---|
| R1 | **Reproducible from clean clone** | A second machine, given only the repository at a tag plus documented secrets, produces a functionally identical artifact (same version, same content hash, same signing identity). | Any build step depends on an uncommitted local file, a developer's machine state, or an undocumented manual action. |
| R2 | **Provenance travels with the artifact** | Every `.apk`/`.aab` carries a `BuildProvenance` record that names commit, content version, ruleset version, save-schema version and build environment. | An installed build cannot be traced back to the commit and content that produced it. |
| R3 | **Content cannot bypass validation** | A change that touches only content/data files still runs the full content validator set before it can enter `integration`. | A content-only PR can merge with a red or skipped validator. |
| R4 | **Secrets never enter the repository** | No keystore, password, service account, API key or token is ever committed, echoed in CI logs or embedded in a client. | A secret appears in git history, a workflow log, or an artifact. |
| R5 | **Offline core; optional layers fail closed** | Telemetry, remote content and leaderboards are build-time configurable and their absence is indistinguishable from presence for the critical path (DD-015, PD-010). | A release build shows an error, blocks progression or degrades when the network is absent. |
| R6 | **Rollback is an artifact, not a hope** | Every release channel retains the last known-good artifact and manifest so a rollback is a redeploy, not a rebuild. | The only copy of a previous release exists on one machine or not at all. |

Lower pillars never override higher ones.

## 3. Repository and build-state facts (VERIFIED at commit `584141c`, re-checked on `ai-12-build`)

| Fact | Status |
|---|---|
| Repository contains documentation only; no Unity project, no `Assets/`, `ProjectSettings/`, `Packages/manifest.json`, no C#, no tests | VERIFIED |
| No `.github/` directory, no CI workflow, no `.gitignore` | VERIFIED |
| No signing configuration, keystore, or secret of any kind is present in any branch | VERIFIED (searched all 14 remote branches) |
| No `integration` branch exists on origin; only `ai-13-integration` | VERIFIED — the PR target named by every phase prompt is MISSING (also reported by AI-02 U-05, AI-05 DEP-06) |
| No contract is FROZEN or RELEASED; `00_CONTROL/PROGRESS.md` baseline is `TBD 1.0.0` for every family | VERIFIED |
| `06_CONTRACTS/WORLDCLASS_CONTRACTS_V7_1.md` assigns `TelemetryEvent` and `RemoteContentManifest` to AI-12 as primary owner | VERIFIED |
| `08_QA_RELEASE/QUALITY_AND_RELEASE.md` requires "build provenance", "checksum manifest" and "rollback artifact" but no schema exists for any of them anywhere in the repo | VERIFIED → CREATE (see `../contracts/`) |
| `07_GITHUB/CODEOWNERS_EXAMPLE.txt` and `07_GITHUB/scripts/validate_ownership.py` map `.github/` and `Release/` to `AI-08` | VERIFIED — legacy 8-account numbering; **CONFLICT** with the 13-account model where AI-12 owns build/release and AI-08 owns audio. Owner of those files: AI-13 governance. Not edited by AI-12. |

## 4. Platform and toolchain assumptions

Product (`PRODUCT_LOCK_V1.md` §5) and the Technical Blueprint state the target; AI-12 records what the build pipeline will assume and who must confirm it.

| Assumption | Value | Label | Owner to verify |
|---|---|---|---|
| Engine | Unity 6 + URP (`TECHNICAL_BLUEPRINT.md` §Engine) | STATED IN BLUEPRINT; exact `ProjectVersion.txt` value UNKNOWN until Phase 02 bootstrap | AI-02 (project) + AI-12 (pin in CI) |
| Primary target | Android; `.aab` for store, `.apk` for internal/device QA | PRODUCT REQUIREMENT (Gate F) | AI-12 |
| Scripting backend / architectures | IL2CPP, ARM64 required; ARMv7 inclusion is a Phase 02 decision | ASSUMED (Google Play has required 64-bit support since 2019; the exact current rule text at release time must be re-read, not remembered) | AI-12 + AI-11 |
| Target/min Android API level | UNKNOWN — Google Play raises the target-API requirement annually; the value is fixed at Phase 14/16 against the then-current policy, never hard-coded in Phase 00 | UNKNOWN by design | AI-12 (re-verify at each release) |
| Build host for CI | Cloud-hosted Linux runners with a pinned Unity image; the specific image/provider is a Phase 02 decision recorded as an ADR | UNKNOWN | AI-12 + AI-13 |
| Unity licence in CI | Requires a licence secret; stored only in the CI secret store (§7) | PRODUCT/ORG DECISION — human-provided credential | Human / AI-12 |
| iOS | Out of scope before RC (`PRODUCT_LOCK_V1.md` §5) | REJECT for v1 pipeline | — |
| Offline | Entire critical path playable with no network (DD-015) | PRODUCT REQUIREMENT → build flag defaults in §9 | AI-12 (flags) / AI-10 (airplane-mode test) |

No device names, performance numbers, SDK versions or store rules are asserted here. They become facts only when measured or re-read at release time.

## 5. Versioning scheme (proposed for Phase 01 freeze)

Four independent version streams are needed because they change for different reasons and are consumed by different systems. Conflating them is the most common cause of un-debuggable live issues.

| Stream | Format | Owner | Changes when | Where it appears |
|---|---|---|---|---|
| **App version** (`versionName`) | `MAJOR.MINOR.PATCH` semver | AI-12 | Player-visible release | Store listing, settings screen, `BuildProvenance.app_version` |
| **Build number** (`versionCode`) | Monotonic integer, never reused, never decremented | AI-12 (CI assigns) | Every release-channel build | Android manifest, `BuildProvenance.build_number` |
| **Content version** | `MAJOR.MINOR.PATCH` | AI-12 stamps; AI-03/AI-09 content changes drive bumps | Any change to shipped content data (puzzles, items, narrative, localization) | `BuildProvenance.content_version`, `RemoteContentManifest.content_version` |
| **Schema versions** (save, content schema, ruleset, event) | Per-contract `MAJOR.MINOR.PATCH` as defined by each owner (AI-02 save/ruleset, AI-13 event, AI-03 content schema) | Respective owners | Contract change | Recorded, not owned, by AI-12 in `BuildProvenance.schema_versions` |

Rules:
- `versionCode` is assigned by CI from an append-only counter; humans never type it.
- A release build fails if `content_version` is unchanged while any file under the content roots (to be declared by AI-03/AI-09 in Phase 01) differs from the previous tagged release. This is the mechanical teeth behind R3.
- Git tags follow `v<app_version>+<build_number>` (e.g. `v0.3.0+417` — illustrative format, not a real tag).
- Pre-release identifiers: `-internal`, `-alpha`, `-beta`, `-rc.N` appended to `versionName` on non-production channels.

## 6. Release channels

| Channel ID (DRAFT) | Purpose | Artifact | Signing identity | Audience | Promotion rule |
|---|---|---|---|---|---|
| `release.channel.internal` | Device QA, daily integration builds | `.apk` (debuggable off; profiling on optional) | Upload key or dedicated internal key | AI-10 / AI-11 device lab | Automatic from green `integration` |
| `release.channel.alpha` | Closed alpha (Phase 15) | `.aab` | Upload key | Invited testers | Manual promotion after Gate A/E/F |
| `release.channel.beta` | Soft launch / open test | `.aab` | Upload key | Opt-in public | Manual promotion after all gates except G finalisation |
| `release.channel.production` | Store release, staged rollout | `.aab` | Upload key (store manages app signing) | Public | Human release approval + Gate F/G evidence |

Channel IDs are DRAFT until Phase 01 and follow the `release.*` stem proposed in §11. Pre-creation search on all branches for `release.channel.` → ABSENT.

## 7. Secrets and signing policy (non-negotiable; ties to stop condition "credential would be exposed")

1. **Never in git.** Forbidden in any branch, any history: `*.keystore`, `*.jks`, `key.properties`, `keystore.properties`, `google-services.json` with real project IDs, service-account `*.json`, `.env`, Unity licence files (`*.ulf`), tokens. Enforced by (a) the `.gitignore` template in `../templates/gitignore.template`, (b) a secret-pattern scan step in the CI template (`../ci/`), (c) a pre-merge check in `RELEASE_VALIDATION_GATE_POLICY.md` §4.
2. **Signing material lives only in the CI secret store** (repository/organisation encrypted secrets) and in an offline human-controlled backup. It is materialised to disk only inside the signing job and removed at job end.
3. **Store-managed app signing** is the default direction so that the upload key is rotatable and the app-signing key never exists on a developer machine. This is PROPOSED; the human product authority confirms at Phase 14.
4. **The client never contains a signing secret** for leaderboards, telemetry or remote content (V7.1 §11). Integrity of remote content is verified by the client using a public key or content checksum, never a shared secret.
5. **Log hygiene:** CI steps that touch secrets run with output masked; no `echo` of secret-bearing variables. Reviewers reject any workflow that prints environment dumps.
6. **Rotation:** upload key rotation and secret rotation procedures are written before the first store upload (Phase 14). Not fabricated here.
7. **Exposure response:** if a secret is ever committed, the response is: revoke/rotate immediately → purge history via governance decision → record incident (`01_GOVERNANCE/INCIDENT_RECOVERY.md`). Rewriting shared history is a destructive migration and requires an approved decision.

## 8. Build provenance (Gate F "build provenance" and "checksum manifest")

Every release-channel artifact is accompanied by a `BuildProvenance` record (DRAFT contract in `../contracts/BuildProvenance.v0.1.0-draft.md`) and is embedded in the build in a read-only, player-inaccessible form so support can read it from a device.

Minimum content: `provenance_schema_version`, `app_version`, `build_number`, `content_version`, `schema_versions{save,ruleset,content,event}`, `git_commit`, `git_tag`, `branch`, `channel_id`, `build_timestamp_utc`, `builder` (CI system + run identifier, never a person's name), `unity_version` (as reported by the build, not typed), `artifact_checksums[]` (algorithm + hex digest per artifact), `signing_identity_fingerprint` (public certificate fingerprint only — never key material), `feature_flags{telemetry,remote_content,leaderboards}`.

The record is generated by CI after signing; it is never hand-edited. A release without a valid provenance record fails Gate F.

## 9. Optional-layer configuration (telemetry, remote content, leaderboards)

Per DD-015 / PD-010 / V7.1 §10–§12, these are **build-time flags** with the following defaults:

| Flag | `internal` | `alpha` | `beta` | `production` | Notes |
|---|---|---|---|---|---|
| `telemetry` | ON (debug sink) | ON only if consent/opt-out UX exists (AI-07) | ON with opt-out | ON with opt-out — or OFF if human legal decision not recorded | Never required for play. Schema: `TelemetryEvent` (DRAFT). Privacy decision is human-gated (V7.1 §17). |
| `remote_content` | OFF | OFF | OFF | OFF at v1 (`PRODUCT_LOCK_V1.md` §7.3 "Later") | Manifest contract is prepared now so Phase 13 does not invent one. |
| `leaderboards` | OFF | OFF | OFF | OFF at v1 (§7.3 "Later") | `CompetitiveResult` is AI-13-owned; AI-12 provides transport only. |

Rule: a flag being OFF must compile the feature out or stub it with a no-op that produces no UI, no error and no network call. AI-10 verifies with the airplane-mode acceptance test (PD-010).

### 9.1 Telemetry configuration principles (AI-12 = transport/config owner; AI-01 = questions; AI-10 = validation; Human = legal)
- Every event has a stable ID (`telemetry.<domain>.<verb>` stem, DRAFT), a schema version, a purpose tag mapping to a V7.1 §10 product question, and a retention class.
- No free-text player content, no device identifiers beyond what the platform anonymises, no precise location.
- Fire-and-forget with bounded local queue; queue overflow drops oldest silently **and increments a local drop counter** (a silent drop with no counter would be a hidden defect — forbidden).
- Transport failure never surfaces to the player.

### 9.2 Remote content principles (prepared, not shipped at v1)
- `RemoteContentManifest` (DRAFT) carries `content_version`, `schema_version`, `compatible_app_versions` (range), per-package `checksum`, `size_bytes`, `required: false` flag, and `rollback_to` pointer to the last known-good manifest.
- Client verifies checksum before activation; on failure it keeps the current known-good content and logs a local diagnostic. It never blocks the offline core (Gate K).
- A package can be disabled by publishing a manifest that omits it; no client update is required to roll back.

## 10. Store readiness framing (Gate G) — what AI-12 owns vs. what is human-gated

| Item | AI-12 responsibility | Human / other owner |
|---|---|---|
| Store listing assets (icon, screenshots, video) | Pipeline to export correctly sized, IP-safe assets from approved sources; checklist | Content: AI-05/06/07; approval: Human (PD-013 title) |
| Privacy policy / data-safety declarations | Generate the declaration inputs from the actual `feature_flags` and `TelemetryEvent` inventory in the build (so the declaration cannot contradict the binary) | Legal text and interpretation: Human (V7.1 §17) |
| Content rating questionnaire | Provide accurate inputs (no violence, no gambling — REJECTED by PD/CUT lists) | Submission: Human |
| Target API / policy compliance | Re-read current store policy at Phase 14 and Phase 16; never rely on remembered values | AI-12 |
| No misleading IP claims | Automated check that no rejected term from `PRODUCT_LOCK_V1.md` §6.3 "Rejected / avoid" column appears in store metadata or package identifiers | AI-01/AI-09 own the term list |
| Application ID / package name | Reverse-DNS, original, no franchise reference; final value is a Human decision alongside the title (PD-013). Placeholder is clearly labelled `TBD_applicationId` in templates. | Human |

## 11. IP-safe release terminology and DRAFT ID stems

Release-side vocabulary is internal (never player-facing) and must not collide with other owners' stems. Pre-creation search for each stem across all 14 branches at the time of writing → ABSENT.

| Concept | Stem / term | Owner | Status |
|---|---|---|---|
| Release channel | `release.channel.<name>` | AI-12 | DRAFT |
| Build provenance record | `BuildProvenance` (contract), `build.provenance` (artifact kind) | AI-12 | DRAFT |
| Remote content manifest | `RemoteContentManifest` (contract), `content.package.<slug>` (package IDs) | AI-12 (manifest); package slugs assigned by content owners | DRAFT |
| Telemetry event | `TelemetryEvent` (contract), `telemetry.<domain>.<verb>` (event IDs) | AI-12 schema; event catalogue proposals from AI-01/AI-10/AI-11 | DRAFT |
| Release gate check | `RG-###` (Release Gate check IDs, this track's validator/check family) | AI-12 | DRAFT — distinct from AI-01 `PD/F10/IGM/CUT`, AI-05 `V1–V9`, AI-02 audit IDs |
| Release decision / dependency | `RD-###` (Release Dependency register entries, §13) | AI-12 | DRAFT |

Avoid: any store/platform brand name inside content IDs; "Minecraft", "Rubik", or other franchise/trademark terms anywhere in package identifiers, channel names or artifact names (`10_SOURCE_REFERENCE/SOURCE_GDD_NOTES.md`).

## 12. Measurable release boundaries (what AI-12 will hold)

| Boundary | Limit | Label | Verification |
|---|---|---|---|
| Clean-clone build reproducibility | 2 of 2 independent CI runs at the same tag yield identical `content_version`, `app_version`, `build_number` and identical content-file checksums | REQUIREMENT (R1) | CI double-run at RC (Phase 16) |
| Secrets in repository | 0 findings from the secret-pattern scan on every PR and on full history at RC | REQUIREMENT (R4) | `RG-` secret scan |
| Content-only PR without validators | 0 — impossible by pipeline construction | REQUIREMENT (R3) | `RELEASE_VALIDATION_GATE_POLICY.md` |
| Provenance completeness | 100% of release-channel artifacts have a validating `BuildProvenance` | REQUIREMENT (R2) | validator |
| Rollback readiness | Last known-good artifact + manifest retained for every channel, restorable without rebuild | REQUIREMENT (R6) | Phase 16 rollback drill |
| Airplane-mode critical path | 0 error dialogs, 0 progression blocks with all optional flags ON but network absent | REQUIREMENT (R5 / PD-010) | AI-10 acceptance test |
| Release artifact size | UNKNOWN — a target is set only after AI-11 publishes budgets and a first Phase 02 build is measured | HYPOTHESIS pending | AI-11 + AI-12 |
| CI wall-clock for a full validate+build | UNKNOWN until first real pipeline; recorded, not promised | UNKNOWN | AI-12 |

## 13. Dependency / decision register (RD-###)

| ID | Type | Description | Owner | Unblocks AI-12 how |
|---|---|---|---|---|
| RD-001 | MISSING | `integration` branch does not exist on origin (only `ai-13-integration`). PR target per every phase prompt is unavailable. | AI-13 | Cannot open the required PR; work is pushed to `ai-12-build` and handoff names the target. |
| RD-002 | CONFLICT | `07_GITHUB/CODEOWNERS_EXAMPLE.txt` and `07_GITHUB/scripts/validate_ownership.py` assign `.github/` and `Release/` to `AI-08`; 13-account model assigns them to AI-12. | AI-13 | Recommendation: map `.github/` and `12_RELEASE/` (or `Release/`) to AI-12; audio to AI-08. AI-12 did not edit. |
| RD-003 | PROPOSED | Ratify `12_RELEASE/` as the AI-12 owned path (pattern: `11_UIUX/` for AI-07). | AI-13 | Until ratified, treat all files as PROPOSED. |
| RD-004 | UNKNOWN | Unity 6 exact version / URP version / Android SDK, NDK, JDK versions for the CI image. | AI-02 (project) → AI-12 pins | Phase 02 bootstrap; recorded as an ADR then. |
| RD-005 | HUMAN | Unity CI licence credential, store developer account, signing key custody. | Human Product Authority | Cannot be mocked meaningfully; pipeline is designed to consume them from the secret store when provided. |
| RD-006 | HUMAN | Application ID / package name and final title (PD-013). | Human | Templates carry `TBD_applicationId`. |
| RD-007 | HUMAN | Telemetry legal/privacy stance and monetization (PD-014) affect store declarations and flag defaults. | Human | Defaults in §9 are conservative and reversible. |
| RD-008 | MISSING | Content root paths (which directories count as "content") for R3 content-version enforcement. | AI-03 / AI-09 (Phase 01) | Policy written generically; concrete paths bound at Phase 01. |
| RD-009 | MISSING | Save schema, ruleset, content schema and event schema version sources to stamp into `BuildProvenance.schema_versions`. | AI-02 / AI-03 / AI-13 | Fixture uses explicit MOCK values. |
| RD-010 | PROPOSED | Protected-zone rule (`01_GOVERNANCE/MULTI_AI_OPERATING_MODEL.md` §5) lists `.github/workflows/` as RFC-only. AI-12 therefore stages workflow templates under `12_RELEASE/ci/` and requests an RFC to activate them in Phase 02. | AI-13 | Nothing under `.github/` is created in Phase 00. |

## 14. Accessibility, localization, performance and recovery implications (release-side)

- **Localization:** release pipeline treats localization tables as content (R3 applies); a pseudo-localization build variant (`PD-012` +35% length) is a planned `internal`-channel flavour, not a Phase 00 artifact.
- **Accessibility:** `AccessibilityPreference` (AI-07, DRAFT 0.1.0) is a save-side concern; AI-12's only obligation is that build flags never strip accessibility features per channel.
- **Performance:** AI-12 does not set budgets. The pipeline will publish the artifact size and a startup-time smoke measurement per build once AI-11 defines the measurement method; until then no numbers are claimed.
- **Recovery:** R6 rollback artifact retention plus §9.2 remote-content rollback pointer. Save migration testing is AI-02/AI-10; the release gate merely refuses to ship if that suite is red (`RELEASE_VALIDATION_GATE_POLICY.md` §3).

## 15. Cut list (release scope, v1)

| ID | Cut | Rationale |
|---|---|---|
| RC-001 | iOS pipeline | Out of v1 scope (`PRODUCT_LOCK_V1.md` §5). |
| RC-002 | Remote content delivery at v1 | "Later" per Product §7.3; manifest contract prepared only so Phase 13 does not invent it. |
| RC-003 | Leaderboard transport at v1 | "Later" per Product §7.3. |
| RC-004 | Third-party crash/analytics SDK selection in Phase 00 | Requires human privacy decision (RD-007) and AI-11 runtime-cost evidence; premature. |
| RC-005 | Hand-maintained version numbers | Replaced by CI-assigned monotonic `versionCode` (§5). |
| RC-006 | Self-hosted CI runners | Not justified without evidence of cost/need; revisit if Unity image licensing or build time forces it. |

`RC-###` = Release Cut IDs (AI-12), distinct from AI-01 `CUT-###`. Pre-creation search → ABSENT.

## 16. Change control

Additive clarification → patch. Changing a pillar rank, a channel definition, a versioning rule, or a flag default → minor version and an `RD-###` entry with AI-13 review. Anything touching secrets policy (§7) or store declarations (§10) → human approval gate (V7.1 §17).
