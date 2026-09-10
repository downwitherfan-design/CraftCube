#!/usr/bin/env python3
"""
AI-05 Environment fixture validator (Phase 00).

Owner: AI-05 — Environment Art / World / Materials / Lighting
Scope: validates AI-05-owned presentation fixtures under
       09_ART_AUDIO/environment/fixtures/. It does NOT validate gameplay,
       simulation, save schemas or any other account's data.

Checks enforced (all deterministic, no network, stdlib only):
  V1  file parses as JSON and declares fixture_kind / schema_version / owner
  V2  every presentation_id is globally unique within the fixture
  V3  every presentation_id matches the DRAFT env.* scheme from
      BIOME_PRESENTATION_IDENTITY_MATRIX_V1.md §1
  V4  every biome has exactly one beacon and tier looks for tiers 0..4
  V5  every tier look and every memory mark has >= 1 non-hue cue
      (Direction Lock rule R6: no colour-only cue)
  V6  every memory mark count per biome <= 3 (Direction Lock §9.1)
  V7  all cue kinds are in the declared cue_kinds_allowed list
  V8  every shader referenced by a biome is declared in 'shaders' and
      total declared shaders <= 6 (Direction Lock §6)
  V9  fixture_kind == "MOCK" implies a _mock_notice is present
      (ASSET_PIPELINE.md: placeholders must be mechanically detectable)

Exit code 0 = all checks pass; 1 = one or more failures; 2 = usage error.

Usage:
  python3 09_ART_AUDIO/environment/tools/validate_environment_fixtures.py
  python3 09_ART_AUDIO/environment/tools/validate_environment_fixtures.py <path.json> [...]
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]
DEFAULT_FIXTURE_DIR = REPO_ROOT / "09_ART_AUDIO" / "environment" / "fixtures"

ID_PATTERNS = [
    re.compile(r"^env\.biome\.[a-z][a-z0-9_]*$"),
    re.compile(r"^env\.biome\.[a-z][a-z0-9_]*\.beacon$"),
    re.compile(r"^env\.biome\.[a-z][a-z0-9_]*\.tier\.[0-4]$"),
    re.compile(r"^env\.biome\.[a-z][a-z0-9_]*\.memory\.[a-z][a-z0-9_]*$"),
    re.compile(r"^env\.shader\.[a-z][a-z0-9_]*$"),
    re.compile(r"^env\.motif\.[a-z][a-z0-9_]*$"),
]
REQUIRED_TIERS = {0, 1, 2, 3, 4}
MAX_MEMORY_MARKS_PER_BIOME = 3
MAX_MASTER_SHADERS = 6


class Report:
    def __init__(self, path: Path) -> None:
        self.path = path
        self.failures: list[str] = []
        self.passed: list[str] = []

    def fail(self, check: str, msg: str) -> None:
        self.failures.append(f"[{check}] {msg}")

    def ok(self, check: str, msg: str) -> None:
        self.passed.append(f"[{check}] {msg}")


def _matches_scheme(pid: str) -> bool:
    return any(p.match(pid) for p in ID_PATTERNS)


def validate(path: Path) -> Report:
    rep = Report(path)

    # V1 — parse + required top-level fields
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        rep.fail("V1", f"cannot parse JSON: {exc}")
        return rep
    for key in ("fixture_kind", "schema_version", "owner"):
        if key not in data:
            rep.fail("V1", f"missing top-level field '{key}'")
    if data.get("owner") != "AI-05":
        rep.fail("V1", f"owner must be 'AI-05', got {data.get('owner')!r}")
    if not rep.failures:
        rep.ok("V1", f"parsed; fixture_kind={data['fixture_kind']} schema_version={data['schema_version']}")

    # V9 — mock detectability
    if data.get("fixture_kind") == "MOCK":
        if "_mock_notice" in data and isinstance(data["_mock_notice"], str) and data["_mock_notice"].strip():
            rep.ok("V9", "MOCK fixture carries _mock_notice (mechanically detectable)")
        else:
            rep.fail("V9", "fixture_kind is MOCK but _mock_notice is missing/empty")

    allowed_cues = set(data.get("cue_kinds_allowed", []))
    non_hue_cues = set(data.get("non_hue_cue_kinds", []))
    if not allowed_cues or not non_hue_cues:
        rep.fail("V7", "cue_kinds_allowed / non_hue_cue_kinds must be declared and non-empty")
    if "hue" in non_hue_cues:
        rep.fail("V5", "'hue' must not be listed in non_hue_cue_kinds")

    # Collect IDs
    all_ids: list[str] = []
    shaders = data.get("shaders", [])
    shader_ids = {s.get("presentation_id") for s in shaders if isinstance(s, dict)}
    all_ids.extend(sid for sid in shader_ids if sid)

    # V8 — shader count
    if len(shaders) > MAX_MASTER_SHADERS:
        rep.fail("V8", f"{len(shaders)} master shaders declared; limit is {MAX_MASTER_SHADERS}")
    else:
        rep.ok("V8", f"{len(shaders)} master shaders declared (limit {MAX_MASTER_SHADERS})")

    biomes = data.get("biomes", [])
    if not isinstance(biomes, list) or not biomes:
        rep.fail("V4", "no biomes declared")
        biomes = []

    for b in biomes:
        bid = b.get("presentation_id", "<missing>")
        all_ids.append(bid)

        # V4 — beacon
        beacon = b.get("beacon")
        if not isinstance(beacon, dict) or not beacon.get("presentation_id"):
            rep.fail("V4", f"{bid}: missing beacon.presentation_id")
        else:
            all_ids.append(beacon["presentation_id"])

        # V4 — tier coverage
        looks = b.get("tier_looks", [])
        tiers_seen = [l.get("tier") for l in looks]
        if sorted(tiers_seen) != sorted(REQUIRED_TIERS):
            rep.fail("V4", f"{bid}: tier_looks must cover exactly tiers {sorted(REQUIRED_TIERS)}, got {sorted(tiers_seen)}")

        # V5 / V7 — cues on tier looks
        for look in looks:
            lid = look.get("presentation_id", f"{bid}.tier.?")
            all_ids.append(lid)
            cues = set(look.get("cues", []))
            bad = cues - allowed_cues
            if bad:
                rep.fail("V7", f"{lid}: unknown cue kinds {sorted(bad)}")
            if not (cues & non_hue_cues):
                rep.fail("V5", f"{lid}: no non-hue cue (rule R6 violated)")
            # tier in id must match tier field
            m = re.search(r"\.tier\.(\d)$", lid)
            if m and int(m.group(1)) != look.get("tier"):
                rep.fail("V3", f"{lid}: id tier suffix does not match 'tier' field {look.get('tier')}")

        # V5 / V6 / V7 — memory marks
        marks = b.get("memory_marks", [])
        if len(marks) > MAX_MEMORY_MARKS_PER_BIOME:
            rep.fail("V6", f"{bid}: {len(marks)} memory marks; limit is {MAX_MEMORY_MARKS_PER_BIOME}")
        for mark in marks:
            mid = mark.get("presentation_id", f"{bid}.memory.?")
            all_ids.append(mid)
            cues = set(mark.get("cues", []))
            bad = cues - allowed_cues
            if bad:
                rep.fail("V7", f"{mid}: unknown cue kinds {sorted(bad)}")
            if not (cues & non_hue_cues):
                rep.fail("V5", f"{mid}: no non-hue cue (rule R6 violated)")
            if not mark.get("flag_semantic"):
                rep.fail("V5", f"{mid}: missing flag_semantic (must be a pure function of one flag)")

        # V8 — shader references
        for sref in b.get("shaders_used", []):
            if sref not in shader_ids:
                rep.fail("V8", f"{bid}: references undeclared shader {sref!r}")

    # V2 — uniqueness
    dupes = sorted({i for i in all_ids if all_ids.count(i) > 1})
    if dupes:
        rep.fail("V2", f"duplicate presentation_id(s): {dupes}")
    else:
        rep.ok("V2", f"{len(all_ids)} presentation IDs, all unique")

    # V3 — scheme
    off_scheme = sorted({i for i in all_ids if not _matches_scheme(i)})
    if off_scheme:
        rep.fail("V3", f"IDs not matching env.* DRAFT scheme: {off_scheme}")
    else:
        rep.ok("V3", "all IDs match the env.* DRAFT scheme")

    if not any(f.startswith("[V4]") for f in rep.failures):
        rep.ok("V4", f"{len(biomes)} biomes, each with 1 beacon and tiers 0-4")
    if not any(f.startswith("[V5]") for f in rep.failures):
        rep.ok("V5", "every tier look and memory mark has a non-hue cue (R6)")
    if not any(f.startswith("[V6]") for f in rep.failures):
        rep.ok("V6", f"memory marks per biome <= {MAX_MEMORY_MARKS_PER_BIOME}")
    if not any(f.startswith("[V7]") for f in rep.failures):
        rep.ok("V7", "all cue kinds declared")
    return rep


def main(argv: list[str]) -> int:
    if len(argv) > 1:
        paths = [Path(p) for p in argv[1:]]
    else:
        paths = sorted(DEFAULT_FIXTURE_DIR.glob("*.json"))
    if not paths:
        print(f"usage error: no fixture files found in {DEFAULT_FIXTURE_DIR}", file=sys.stderr)
        return 2

    overall_ok = True
    for p in paths:
        rep = validate(p)
        rel = p.resolve().relative_to(REPO_ROOT) if p.resolve().is_relative_to(REPO_ROOT) else p
        print(f"== {rel}")
        for line in rep.passed:
            print(f"   PASS {line}")
        for line in rep.failures:
            print(f"   FAIL {line}")
        status = "OK" if not rep.failures else "FAILED"
        print(f"   RESULT {status} ({len(rep.passed)} passed, {len(rep.failures)} failed)")
        overall_ok = overall_ok and not rep.failures
    return 0 if overall_ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
