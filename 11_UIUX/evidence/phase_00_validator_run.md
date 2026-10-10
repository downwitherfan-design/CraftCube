# Evidence — Phase 00 AI-07 fixture validation

Claim covered: "AccessibilityPreference v0.1.0-draft fixtures are well-formed, negative fixtures
are rejected, and the validator itself detects tampering."
Standard: `08_QA_RELEASE/EVIDENCE_STANDARD.md` (unit-test-style claim → exact command + result).

Environment (VERIFIED at run time): Python 3.13.14, branch `ai-07-uiux`, repo root
`/home/user/flutter_app` (local clone of `downwitherfan-design/CraftCube`). No Unity, no
Android device, no build was run. Nothing below is a device or performance result.

## 1. Primary run

Command:
```
cd /home/user/flutter_app && python3 11_UIUX/tools/validate_a11y_fixtures.py; echo "EXIT_CODE=$?"
```

Output (verbatim):
```
PASS: default.json: VALID (expected)
PASS: max_comfort.json: VALID (expected)
PASS: left_handed_large_targets.json: VALID (expected)
PASS: minimal_keys_only.json: VALID (expected)
PASS: minimal_keys_only resolves to the golden default block
PASS: invalid_enum_case.json: REJECTED (expected)
      - camera_comfort: 'cinematic' not in ['standard', 'steady', 'minimal']
      - text_scale: 2.0 not in [1.0, 1.15, 1.3, 1.5]
PASS: future_major_version.json: REJECTED (expected)
      - schema_version 2.0.0 has MAJOR 2 > supported 0: refuse to apply

SUMMARY: 6 fixtures checked, 0 failure(s), schema AccessibilityPreference 0.1.0
EXIT_CODE=0
```

## 2. Mutation checks (validator integrity — run on a scratch copy in /tmp, repo untouched)

| Mutation | Expected | Observed | Exit |
|---|---|---|---|
| `default.json`: `reduce_motion` set to string `"yes"` | validator fails | `FAIL: default.json: REJECTED but expected VALID` and `FAIL: minimal_keys_only resolved defaults differ from default.json` | 1 |
| Add unlisted `rogue.json` fixture | validator fails (no unaccounted fixture) | `FAIL: fixture 'rogue.json' has no entry in EXPECTATIONS` | 1 |
| Make `invalid_enum_case.json` valid | validator fails (negative fixture must stay negative) | `FAIL: invalid_enum_case.json: VALID but expected REJECTED` | 1 |

After mutations, `git status --short` in the repository printed nothing (clean).

Note on process honesty: the first attempt at mutation 1 printed `EXIT=0` because `$?` captured
the exit of `tail` in a pipeline, not the validator. It was re-run with the validator's exit
code captured directly (result: `EXIT=1`). The corrected result is the one recorded above.

## 3. What this evidence does NOT show

- No runtime reader exists yet; "degraded" handling is specified in the contract, not implemented.
- No consumer (AI-04/06/08/11) has integrated the fixture.
- No accessibility audit, contrast measurement, touch-target audit or device test was performed.
