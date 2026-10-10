#!/usr/bin/env python3
"""Reproducible test suite for validate_audio_cue_registry.py.

Owner: AI-08. Standard library only.

Runs:
  1. positive case — the committed DRAFT fixture must validate (exit 0);
  2. negative cases — deterministic mutations of the fixture, each of which must
     be rejected with exit code 1 and a specific error substring;
  3. malformed input — must exit 2.

Never weakens the validator: every negative case asserts the *reason* text,
not just a non-zero exit.

Usage:
    python3 09_ART_AUDIO/AUDIO/scripts/test_validate_audio_cue_registry.py
Exit code 0 when all cases pass, 1 otherwise.
"""
from __future__ import annotations

import copy
import json
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
VALIDATOR = HERE / "validate_audio_cue_registry.py"
FIXTURE = HERE.parent / "fixtures" / "audio_cue_registry_draft.v0.1.0.json"


def run(path: Path, *extra: str) -> tuple[int, str, str]:
    r = subprocess.run(
        [sys.executable, str(VALIDATOR), str(path), *extra],
        capture_output=True, text=True,
    )
    return r.returncode, r.stdout, r.stderr


def find_cue(doc: dict, cue_id: str) -> dict:
    for c in doc["cues"]:
        if c["cueId"] == cue_id:
            return c
    raise KeyError(cue_id)


def negative_cases(src: dict) -> list[tuple[str, dict, str]]:
    cases: list[tuple[str, dict, str]] = []

    d = copy.deepcopy(src); d["cues"].append(copy.deepcopy(d["cues"][0]))
    cases.append(("duplicate cueId", d, "duplicate cueId"))

    d = copy.deepcopy(src); d["motifs"].append(copy.deepcopy(d["motifs"][0]))
    cases.append(("duplicate motifId", d, "duplicate motifId"))

    d = copy.deepcopy(src); find_cue(d, "audio.puzzle.move.committed")["requiresNonAudioEquivalent"] = False
    cases.append(("P0 without non-audio equivalent", d, "P0_PUZZLE_CRITICAL cues must set requiresNonAudioEquivalent=true"))

    d = copy.deepcopy(src); find_cue(d, "audio.story.reveal.immediate")["requiresNonAudioEquivalent"] = False
    cases.append(("P1 without non-audio equivalent", d, "P1_NARRATIVE cues must set requiresNonAudioEquivalent=true"))

    d = copy.deepcopy(src); find_cue(d, "audio.puzzle.move.committed")["variationStrategy"] = "none"
    cases.append(("high-rate cue with variation=none", d, "requires a variationStrategy other than 'none'"))

    d = copy.deepcopy(src); find_cue(d, "audio.puzzle.solve.completed")["motifRef"] = "motif.does_not_exist"
    cases.append(("undeclared motifRef", d, "not declared in motifs"))

    d = copy.deepcopy(src); find_cue(d, "audio.puzzle.move.committed")["cueId"] = "game.puzzle.move.committed"
    cases.append(("wrong root (game.*)", d, "does not match grammar"))

    d = copy.deepcopy(src); find_cue(d, "audio.puzzle.move.committed")["cueId"] = "audio.item.acquired"
    cases.append(("too few segments", d, "does not match grammar"))

    d = copy.deepcopy(src); find_cue(d, "audio.puzzle.move.committed")["cueId"] = "audio.combat.move.committed"
    cases.append(("disallowed domain", d, "domain 'combat' not in"))

    d = copy.deepcopy(src); find_cue(d, "audio.puzzle.move.committed")["bus"] = "Music"
    cases.append(("P0 on non-PuzzleCritical bus", d, "requires bus in ['PuzzleCritical']"))

    d = copy.deepcopy(src); find_cue(d, "audio.puzzle.move.committed")["status"] = "released"
    cases.append(("released record inside DRAFT registry", d, "not allowed inside a DRAFT registry"))

    d = copy.deepcopy(src); del find_cue(d, "audio.puzzle.move.committed")["description"]
    cases.append(("missing required field", d, "missing field 'description'"))

    d = copy.deepcopy(src); d["schemaVersion"] = "0.1"
    cases.append(("non-semver schemaVersion", d, "is not semver"))

    d = copy.deepcopy(src); d["owner"] = "AI-06"
    cases.append(("wrong owner", d, "owner must be 'AI-08'"))

    d = copy.deepcopy(src); d["contractId"] = "CC.AUDIO.OTHER"
    cases.append(("wrong contractId", d, "contractId must be 'CC.AUDIO.CUE'"))

    return cases


def main() -> int:
    failures = 0
    total = 0

    # 1. positive
    total += 1
    code, out, err = run(FIXTURE, "--expect-status", "DRAFT")
    if code == 0 and out.startswith("OK:"):
        print(f"[PASS] positive: committed fixture validates\n       {out.strip()}")
    else:
        failures += 1
        print(f"[FAIL] positive: exit={code}\n{err}")

    # 2. negatives
    src = json.loads(FIXTURE.read_text(encoding="utf-8"))
    with tempfile.TemporaryDirectory() as tmp:
        for i, (name, doc, expected) in enumerate(negative_cases(src)):
            total += 1
            p = Path(tmp) / f"neg_{i}.json"
            p.write_text(json.dumps(doc), encoding="utf-8")
            code, out, err = run(p)
            if code == 1 and expected in err:
                print(f"[PASS] negative: {name}")
            else:
                failures += 1
                print(f"[FAIL] negative: {name} — exit={code}, expected substring {expected!r}\n{err}")

        # 3. malformed
        total += 1
        bad = Path(tmp) / "bad.json"
        bad.write_text("{ not json", encoding="utf-8")
        code, out, err = run(bad)
        if code == 2:
            print("[PASS] malformed JSON exits 2")
        else:
            failures += 1
            print(f"[FAIL] malformed JSON exit={code}")

    print(f"\n{total - failures}/{total} cases passed")
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
