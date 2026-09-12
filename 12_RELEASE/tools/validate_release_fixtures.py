#!/usr/bin/env python3
"""AI-12 release-contract fixture validator (Phase 00).

Owner: AI-12 — Build / CI/CD / Release / Store
Validator ID: validate_release_fixtures
Validator version: 0.1.0

Implements the Release Gate checks that AI-12 owns and that can be executed today
against DRAFT contracts (see 12_RELEASE/phase_00/RELEASE_VALIDATION_GATE_POLICY.md §3):

  RG-010  no MOCK fixture is unlabelled / mock detectability
  RG-011  in-record secret-pattern scan (key names)
  RG-012  BuildProvenance record validates against BuildProvenance.v0.1.0-draft
  RG-016  RemoteContentManifest validates against RemoteContentManifest.v0.1.0-draft
  RG-017  TelemetryEventCatalogue validates against TelemetryEvent.v0.1.0-draft

Behaviour:
  * Positive fixtures: every file in 12_RELEASE/fixtures/<family>/ NOT prefixed NEG_
    must pass all applicable checks.
  * Negative fixtures: every file prefixed NEG_ must FAIL, and the FIRST failing check
    must equal the RG id declared in the fixture's "_expect_fail" key. A negative fixture
    that passes, or fails on a different check, is itself a defect (test-integrity rule:
    the validator must be proven to catch what it claims to catch).
  * Exit 0 only when all positive pass and all negative fail as expected. Otherwise exit 1.
  * stdlib only. No network. Deterministic output ordering.

Usage:
  python3 12_RELEASE/tools/validate_release_fixtures.py [--root <repo-root>]
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

VALIDATOR_ID = "validate_release_fixtures"
VALIDATOR_VERSION = "0.1.0"

SEMVER = re.compile(r"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$")
APP_VERSION = re.compile(r"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(-(internal|alpha|beta|rc\.[1-9]\d*))?$")
HEX64 = re.compile(r"^[0-9a-f]{64}$")
HEX40 = re.compile(r"^[0-9a-f]{40}$")
RFC3339Z = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$")
CHANNEL_ID = re.compile(r"^release\.channel\.(internal|alpha|beta|production)$")
RG_ID = re.compile(r"^RG-[0-9]{3}$")
AI_OWNER = re.compile(r"^AI-(0[1-9]|1[0-3])$")
MANIFEST_ID = re.compile(r"^content\.manifest\.[a-z0-9][a-z0-9_-]*$")
PACKAGE_ID = re.compile(r"^content\.package\.[a-z0-9][a-z0-9_-]*$")
EVENT_ID = re.compile(r"^telemetry\.[a-z][a-z0-9_]*\.[a-z][a-z0-9_]*$")
FIELD_NAME = re.compile(r"^[a-z][a-z0-9_]*$")

SECRET_KEY_TOKENS = ("password", "secret", "keystore", "private", "token")
FORBIDDEN_TELEMETRY_FIELD_TOKENS = (
    "email", "phone", "address", "imei", "mac", "advertising_id", "adid", "idfa", "gaid",
    "location", "lat", "lon", "gps", "password", "secret", "token", "chat", "free_text",
    "raw_text", "custom_", "user_input",
)
FORBIDDEN_TELEMETRY_FIELD_WHOLE = ("name", "first_name", "last_name", "username", "display_name", "ip")

TELEMETRY_PURPOSES = {
    "onboarding_abandonment", "tutorial_error", "item_misunderstanding", "quest_abandonment",
    "biome_revisit", "performance_drop", "crash_diagnostic",
}
TELEMETRY_RETENTION = {"session_only", "aggregate_90d", "diagnostic_30d"}
TELEMETRY_FIELD_TYPES = {"bool", "int", "float", "string_id", "enum", "duration_ms"}
ARTIFACT_KINDS = {"apk", "aab", "symbols", "mapping"}
REQUIRED_VALIDATOR_SET = {"RG-010", "RG-011", "RG-012"}

FAMILIES = {
    "build_provenance": "BuildProvenance",
    "remote_content_manifest": "RemoteContentManifest",
    "telemetry_event": "TelemetryEventCatalogue",
}


class CheckFailure(Exception):
    def __init__(self, rg: str, message: str):
        super().__init__(f"{rg}: {message}")
        self.rg = rg
        self.message = message


def fail(rg: str, msg: str) -> None:
    raise CheckFailure(rg, msg)


def req(obj: dict, key: str, rg: str, typ=None):
    if key not in obj:
        fail(rg, f"missing required key '{key}'")
    val = obj[key]
    if typ is not None and not isinstance(val, typ):
        fail(rg, f"key '{key}' must be {typ.__name__ if hasattr(typ, '__name__') else typ}, got {type(val).__name__}")
    return val


def semver(obj: dict, key: str, rg: str) -> str:
    v = req(obj, key, rg, str)
    if not SEMVER.match(v):
        fail(rg, f"'{key}' is not MAJOR.MINOR.PATCH semver: {v!r}")
    return v


def semver_tuple(v: str) -> tuple:
    return tuple(int(x) for x in v.split("."))


def digest(obj: dict, key: str, rg: str) -> dict:
    d = req(obj, key, rg, dict)
    if req(d, "algorithm", rg, str) != "sha256":
        fail(rg, f"'{key}.algorithm' must be 'sha256'")
    if not HEX64.match(req(d, "hex", rg, str)):
        fail(rg, f"'{key}.hex' must be 64 lowercase hex chars")
    return d


# --------------------------------------------------------------------------- RG-010 / RG-011

def check_rg010_mock_labelling(rec: dict) -> None:
    kind = req(rec, "fixture_kind", "RG-010", str)
    if kind not in ("PRODUCTION", "MOCK"):
        fail("RG-010", f"fixture_kind must be PRODUCTION or MOCK, got {kind!r}")
    if kind == "MOCK":
        notice = rec.get("_mock_notice")
        if not isinstance(notice, str) or not notice.strip():
            fail("RG-010", "MOCK record without non-empty '_mock_notice' (undetectable mock)")
    else:
        if "_mock_notice" in rec:
            fail("RG-010", "PRODUCTION record carries '_mock_notice' (ambiguous fixture kind)")


def _walk_keys(node, path=""):
    if isinstance(node, dict):
        for k, v in node.items():
            yield f"{path}.{k}" if path else k, k
            yield from _walk_keys(v, f"{path}.{k}" if path else k)
    elif isinstance(node, list):
        for i, v in enumerate(node):
            yield from _walk_keys(v, f"{path}[{i}]")


def check_rg011_secret_keys(rec: dict) -> None:
    for full, key in _walk_keys(rec):
        low = key.lower()
        for tok in SECRET_KEY_TOKENS:
            if tok in low:
                fail("RG-011", f"key '{full}' contains forbidden secret-like token '{tok}'")


# --------------------------------------------------------------------------- RG-012 BuildProvenance

def check_rg012_build_provenance(rec: dict) -> None:
    rg = "RG-012"
    if req(rec, "schema", rg, str) != "BuildProvenance":
        fail(rg, "schema must be 'BuildProvenance'")
    semver(rec, "schema_version", rg)
    av = req(rec, "app_version", rg, str)
    if not APP_VERSION.match(av):
        fail(rg, f"app_version invalid: {av!r}")
    bn = req(rec, "build_number", rg, int)
    if isinstance(bn, bool) or bn < 1:
        fail(rg, "build_number must be integer >= 1")
    semver(rec, "content_version", rg)
    digest(rec, "content_digest", rg)

    sv = req(rec, "schema_versions", rg, dict)
    for k in ("save", "ruleset", "content", "event"):
        semver(sv, k, rg)

    git = req(rec, "git", rg, dict)
    if not HEX40.match(req(git, "commit", rg, str)):
        fail(rg, "git.commit must be 40 lowercase hex")
    tag = req(git, "tag", rg, str)
    if not req(git, "branch", rg, str):
        fail(rg, "git.branch must be non-empty")

    ch = req(rec, "channel_id", rg, str)
    if not CHANNEL_ID.match(ch):
        fail(rg, f"channel_id invalid: {ch!r}")
    if ch != "release.channel.internal" and not tag:
        fail(rg, f"git.tag must be non-empty for channel {ch}")

    if not RFC3339Z.match(req(rec, "build_timestamp_utc", rg, str)):
        fail(rg, "build_timestamp_utc must be RFC3339 UTC with trailing Z")

    builder = req(rec, "builder", rg, dict)
    if not req(builder, "system", rg, str):
        fail(rg, "builder.system must be non-empty")
    if not req(builder, "run_id", rg, str):
        fail(rg, "builder.run_id must be non-empty")

    if not req(rec, "unity_version", rg, str):
        fail(rg, "unity_version must be non-empty")

    ff = req(rec, "feature_flags", rg, dict)
    for k in ("telemetry", "remote_content", "leaderboards"):
        req(ff, k, rg, bool)

    arts = req(rec, "artifacts", rg, list)
    if not arts:
        fail(rg, "artifacts must contain at least one entry")
    kinds = set()
    for i, a in enumerate(arts):
        if not isinstance(a, dict):
            fail(rg, f"artifacts[{i}] must be an object")
        kind = req(a, "kind", rg, str)
        if kind not in ARTIFACT_KINDS:
            fail(rg, f"artifacts[{i}].kind invalid: {kind!r}")
        kinds.add(kind)
        if not req(a, "file_name", rg, str):
            fail(rg, f"artifacts[{i}].file_name must be non-empty")
        sb = req(a, "size_bytes", rg, int)
        if isinstance(sb, bool) or sb < 0:
            fail(rg, f"artifacts[{i}].size_bytes must be integer >= 0")
        digest(a, "checksum", rg)
    if not (kinds & {"apk", "aab"}):
        fail(rg, "artifacts must include at least one apk or aab")

    digest(rec, "signing_identity_fingerprint", rg)

    vals = req(rec, "validators", rg, list)
    if not vals:
        fail(rg, "validators must contain at least one entry")
    seen = set()
    for i, v in enumerate(vals):
        if not isinstance(v, dict):
            fail(rg, f"validators[{i}] must be an object")
        rid = req(v, "rg_id", rg, str)
        if not RG_ID.match(rid):
            fail(rg, f"validators[{i}].rg_id invalid: {rid!r}")
        seen.add(rid)
        if not req(v, "validator_id", rg, str):
            fail(rg, f"validators[{i}].validator_id must be non-empty")
        semver(v, "validator_version", rg)
        ec = req(v, "exit_code", rg, int)
        if isinstance(ec, bool):
            fail(rg, f"validators[{i}].exit_code must be integer")
        if ec != 0:
            fail(rg, f"validators[{i}] ({rid}) has non-zero exit_code {ec}; a red validator can never be shipped")
        fn = req(v, "findings", rg, int)
        if isinstance(fn, bool) or fn < 0:
            fail(rg, f"validators[{i}].findings must be integer >= 0")
    missing = sorted(REQUIRED_VALIDATOR_SET - seen)
    if missing:
        fail(rg, f"validators missing required set entries: {missing}")


# --------------------------------------------------------------------------- RG-016 RemoteContentManifest

def canonical_packages_digest(packages: list) -> str:
    canon = json.dumps(sorted(packages, key=lambda p: p["package_id"]), sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(canon.encode("utf-8")).hexdigest()


def check_rg016_remote_content_manifest(rec: dict) -> None:
    rg = "RG-016"
    if req(rec, "schema", rg, str) != "RemoteContentManifest":
        fail(rg, "schema must be 'RemoteContentManifest'")
    semver(rec, "schema_version", rg)
    mid = req(rec, "manifest_id", rg, str)
    if not MANIFEST_ID.match(mid):
        fail(rg, f"manifest_id invalid: {mid!r}")
    semver(rec, "content_version", rg)
    if not RFC3339Z.match(req(rec, "published_utc", rg, str)):
        fail(rg, "published_utc must be RFC3339 UTC with trailing Z")

    cav = req(rec, "compatible_app_versions", rg, dict)
    lo = semver(cav, "min_inclusive", rg)
    hi = semver(cav, "max_exclusive", rg)
    if not semver_tuple(lo) < semver_tuple(hi):
        fail(rg, f"compatible_app_versions min_inclusive {lo} must be < max_exclusive {hi}")

    rb = req(rec, "rollback_to", rg, str)
    if rb and not MANIFEST_ID.match(rb):
        fail(rg, f"rollback_to invalid manifest_id: {rb!r}")
    if rb and rb == mid:
        fail(rg, "rollback_to must not point at itself")

    integ = digest(rec, "integrity", rg)
    pkgs = req(rec, "packages", rg, list)
    ids = set()
    for i, p in enumerate(pkgs):
        if not isinstance(p, dict):
            fail(rg, f"packages[{i}] must be an object")
        pid = req(p, "package_id", rg, str)
        if not PACKAGE_ID.match(pid):
            fail(rg, f"packages[{i}].package_id invalid: {pid!r}")
        if pid in ids:
            fail(rg, f"duplicate package_id {pid!r}")
        ids.add(pid)
        semver(p, "package_version", rg)
        if req(p, "required", rg, bool) is not False:
            fail(rg, f"packages[{i}] ({pid}) has required=true; remote content may never be required (DD-015, v1 hard rule)")
        req(p, "enabled", rg, bool)
        sb = req(p, "size_bytes", rg, int)
        if isinstance(sb, bool) or sb < 0:
            fail(rg, f"packages[{i}].size_bytes must be integer >= 0")
        digest(p, "checksum", rg)
        semver(p, "content_schema_version", rg)
        semver(p, "min_save_schema_version", rg)
        owner = req(p, "owner", rg, str)
        if not AI_OWNER.match(owner):
            fail(rg, f"packages[{i}].owner invalid: {owner!r}")
    expected = canonical_packages_digest(pkgs)
    if integ["hex"] != expected:
        fail(rg, "integrity.hex does not match canonical digest of packages (tamper/stale manifest)")


# --------------------------------------------------------------------------- RG-017 TelemetryEventCatalogue

def _forbidden_field(name: str) -> str | None:
    low = name.lower()
    if low in FORBIDDEN_TELEMETRY_FIELD_WHOLE:
        return low
    for tok in FORBIDDEN_TELEMETRY_FIELD_TOKENS:
        if tok in low:
            return tok
    return None


def check_rg017_telemetry_catalogue(rec: dict) -> None:
    rg = "RG-017"
    if req(rec, "schema", rg, str) != "TelemetryEventCatalogue":
        fail(rg, "schema must be 'TelemetryEventCatalogue'")
    semver(rec, "schema_version", rg)
    semver(rec, "catalogue_version", rg)
    events = req(rec, "events", rg, list)
    ids = set()
    for i, e in enumerate(events):
        if not isinstance(e, dict):
            fail(rg, f"events[{i}] must be an object")
        eid = req(e, "event_id", rg, str)
        if not EVENT_ID.match(eid):
            fail(rg, f"events[{i}].event_id invalid (expect telemetry.<domain>.<verb>): {eid!r}")
        if eid in ids:
            fail(rg, f"duplicate event_id {eid!r}")
        ids.add(eid)
        semver(e, "event_version", rg)
        purpose = req(e, "purpose", rg, str)
        if purpose not in TELEMETRY_PURPOSES:
            fail(rg, f"{eid}: purpose {purpose!r} not in closed set")
        ret = req(e, "retention_class", rg, str)
        if ret not in TELEMETRY_RETENTION:
            fail(rg, f"{eid}: retention_class {ret!r} not in closed set")
        oq = req(e, "owner_question", rg, str)
        if not AI_OWNER.match(oq):
            fail(rg, f"{eid}: owner_question invalid: {oq!r}")
        fields = req(e, "fields", rg, list)
        names = set()
        for j, f in enumerate(fields):
            if not isinstance(f, dict):
                fail(rg, f"{eid}.fields[{j}] must be an object")
            n = req(f, "name", rg, str)
            if not FIELD_NAME.match(n):
                fail(rg, f"{eid}.fields[{j}].name invalid: {n!r}")
            if n in names:
                fail(rg, f"{eid}: duplicate field name {n!r}")
            names.add(n)
            bad = _forbidden_field(n)
            if bad:
                fail(rg, f"{eid}: field {n!r} matches forbidden personal-data/free-text token {bad!r}")
            t = req(f, "type", rg, str)
            if t not in TELEMETRY_FIELD_TYPES:
                fail(rg, f"{eid}.fields[{j}].type invalid (no free-text 'string' type exists): {t!r}")
            req(f, "required", rg, bool)


# --------------------------------------------------------------------------- driver

FAMILY_CHECKS = {
    "build_provenance": check_rg012_build_provenance,
    "remote_content_manifest": check_rg016_remote_content_manifest,
    "telemetry_event": check_rg017_telemetry_catalogue,
}


def run_checks(family: str, rec: dict) -> None:
    """Order matters: RG-010 and RG-011 are cross-cutting and run first."""
    check_rg010_mock_labelling(rec)
    check_rg011_secret_keys(rec)
    FAMILY_CHECKS[family](rec)


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=None, help="repository root (default: derived from this file)")
    args = ap.parse_args(argv)
    root = Path(args.root).resolve() if args.root else Path(__file__).resolve().parents[2]
    fixtures_root = root / "12_RELEASE" / "fixtures"

    passed = failed = 0
    lines: list[str] = []

    for family in sorted(FAMILIES):
        fdir = fixtures_root / family
        if not fdir.is_dir():
            lines.append(f"FAIL [{family}] fixture directory missing: {fdir}")
            failed += 1
            continue
        files = sorted(fdir.glob("*.json"))
        if not files:
            lines.append(f"FAIL [{family}] no fixtures found (a missing validator input is never a pass)")
            failed += 1
            continue
        for path in files:
            rel = path.relative_to(root).as_posix()
            try:
                rec = json.loads(path.read_text(encoding="utf-8"))
            except json.JSONDecodeError as exc:
                lines.append(f"FAIL [{rel}] invalid JSON: {exc}")
                failed += 1
                continue
            if not isinstance(rec, dict):
                lines.append(f"FAIL [{rel}] top-level must be an object")
                failed += 1
                continue

            negative = path.name.startswith("NEG_")
            expect = rec.pop("_expect_fail", None)
            try:
                run_checks(family, rec)
                outcome = None
            except CheckFailure as cf:
                outcome = cf

            if not negative:
                if outcome is None:
                    lines.append(f"PASS [{rel}] fixture_kind={rec.get('fixture_kind')} schema={rec.get('schema')} v{rec.get('schema_version')}")
                    passed += 1
                else:
                    lines.append(f"FAIL [{rel}] {outcome}")
                    failed += 1
            else:
                if not isinstance(expect, str) or not RG_ID.match(expect):
                    lines.append(f"FAIL [{rel}] negative fixture must declare '_expect_fail': 'RG-###'")
                    failed += 1
                elif outcome is None:
                    lines.append(f"FAIL [{rel}] negative fixture PASSED but was expected to fail on {expect}")
                    failed += 1
                elif outcome.rg != expect:
                    lines.append(f"FAIL [{rel}] negative fixture failed on {outcome.rg} but expected {expect}: {outcome.message}")
                    failed += 1
                else:
                    lines.append(f"PASS [{rel}] negative fixture failed as expected on {expect}: {outcome.message}")
                    passed += 1

    for ln in lines:
        print(ln)
    total = passed + failed
    status = "OK" if failed == 0 else "DEFECT"
    print(f"RESULT {status} ({passed} passed, {failed} failed, {total} fixtures) "
          f"validator={VALIDATOR_ID} v{VALIDATOR_VERSION}")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
