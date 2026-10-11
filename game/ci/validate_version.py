#!/usr/bin/env python3
"""CraftCube application-version consistency validator (stdlib only, no network).

Owner: AI-13 (Integration / Architecture Governance). Build-pipeline use only.
Implements the "single validated source of truth" acceptance criterion of the
mandatory versioned-APK release policy (12_RELEASE/ANDROID_RELEASE_POLICY.md).

Sources of truth:
  game/app_version.json     -> authoritative app_version (MAJOR.MINOR.PATCH) + version_code
                               + expected android metadata + the released[] ledger.
Consistency targets (must agree with the source of truth):
  game/export_presets.cfg   -> preset.0.options version/name, version/code, package/unique_name,
                               architectures/arm64-v8a, gradle_build/min_sdk
  game/scripts/game/version.gd -> must reference res://app_version.json

Checks:
  V1  app_version is valid SemVer MAJOR.MINOR.PATCH
  V2  version_code is a positive integer
  V3  export_presets.cfg version/name == app_version
  V4  export_presets.cfg version/code == version_code
  V5  export_presets.cfg package/unique_name == android.package
  V6  enabled architectures match android.architectures
  V7  version_code strictly greater than every released[].version_code (monotonic)
  V8  app_version not already present in released[] (no version reuse)
  V9  version.gd reads res://app_version.json (no second hard-coded version)
  V10 min_sdk in export preset (if set) == android.min_sdk

Exit 0 only when all checks pass; otherwise exit 1 with the failing checks listed.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

VALIDATOR_ID = "validate_version"
VALIDATOR_VERSION = "0.1.0"
SEMVER_RE = re.compile(r"^\d+\.\d+\.\d+$")

_ARCH_KEYS = {
    "armeabi-v7a": "architectures/armeabi-v7a",
    "arm64-v8a": "architectures/arm64-v8a",
    "x86": "architectures/x86",
    "x86_64": "architectures/x86_64",
}


def _read_kv(text: str) -> dict:
    """Flat key=value map from a Godot .cfg (keys are globally unique enough here)."""
    out = {}
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith(";") or line.startswith("[") or "=" not in line:
            continue
        k, v = line.split("=", 1)
        out[k.strip()] = v.strip().strip('"')
    return out


def validate(root: Path) -> list:
    problems: list = []

    version_file = root / "game" / "app_version.json"
    preset_file = root / "game" / "export_presets.cfg"
    version_gd = root / "game" / "scripts" / "game" / "version.gd"

    for path in (version_file, preset_file, version_gd):
        if not path.is_file():
            problems.append(f"missing required file: {path.relative_to(root)}")
    if problems:
        return problems

    meta = json.loads(version_file.read_text())
    app_version = str(meta.get("app_version", ""))
    version_code = meta.get("version_code")
    android = meta.get("android", {}) or {}
    released = meta.get("released", []) or []

    # V1
    if not SEMVER_RE.match(app_version):
        problems.append(f"V1 app_version {app_version!r} is not MAJOR.MINOR.PATCH")
    # V2
    if not isinstance(version_code, int) or version_code <= 0:
        problems.append(f"V2 version_code {version_code!r} is not a positive integer")

    preset = _read_kv(preset_file.read_text())

    # V3 / V4
    if preset.get("version/name") != app_version:
        problems.append(
            f"V3 export version/name {preset.get('version/name')!r} != app_version {app_version!r}"
        )
    if str(preset.get("version/code")) != str(version_code):
        problems.append(
            f"V4 export version/code {preset.get('version/code')!r} != version_code {version_code!r}"
        )
    # V5
    if preset.get("package/unique_name") != android.get("package"):
        problems.append(
            f"V5 export package {preset.get('package/unique_name')!r} != android.package "
            f"{android.get('package')!r}"
        )
    # V6
    for abi in android.get("architectures", []):
        key = _ARCH_KEYS.get(abi)
        if key is None:
            problems.append(f"V6 unknown architecture {abi!r} in app_version.json")
        elif preset.get(key) != "true":
            problems.append(f"V6 architecture {abi!r} declared but not enabled in export preset")
    for abi, key in _ARCH_KEYS.items():
        if preset.get(key) == "true" and abi not in android.get("architectures", []):
            problems.append(f"V6 export preset enables {abi!r} but app_version.json does not list it")
    # V10
    preset_min = preset.get("gradle_build/min_sdk", "")
    if preset_min not in ("", None) and str(preset_min) != str(android.get("min_sdk")):
        problems.append(
            f"V10 export min_sdk {preset_min!r} != android.min_sdk {android.get('min_sdk')!r}"
        )

    # V7 / V8
    for rec in released:
        rc = rec.get("version_code")
        if isinstance(rc, int) and isinstance(version_code, int) and version_code <= rc:
            problems.append(
                f"V7 version_code {version_code} must be > released version_code {rc} "
                f"({rec.get('version')})"
            )
        if rec.get("version") == app_version:
            problems.append(f"V8 app_version {app_version} already released (version reuse)")

    # V9
    if "res://app_version.json" not in version_gd.read_text():
        problems.append("V9 version.gd does not read res://app_version.json (duplicated version?)")

    return problems


def main(argv=None) -> int:
    p = argparse.ArgumentParser(description="Validate CraftCube version consistency.")
    p.add_argument("--root", default=None, help="repo root (default: two levels up from this file)")
    args = p.parse_args(argv)
    root = Path(args.root).resolve() if args.root else Path(__file__).resolve().parents[2]

    problems = validate(root)
    if problems:
        for prob in problems:
            print(f"validate_version: {prob}", file=sys.stderr)
        return 1
    meta = json.loads((root / "game" / "app_version.json").read_text())
    print(
        f"validate_version: OK  app_version={meta['app_version']}  version_code={meta['version_code']}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
