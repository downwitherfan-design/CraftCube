#!/usr/bin/env python3
"""AI-07 — AccessibilityPreference fixture validator (stdlib only).

Validates every fixture under 11_UIUX/fixtures/accessibility_preference/ against the
DRAFT v0.1.0 schema in 11_UIUX/contracts/AccessibilityPreference.v0.1.0-draft.md.

Design rules enforced here (mirrors the contract text):
  * `schema` and `schema_version` are required.
  * Every other field is optional and resolves to its default when absent.
  * Values outside the allowed set are hard errors (a runtime reader would degrade; the
    validator must REJECT so defects are visible, never silently accepted).
  * A schema_version with a higher MAJOR than supported is a hard error.
  * Unknown keys are tolerated (additive compatibility) except that keys starting with
    "_" are treated as fixture annotations and ignored.
  * Every fixture file must be listed in EXPECTATIONS with an explicit expected outcome
    so that negative fixtures are asserted, not skipped, and no fixture is unaccounted for.

Exit code 0 => all expectations met. Non-zero => at least one mismatch (printed).
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

SCHEMA_NAME = "AccessibilityPreference"
SUPPORTED_MAJOR = 0
SUPPORTED_VERSION = "0.1.0"
FLOAT_TOL = 1e-6

# field -> (kind, allowed, default)
#   kind: "bool" | "enum" | "number_set"
FIELDS: dict[str, tuple[str, tuple, object]] = {
    "reduce_motion": ("bool", (), False),
    "camera_comfort": ("enum", ("standard", "steady", "minimal"), "standard"),
    "screen_shake_intensity": ("number_set", (0.0, 0.25, 0.5, 0.75, 1.0), 0.5),
    "haptic_intensity": ("number_set", (0.0, 0.25, 0.5, 0.75, 1.0), 0.5),
    "audio_cue_redundancy": ("bool", (), True),
    "color_assist_indicators": ("bool", (), False),
    "large_touch_targets": ("bool", (), False),
    "handedness": ("enum", ("right", "left", "auto"), "auto"),
    "safe_area_mode": ("enum", ("system", "extended_padding"), "system"),
    "dialogue_text_speed": ("enum", ("slow", "normal", "fast", "instant"), "normal"),
    "text_scale": ("number_set", (1.0, 1.15, 1.3, 1.5), 1.0),
    "high_contrast_ui": ("bool", (), False),
    "hold_to_confirm_destructive": ("bool", (), True),
}

# Every fixture must appear here. True => must validate. False => must be rejected.
EXPECTATIONS: dict[str, bool] = {
    "default.json": True,
    "max_comfort.json": True,
    "left_handed_large_targets.json": True,
    "minimal_keys_only.json": True,
    "invalid_enum_case.json": False,
    "future_major_version.json": False,
}

HERE = Path(__file__).resolve().parent
FIXTURE_DIR = HERE.parent / "fixtures" / "accessibility_preference"


def _parse_semver(v: str) -> tuple[int, int, int]:
    parts = v.split(".")
    if len(parts) != 3 or not all(p.isdigit() for p in parts):
        raise ValueError(f"schema_version '{v}' is not MAJOR.MINOR.PATCH")
    return int(parts[0]), int(parts[1]), int(parts[2])


def validate(doc: dict) -> tuple[list[str], dict]:
    """Return (errors, resolved_block). errors empty => valid."""
    errors: list[str] = []
    resolved: dict = {}

    if doc.get("schema") != SCHEMA_NAME:
        errors.append(f"schema must be '{SCHEMA_NAME}', got {doc.get('schema')!r}")
    version = doc.get("schema_version")
    if not isinstance(version, str):
        errors.append("schema_version missing or not a string")
    else:
        try:
            major, _, _ = _parse_semver(version)
            if major > SUPPORTED_MAJOR:
                errors.append(
                    f"schema_version {version} has MAJOR {major} > supported {SUPPORTED_MAJOR}: refuse to apply"
                )
        except ValueError as exc:
            errors.append(str(exc))

    for field, (kind, allowed, default) in FIELDS.items():
        if field not in doc:
            resolved[field] = default
            continue
        value = doc[field]
        if kind == "bool":
            if not isinstance(value, bool):
                errors.append(f"{field}: expected bool, got {type(value).__name__}")
                continue
        elif kind == "enum":
            if not isinstance(value, str) or value not in allowed:
                errors.append(f"{field}: {value!r} not in {list(allowed)}")
                continue
        elif kind == "number_set":
            if isinstance(value, bool) or not isinstance(value, (int, float)):
                errors.append(f"{field}: expected number, got {type(value).__name__}")
                continue
            if not any(abs(float(value) - a) <= FLOAT_TOL for a in allowed):
                errors.append(f"{field}: {value!r} not in {list(allowed)}")
                continue
        resolved[field] = value

    return errors, resolved


def main() -> int:
    if not FIXTURE_DIR.is_dir():
        print(f"FAIL: fixture dir not found: {FIXTURE_DIR}")
        return 2

    files = sorted(p.name for p in FIXTURE_DIR.glob("*.json"))
    unaccounted = sorted(set(files) - set(EXPECTATIONS))
    missing = sorted(set(EXPECTATIONS) - set(files))
    failures = 0

    if unaccounted:
        failures += len(unaccounted)
        for name in unaccounted:
            print(f"FAIL: fixture '{name}' has no entry in EXPECTATIONS (add an explicit outcome)")
    if missing:
        failures += len(missing)
        for name in missing:
            print(f"FAIL: expected fixture '{name}' is missing on disk")

    for name, expect_valid in EXPECTATIONS.items():
        path = FIXTURE_DIR / name
        if not path.exists():
            continue
        try:
            doc = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            print(f"FAIL: {name}: invalid JSON: {exc}")
            failures += 1
            continue
        errors, resolved = validate(doc)
        is_valid = not errors
        outcome = "VALID" if is_valid else "REJECTED"
        if is_valid == expect_valid:
            print(f"PASS: {name}: {outcome} (expected)")
            if is_valid and name == "minimal_keys_only.json":
                # prove default resolution matches the golden default fixture
                golden = json.loads((FIXTURE_DIR / "default.json").read_text(encoding="utf-8"))
                golden_body = {k: v for k, v in golden.items() if k in FIELDS}
                if resolved != golden_body:
                    print("FAIL: minimal_keys_only resolved defaults differ from default.json")
                    failures += 1
                else:
                    print("PASS: minimal_keys_only resolves to the golden default block")
        else:
            failures += 1
            print(f"FAIL: {name}: {outcome} but expected {'VALID' if expect_valid else 'REJECTED'}")
        for err in errors:
            print(f"      - {err}")

    print(f"\nSUMMARY: {len(EXPECTATIONS)} fixtures checked, {failures} failure(s), schema {SCHEMA_NAME} {SUPPORTED_VERSION}")
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
