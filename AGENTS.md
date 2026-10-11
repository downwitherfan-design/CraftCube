# AGENTS.md — CraftCube repository memory

## GitHub write credential (out-of-band, do NOT commit the value)

The runtime's injected `GITHUB_TOKEN` is **read-only** (empty OAuth scopes → `403` on write).
The owner supplied a write-enabled PAT. It is stored **outside this repository**:

- Token file: `/home/openhands/.config/craftcube/github_token` (mode `600`)
- Askpass helper: `/home/openhands/.config/craftcube/gitaskpass.sh` (mode `700`)

Never print, log, commit, or embed the token value in any repo file, `.git/config`, or remote URL.
Prefer the one-off URL form so it never lands on disk in git config:

```bash
TOK="$(cat /home/openhands/.config/craftcube/github_token)"
GIT_TERMINAL_PROMPT=0 git push "https://x-access-token:${TOK}@github.com/downwitherfan-design/CraftCube.git" <branch>
```

For API calls: `curl -H "Authorization: Bearer $TOK" https://api.github.com/...`
(for example, pushing tag `vX.Y.Z` triggers `.github/workflows/craftcube-release.yml`).

## Release rule (non-negotiable)

Every release-ready milestone must publish a **versioned APK as a GitHub Release asset**, not merely
a CI pass or an Actions artifact. Workflow: bump `game/app_version.json` (+ `export_presets.cfg`),
commit, push tag `vX.Y.Z`. See `12_RELEASE/ANDROID_RELEASE_POLICY.md`.

## Working branch

`godot-migration` (PR #11 → `integration`). Never merge PR #11 into `integration`/`main` without the
Phase 00 gate passing and the required human approvals. See `11_INTEGRATION/OPENHANDS_RESUME_STATE.md`.
