#!/usr/bin/env python3
"""Validator for the CraftCube `PerformanceBudget` contract fixtures (AI-11 owned).

Contract: 12_PERFORMANCE/contracts/PerformanceBudget.v0.1.0-draft.md
Method:   12_PERFORMANCE/phase_00/MEASUREMENT_METHOD_STANDARD.md

Design rules of this tool
- Standard library only; deterministic; no network; no engine dependency.
- Exit code 0 only when every positive fixture passes AND every negative fixture
  (under `_expect_invalid/`) is rejected. A negative fixture that passes is a
  validator defect and fails the run (Test Integrity Rule: never silently skip).
- The central rule it enforces mechanically: an entry may claim `status: MEASURED`
  only with complete evidence. No evidence -> rejected. `build_id: "UNKNOWN"` -> rejected.

Usage
    python3 12_PERFORMANCE/tools/validate_performance_budget.py            # validate default fixture dir
    python3 12_PERFORMANCE/tools/validate_performance_budget.py FILE.json  # validate one positive file
    python3 12_PERFORMANCE/tools/validate_performance_budget.py --dir DIR  # validate a fixture dir
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Any

SCHEMA_NAME = "PerformanceBudget"
SUPPORTED_MAJOR = 0
TIERS = ["low", "mid", "high"]
ID_RE = re.compile(r"^PERF-[0-9]{3}$")
SCENE_RE = re.compile(r"^perf\.scene\.[a-z0-9_]+$")
SEMVER_RE = re.compile(r"^[0-9]+\.[0-9]+\.[0-9]+$")

CATEGORIES = {"frame_time", "latency", "memory", "rendering", "thermal", "battery", "load", "system", "complexity"}
UNITS = {"ms", "MB", "KB", "B/frame", "count", "ratio", "pct", "none"}
DIRECTIONS = {"max", "min", "exact"}
STATUSES = {"HYPOTHESIS", "MEASURED"}
# Metric names from MEASUREMENT_METHOD_STANDARD.md §3 plus the two contract-level specials.
METRICS = {
    "frame_time_p95_ms", "frame_time_p99_ms", "hitch_count", "max_frame_ms",
    "touch_to_visual_ms", "resident_memory_mb", "texture_memory_mb",
    "managed_alloc_bytes_per_frame", "draw_calls", "cold_start_ms", "load_ms",
    "thermal_status_transitions", "battery_drain_pct_30min", "save_write_block_ms",
    # contract-level entries that are budgets on authored content, not profiler metrics
    "consecutive_frames_over_p95_before_fallback", "realtime_shadow_lights",
    "transient_vfx_systems", "particle_systems_per_beacon", "render_resolution_scale",
    "save_payload_kb", "install_size_mb", "frame_time_delta_ms", "eval_ms", "dispatch_ms",
    # specials
    "method_only", "count",
}
EVIDENCE_REQUIRED = [
    "scene_id", "device_id", "device_tier", "quality_tier", "build_id", "os_version",
    "method_version", "tool", "window_s", "value", "result", "artifact_path", "captured_by", "date",
]
DATE_RE = re.compile(r"^[0-9]{4}-[0-9]{2}-[0-9]{2}$")


class Errors(list):
    def add(self, where: str, msg: str) -> None:
        self.append(f"{where}: {msg}")


def _is_num(v: Any) -> bool:
    return isinstance(v, (int, float)) and not isinstance(v, bool)


def validate_value(v: Any, entry_id: str, tier: str, errs: Errors) -> None:
    where = f"{entry_id}.values.{tier}"
    if _is_num(v):
        if v < 0:
            errs.add(where, "negative budget value")
        return
    if v == "method_only":
        return
    if isinstance(v, list):
        if len(v) != 2 or not all(_is_num(x) for x in v) or v[0] > v[1]:
            errs.add(where, "range must be [min,max] numbers with min <= max")
        return
    errs.add(where, f"unsupported value type {type(v).__name__!r} (number | [min,max] | 'method_only')")


def validate_evidence(ev: Any, entry_id: str, idx: int, entry_scenes: list, errs: Errors) -> None:
    where = f"{entry_id}.evidence[{idx}]"
    if not isinstance(ev, dict):
        errs.add(where, "evidence item must be an object")
        return
    for k in EVIDENCE_REQUIRED:
        if k not in ev or ev[k] in ("", None):
            errs.add(where, f"missing required evidence field {k!r}")
    if ev.get("build_id") == "UNKNOWN":
        errs.add(where, "build_id 'UNKNOWN' is not evidence")
    if ev.get("device_tier") not in TIERS:
        errs.add(where, f"device_tier must be one of {TIERS}")
    if ev.get("quality_tier") not in TIERS:
        errs.add(where, f"quality_tier must be one of {TIERS}")
    if ev.get("result") not in ("PASS", "FAIL"):
        errs.add(where, "result must be PASS or FAIL")
    sid = ev.get("scene_id")
    if isinstance(sid, str) and entry_scenes and sid not in entry_scenes:
        errs.add(where, f"scene_id {sid!r} not in entry scene_ids")
    if "value" in ev and not _is_num(ev["value"]) and not isinstance(ev["value"], list):
        errs.add(where, "value must be numeric (or a list for transition metrics)")
    if "window_s" in ev and not _is_num(ev["window_s"]):
        errs.add(where, "window_s must be numeric")
    d = ev.get("date")
    if isinstance(d, str) and not DATE_RE.match(d):
        errs.add(where, "date must be ISO YYYY-MM-DD")
    mv = ev.get("method_version")
    if isinstance(mv, str) and not SEMVER_RE.match(mv):
        errs.add(where, "method_version must be semver")


def validate_entry(e: Any, idx: int, errs: Errors) -> str | None:
    where = f"entries[{idx}]"
    if not isinstance(e, dict):
        errs.add(where, "entry must be an object")
        return None
    eid = e.get("id")
    if not isinstance(eid, str) or not ID_RE.match(eid):
        errs.add(where, f"id must match {ID_RE.pattern}, got {eid!r}")
        eid_label = f"{where}({eid!r})"
    else:
        eid_label = eid

    for k in ("category", "metric", "unit", "direction", "scene_ids", "gate", "values", "status",
              "rationale", "product_links", "evidence"):
        if k not in e:
            errs.add(eid_label, f"missing required field {k!r}")

    if e.get("category") not in CATEGORIES:
        errs.add(eid_label, f"category must be one of {sorted(CATEGORIES)}")
    if e.get("metric") not in METRICS:
        errs.add(eid_label, f"metric {e.get('metric')!r} not in MEASUREMENT_METHOD_STANDARD §3 / contract specials")
    if e.get("unit") not in UNITS:
        errs.add(eid_label, f"unit must be one of {sorted(UNITS)}")
    if e.get("direction") not in DIRECTIONS:
        errs.add(eid_label, f"direction must be one of {sorted(DIRECTIONS)}")
    if not isinstance(e.get("gate"), bool):
        errs.add(eid_label, "gate must be a boolean")
    if not isinstance(e.get("rationale"), str) or not e.get("rationale", "").strip():
        errs.add(eid_label, "rationale must be a non-empty string")

    links = e.get("product_links")
    if not isinstance(links, list) or not links or not all(isinstance(x, str) and x for x in links):
        errs.add(eid_label, "product_links must be a non-empty list of strings")

    adopted = e.get("adopted_from", [])
    if not isinstance(adopted, list) or not all(isinstance(x, str) for x in adopted):
        errs.add(eid_label, "adopted_from must be a list of strings")

    scenes = e.get("scene_ids")
    if not isinstance(scenes, list) or not all(isinstance(s, str) for s in scenes):
        errs.add(eid_label, "scene_ids must be a list of strings")
        scenes = []
    else:
        for s in scenes:
            if not SCENE_RE.match(s):
                errs.add(eid_label, f"scene_id {s!r} must match {SCENE_RE.pattern}")
        if not scenes and e.get("category") != "complexity":
            errs.add(eid_label, "scene_ids may be empty only for category 'complexity'")

    values = e.get("values")
    if not isinstance(values, dict):
        errs.add(eid_label, "values must be an object keyed by tier")
    else:
        for t in TIERS:
            if t not in values:
                errs.add(eid_label, f"missing budget value for tier {t!r} (budgets have no defaults)")
            else:
                validate_value(values[t], eid_label, t, errs)
        extra = set(values) - set(TIERS)
        if extra:
            errs.add(eid_label, f"unknown tier keys {sorted(extra)} (PERF-033: exactly three tiers)")
        if e.get("metric") == "method_only":
            bad = [t for t in TIERS if values.get(t) != "method_only"]
            if bad:
                errs.add(eid_label, f"metric 'method_only' requires all tier values 'method_only'; got tiers {bad}")

    status = e.get("status")
    if status not in STATUSES:
        errs.add(eid_label, f"status must be one of {sorted(STATUSES)}")
    evidence = e.get("evidence")
    if not isinstance(evidence, list):
        errs.add(eid_label, "evidence must be a list")
        evidence = []
    if status == "MEASURED" and not evidence:
        errs.add(eid_label, "status MEASURED requires non-empty evidence (NO CLAIM WITHOUT EVIDENCE)")
    for i, ev in enumerate(evidence):
        validate_evidence(ev, eid_label, i, scenes, errs)

    return eid if isinstance(eid, str) else None


def validate_document(doc: Any) -> Errors:
    errs = Errors()
    if not isinstance(doc, dict):
        errs.add("root", "document must be a JSON object")
        return errs
    if doc.get("schema") != SCHEMA_NAME:
        errs.add("root.schema", f"must be {SCHEMA_NAME!r}")
    sv = doc.get("schema_version")
    if not isinstance(sv, str) or not SEMVER_RE.match(sv):
        errs.add("root.schema_version", "must be semver string")
    else:
        major = int(sv.split(".")[0])
        if major > SUPPORTED_MAJOR:
            errs.add("root.schema_version", f"MAJOR {major} > supported {SUPPORTED_MAJOR}; refuse (never silently read a newer schema)")
    if not isinstance(doc.get("budget_version"), str) or not doc.get("budget_version"):
        errs.add("root.budget_version", "must be a non-empty string")
    mv = doc.get("method_version")
    if not isinstance(mv, str) or not SEMVER_RE.match(mv):
        errs.add("root.method_version", "must be semver string")
    if doc.get("tiers") != TIERS:
        errs.add("root.tiers", f"must be exactly {TIERS} in order")

    entries = doc.get("entries")
    if not isinstance(entries, list) or not entries:
        errs.add("root.entries", "must be a non-empty list")
        return errs

    seen: dict[str, int] = {}
    any_gate_hypothesis = False
    for i, e in enumerate(entries):
        eid = validate_entry(e, i, errs)
        if eid:
            if eid in seen:
                errs.add(eid, f"duplicate id (first at entries[{seen[eid]}], again at entries[{i}])")
            else:
                seen[eid] = i
        if isinstance(e, dict) and e.get("gate") is True and e.get("status") == "HYPOTHESIS":
            any_gate_hypothesis = True

    bv = doc.get("budget_version", "")
    if any_gate_hypothesis and isinstance(bv, str) and not bv.endswith("-hypothesis"):
        errs.add("root.budget_version", "gate entries are still HYPOTHESIS; budget_version must carry '-hypothesis' suffix")
    return errs


def load(path: Path) -> tuple[Any, str | None]:
    try:
        return json.loads(path.read_text(encoding="utf-8")), None
    except (OSError, json.JSONDecodeError) as ex:
        return None, f"{path}: cannot parse JSON: {ex}"


def run_dir(fixture_dir: Path) -> int:
    positives = sorted(p for p in fixture_dir.glob("*.json"))
    negatives = sorted((fixture_dir / "_expect_invalid").glob("*.json")) if (fixture_dir / "_expect_invalid").is_dir() else []
    if not positives:
        print(f"FAIL: no positive fixtures in {fixture_dir}")
        return 2
    failures = 0
    for p in positives:
        doc, perr = load(p)
        errs = validate_document(doc) if perr is None else Errors([perr])
        if errs:
            failures += 1
            print(f"FAIL  {p.relative_to(fixture_dir.parent.parent)}  ({len(errs)} error(s))")
            for m in errs:
                print(f"      - {m}")
        else:
            n = len(doc["entries"])
            gates = sum(1 for e in doc["entries"] if e.get("gate"))
            measured = sum(1 for e in doc["entries"] if e.get("status") == "MEASURED")
            print(f"PASS  {p.relative_to(fixture_dir.parent.parent)}  entries={n} gate={gates} measured={measured} hypothesis={n - measured}")
    for p in negatives:
        doc, perr = load(p)
        errs = validate_document(doc) if perr is None else Errors([perr])
        if errs:
            print(f"PASS  {p.relative_to(fixture_dir.parent.parent)}  correctly rejected: {errs[0]}")
        else:
            failures += 1
            print(f"FAIL  {p.relative_to(fixture_dir.parent.parent)}  NEGATIVE FIXTURE WAS ACCEPTED (validator defect)")
    print(f"summary: positives={len(positives)} negatives={len(negatives)} failures={failures}")
    return 1 if failures else 0


def main(argv: list[str]) -> int:
    here = Path(__file__).resolve().parent.parent
    default_dir = here / "fixtures" / "performance_budget"
    if len(argv) >= 3 and argv[1] == "--dir":
        return run_dir(Path(argv[2]).resolve())
    if len(argv) == 2:
        p = Path(argv[1]).resolve()
        if p.is_dir():
            return run_dir(p)
        doc, perr = load(p)
        errs = validate_document(doc) if perr is None else Errors([perr])
        if errs:
            print(f"FAIL  {p}")
            for m in errs:
                print(f"      - {m}")
            return 1
        print(f"PASS  {p}  entries={len(doc['entries'])}")
        return 0
    return run_dir(default_dir)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
