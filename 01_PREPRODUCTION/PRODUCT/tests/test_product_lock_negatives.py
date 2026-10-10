#!/usr/bin/env python3
"""
test_product_lock_negatives.py — negative/regression tests for validate_product_lock.py.

Proves that the product-lock validator FAILS for the intended reasons (not merely that
the current tree passes). Each case copies the PRODUCT folder into a throwaway root,
introduces exactly one defect, and asserts the validator exits non-zero. The baseline
(unmodified copy) must exit zero.

Usage: python3 01_PREPRODUCTION/PRODUCT/tests/test_product_lock_negatives.py
Exit 0 = all cases behaved as expected.
"""
from __future__ import annotations

import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve()
ROOT = HERE.parents[3]                     # repo root
SRC = ROOT / "01_PREPRODUCTION" / "PRODUCT"
VALIDATOR = SRC / "validate_product_lock.py"

passed = 0
failed = 0


def _run(root: Path) -> int:
    r = subprocess.run([sys.executable, str(VALIDATOR), "--root", str(root)],
                       capture_output=True, text=True)
    return r.returncode


def _stage(tmp: Path) -> Path:
    # The validator resolves cross-folder Markdown links, so the temp root must
    # mirror the whole working tree (minus .git and build outputs).
    shutil.copytree(ROOT, tmp / "repo",
                    ignore=shutil.ignore_patterns(".git", "dist", ".godot", "__pycache__", "android"))
    return tmp / "repo" / "01_PREPRODUCTION" / "PRODUCT"


def _check(name: str, ok: bool) -> None:
    global passed, failed
    if ok:
        passed += 1
        print(f"  PASS: {name}")
    else:
        failed += 1
        print(f"  FAIL: {name}")


def case(name: str, mutate, expect_fail: bool) -> None:
    with tempfile.TemporaryDirectory() as t:
        dst = _stage(Path(t))
        mutate(dst)
        rc = _run(dst.parents[1])
        got_fail = rc != 0
        _check(f"{name} (expected {'FAIL' if expect_fail else 'PASS'}, rc={rc})", got_fail == expect_fail)


def _reg(dst: Path) -> Path:
    return dst / "PRODUCT_DECISION_REGISTER.md"


def _read(p: Path) -> str:
    return p.read_text(encoding="utf-8")


def _write(p: Path, s: str) -> None:
    p.write_text(s, encoding="utf-8")


# Baseline: an unmodified copy must pass.
case("baseline copy passes", lambda dst: None, expect_fail=False)

# Defect 1: break the PD-025 -> PD-030 supersession pointer.
case("removing PD-025 'Superseded by: PD-030' fails",
     lambda dst: _write(_reg(dst), _read(_reg(dst)).replace(
         "**Superseded by:** PD-030 (HUMAN_DECIDED, v1.3.0)", "**Note:** originally decided")),
     expect_fail=True)

# Defect 2: remove the PD-030 entry entirely (and its integrity rule line stays).
def _drop_pd030(dst: Path) -> None:
    s = _read(_reg(dst))
    head, rest = s.split("## PD-030 —", 1)
    _write(_reg(dst), head + "## Register integrity rules" + rest.split("## Register integrity rules", 1)[1])


case("removing PD-030 fails", _drop_pd030, expect_fail=True)

# Defect 3: pin a numeric Godot version inside PRODUCT/ (policy forbids it).
case("pinning 'Godot 4.2' in a PRODUCT doc fails",
     lambda dst: _write(dst / "PRODUCT_LOCK_V1.md",
                        _read(dst / "PRODUCT_LOCK_V1.md") + "\nTested on Godot 4.2 baseline.\n"),
     expect_fail=True)

# Defect 4: strip PD-030's engine statement (loses the Godot lock).
case("PD-030 without 'Godot 4.x stable' fails",
     lambda dst: _write(_reg(dst), _read(_reg(dst)).replace("Godot 4.x stable", "a modern engine")),
     expect_fail=True)

print(f"== product-lock negative tests: {passed} passed, {failed} failed ==")
sys.exit(0 if failed == 0 else 1)
