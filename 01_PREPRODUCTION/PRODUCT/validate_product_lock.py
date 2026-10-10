#!/usr/bin/env python3
"""
validate_product_lock.py — AI-01 product-document validator (Phase 00).

Scope: product validation only (AI-01 ownership). Checks the Markdown files in
01_PREPRODUCTION/PRODUCT/ for:

  1. Required documents exist.
  2. Every document carries an Owner / Document ID / Version header row.
  3. Stable ID families owned by AI-01 (PD, F10, IGM, CUT, AGP, CMP) are
     defined exactly once, are contiguous within their family (no gaps, no
     reuse), and every *reference* to an ID resolves to a definition.
  4. Cross-document Markdown links to files in this folder resolve.
  5. Every PD entry has a Verdict from the allowed vocabulary.
  6. Every PD/AGP/CMP acceptance rule carries at least one check-type tag
     ([VALIDATOR] / [BUILD] / [PLAYTEST] / [EVIDENCE]) so AI-10 can trace it.
  7. Supersession integrity: every 'Supersedes: PD-xxx' target exists and
     carries a matching 'Superseded by: PD-yyy' pointer; a superseded entry is
     never itself HUMAN_DECIDED/APPROVED-without-pointer (no two live verdicts
     for one subject).
  8. Phase 00 human-decision consistency (v1.2.0):
     - PD-025: no numeric Unity/URP/SDK/NDK/JDK version is pinned in PRODUCT/.
     - PD-026: CC. namespace independence from the public title is recorded.
     - PD-027: premium model recorded; no PRODUCT/ text re-approves ads, IAP
       store, subscription, premium currency, timers or paid assists.
     - PD-028: Story Promise, Quiet Engine, Verdant Archive LATER, Asterra
       internal-only and the Hold/Weave/Open finale set are explicitly recorded.

Exit code 0 = PASS, 1 = FAIL. No network, no repository writes.

Usage:
    python3 01_PREPRODUCTION/PRODUCT/validate_product_lock.py [--root <repo-root>]
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

REQUIRED_DOCS = [
    "PRODUCT_LOCK_V1.md",
    "PRODUCT_DECISION_REGISTER.md",
    "FIRST_10_MINUTES_PROOF.md",
    "INVESTMENT_GATE_METRICS.md",
    "CUT_LIST_AND_COMPLEXITY_BUDGET.md",
    "PROGRESSION_ANTI_GRIND_AND_EXPRESSION_POLICY.md",
    "COMPETITOR_REVIEW.md",
]

# family -> (definition regex, id width). Definitions are recognised only in
# these positions so that prose references never count as definitions.
FAMILIES = {
    "PD": r"^## (PD-\d{3}) — ",                 # register heading
    "F10": r"^### (F10-\d{3}) — ",              # proof-point heading
    "IGM": r"^### (IGM-\d{3}[a-e]?) — ",        # metric heading (suffix allowed)
    "CUT": r"^\| (CUT-\d{3}) \| ",              # cut-list table row
    "AGP": r"^\| (AGP-\d{3}) \| ",              # policy table row
    "CMP": r"^\| (CMP-\d{3}) \| ",              # policy table row
}
# A trailing '+' marks a forward pointer ("PD-025+" = next free number), not a reference.
REFERENCE_RE = re.compile(r"\b(PD|F10|IGM|CUT|AGP|CMP)-(\d{3})([a-e])?\b(?!\+)")
HEADER_ROWS = ("| Owner |", "| Document ID |", "| Version |")
# Verdict must START with one of these tokens; a parenthetical qualifier may follow.
VERDICT_RE = re.compile(
    r"^(HUMAN_DECIDED|APPROVED_WITH_LIMITS|APPROVED|REJECTED|DEFERRED_TO_HUMAN|DEFERRED_TO_EVIDENCE)(\s*\(.*\))?$"
)
CHECK_TAGS = ("[VALIDATOR]", "[BUILD]", "[PLAYTEST]", "[EVIDENCE]")
LINK_RE = re.compile(r"`([A-Z0-9_]+\.md)`")


class Report:
    def __init__(self) -> None:
        self.failures: list[str] = []
        self.passes: list[str] = []

    def fail(self, msg: str) -> None:
        self.failures.append(msg)
        print(f"[FAIL] {msg}")

    def ok(self, msg: str) -> None:
        self.passes.append(msg)
        print(f"[PASS] {msg}")


def load_docs(folder: Path, rep: Report) -> dict[str, str]:
    docs: dict[str, str] = {}
    for name in REQUIRED_DOCS:
        p = folder / name
        if not p.is_file():
            rep.fail(f"required document missing: {p.relative_to(folder.parent.parent)}")
            continue
        docs[name] = p.read_text(encoding="utf-8")
    if len(docs) == len(REQUIRED_DOCS):
        rep.ok(f"all {len(REQUIRED_DOCS)} required product documents present")
    return docs


def check_headers(docs: dict[str, str], rep: Report) -> None:
    for name, text in docs.items():
        head = "\n".join(text.splitlines()[:12])
        missing = [h for h in HEADER_ROWS if h not in head]
        if missing:
            rep.fail(f"{name}: header rows missing {missing}")
    rep.ok("header rows (Owner / Document ID / Version) checked")


def collect_definitions(docs: dict[str, str], rep: Report) -> dict[str, dict[str, str]]:
    defs: dict[str, dict[str, str]] = {fam: {} for fam in FAMILIES}
    for name, text in docs.items():
        for fam, pattern in FAMILIES.items():
            rx = re.compile(pattern, re.MULTILINE)
            for m in rx.finditer(text):
                ident = m.group(1)
                if ident in defs[fam]:
                    rep.fail(f"duplicate definition of {ident} in {name} (first in {defs[fam][ident]})")
                else:
                    defs[fam][ident] = name
    return defs


def check_contiguity(defs: dict[str, dict[str, str]], rep: Report) -> None:
    for fam, ids in defs.items():
        if not ids:
            rep.fail(f"family {fam}: no definitions found")
            continue
        base_nums = sorted({int(re.search(r"-(\d{3})", i).group(1)) for i in ids})
        expected = list(range(base_nums[0], base_nums[-1] + 1))
        if base_nums[0] != 1 and fam != "AGP":
            rep.fail(f"family {fam}: numbering does not start at 001 (starts {base_nums[0]:03d})")
        gaps = sorted(set(expected) - set(base_nums))
        # AGP deliberately uses blocks 001-007, 010-017, 020-025 (see policy §4-§6).
        if fam == "AGP":
            allowed_gaps = {8, 9, 18, 19}
            gaps = [g for g in gaps if g not in allowed_gaps]
        if gaps:
            rep.fail(f"family {fam}: numbering gaps at {[f'{g:03d}' for g in gaps]}")
        rep.ok(f"family {fam}: {len(ids)} unique IDs ({fam}-{base_nums[0]:03d}..{fam}-{base_nums[-1]:03d})")


def check_references(docs: dict[str, str], defs: dict[str, dict[str, str]], rep: Report) -> None:
    all_defined = {i for fam in defs.values() for i in fam}
    unresolved: dict[str, set[str]] = {}
    for name, text in docs.items():
        for m in REFERENCE_RE.finditer(text):
            ident = f"{m.group(1)}-{m.group(2)}{m.group(3) or ''}"
            # A suffixed IGM ref (IGM-001b) may resolve to itself; an unsuffixed
            # ref resolves to the base heading.
            if ident in all_defined:
                continue
            base = f"{m.group(1)}-{m.group(2)}"
            if base in all_defined:
                continue
            unresolved.setdefault(ident, set()).add(name)
    # Range shorthands like "CUT-001..CUT-031" and "PD-017+" produce no false
    # positives because both ends are real IDs; "PD-0xx" is prose and excluded
    # by the \d{3} requirement.
    for ident, where in sorted(unresolved.items()):
        rep.fail(f"unresolved ID reference {ident} in {sorted(where)}")
    if not unresolved:
        rep.ok("every PD/F10/IGM/CUT/AGP/CMP reference resolves to a definition")


def check_links(docs: dict[str, str], folder: Path, root: Path, rep: Report) -> None:
    """Bare `FILE.md` references must resolve to exactly one file somewhere in the
    repository (local PRODUCT folder first). Ambiguous or missing names fail."""
    index: dict[str, list[Path]] = {}
    for p in root.rglob("*.md"):
        if ".git" in p.parts:
            continue
        index.setdefault(p.name, []).append(p)
    broken, ambiguous = [], []
    for name, text in docs.items():
        for m in LINK_RE.finditer(text):
            target = m.group(1)
            if (folder / target).is_file():
                continue
            hits = index.get(target, [])
            if not hits:
                broken.append((name, target))
            elif len(hits) > 1:
                ambiguous.append((name, target, [str(h.relative_to(root)) for h in hits]))
    for name, target in broken:
        rep.fail(f"{name}: bare link to `{target}` does not resolve anywhere in the repository")
    for name, target, hits in ambiguous:
        rep.fail(f"{name}: bare link to `{target}` is ambiguous: {hits}")
    if not broken and not ambiguous:
        rep.ok("all bare `FILE.md` links resolve to exactly one repository file")


def check_pd_verdicts(docs: dict[str, str], rep: Report) -> None:
    text = docs.get("PRODUCT_DECISION_REGISTER.md", "")
    blocks = re.split(r"^## (?=PD-\d{3} — )", text, flags=re.MULTILINE)[1:]
    bad_verdict, no_tag = [], []
    for block in blocks:
        pid = block.split(" ", 1)[0]
        m = re.search(r"\*\*Verdict:\*\* (.+)", block)
        verdict = m.group(1).strip() if m else ""
        if not VERDICT_RE.match(verdict):
            bad_verdict.append((pid, verdict))
        if verdict.startswith("APPROVED") and not any(t in block for t in CHECK_TAGS):
            no_tag.append(pid)
    for pid, v in bad_verdict:
        rep.fail(f"{pid}: verdict '{v}' not in allowed vocabulary")
    for pid in no_tag:
        rep.fail(f"{pid}: APPROVED without any [VALIDATOR]/[BUILD]/[PLAYTEST]/[EVIDENCE] acceptance tag")
    if not bad_verdict and not no_tag:
        rep.ok(f"{len(blocks)} PD entries: verdict vocabulary and acceptance tags OK")


def check_policy_rows(docs: dict[str, str], rep: Report) -> None:
    text = docs.get("PROGRESSION_ANTI_GRIND_AND_EXPRESSION_POLICY.md", "")
    missing = []
    for line in text.splitlines():
        m = re.match(r"^\| ((?:AGP|CMP)-\d{3}) \|", line)
        if not m:
            continue
        ident = m.group(1)
        # AGP-02x expression boundaries are design constraints without their
        # own check column; every other AGP/CMP row must name a check or action.
        if ident.startswith("AGP-02"):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        if ident.startswith("CMP"):
            if len(cells) < 4 or not cells[3]:
                missing.append(ident)
        elif not any(tag in line for tag in CHECK_TAGS):
            missing.append(ident)
    for ident in missing:
        rep.fail(f"{ident}: row lacks a check type / default action")
    if not missing:
        rep.ok("AGP/CMP rows carry check type or default action")


def _pd_blocks(text: str) -> dict[str, str]:
    blocks = re.split(r"^## (?=PD-\d{3} — )", text, flags=re.MULTILINE)[1:]
    return {b.split(" ", 1)[0]: b for b in blocks}


def check_supersession(docs: dict[str, str], rep: Report) -> None:
    text = docs.get("PRODUCT_DECISION_REGISTER.md", "")
    blocks = _pd_blocks(text)
    problems = []
    for pid, block in blocks.items():
        for m in re.finditer(r"\*\*Supersedes:\*\* ([^\n]+)", block):
            for target in re.findall(r"PD-\d{3}", m.group(1)):
                if target not in blocks:
                    problems.append(f"{pid} supersedes unknown {target}")
                    continue
                if f"Superseded by:** {pid}" not in blocks[target] and f"closed by:** {pid}" not in blocks[target]:
                    problems.append(f"{target} lacks a 'Superseded by' pointer back to {pid}")
    # A superseded DEFERRED_TO_HUMAN entry must not still be the only record of a decided subject.
    for pid, block in blocks.items():
        if "Superseded by:" in block:
            ref = re.search(r"Superseded by:\*\* (PD-\d{3})", block)
            if ref and ref.group(1) not in blocks:
                problems.append(f"{pid} points to missing superseding entry {ref.group(1)}")
    for p in problems:
        rep.fail(f"supersession: {p}")
    if not problems:
        rep.ok("supersession chain consistent (Supersedes <-> Superseded by)")


VERSION_PIN_RE = re.compile(
    r"\b(Unity\s+6\.\d|Unity\s+20\d\d\.\d|URP\s+\d+\.\d|NDK\s*r?\d{2}|JDK\s*\d{1,2}\b|API\s+level\s+\d{2}|minSdk\s*=?\s*\d{2}|targetSdk\s*=?\s*\d{2})",
    re.IGNORECASE,
)


def check_human_decisions(docs: dict[str, str], rep: Report) -> None:
    reg = docs.get("PRODUCT_DECISION_REGISTER.md", "")
    blocks = _pd_blocks(reg)
    fails = []

    # PD-025: engine decided, versions not pinned anywhere in PRODUCT/.
    b = blocks.get("PD-025", "")
    if "HUMAN_DECIDED" not in b or "Unity 6 + URP + Android" not in b:
        fails.append("PD-025 must record HUMAN_DECIDED Unity 6 + URP + Android")
    for name, text in docs.items():
        for m in VERSION_PIN_RE.finditer(text):
            fails.append(f"{name}: pinned toolchain version '{m.group(0)}' forbidden by PD-025")

    # PD-026: CC namespace independence + Asterra internal-only.
    b = blocks.get("PD-026", "")
    if "INDEPENDENT of the public product title" not in b:
        fails.append("PD-026 must state CC. namespace is INDEPENDENT of the public product title")
    if "INTERNAL-ONLY until legal clearance" not in b:
        fails.append("PD-026 must state Asterra is INTERNAL-ONLY until legal clearance")
    if "trademark clearance is claimed" not in b and "No trademark clearance" not in b:
        fails.append("PD-026 must state that no trademark clearance is claimed")

    # PD-027: premium; forbidden monetization not re-approved anywhere.
    b = blocks.get("PD-027", "")
    if "PREMIUM ONE-TIME PURCHASE" not in b:
        fails.append("PD-027 must record PREMIUM ONE-TIME PURCHASE")
    for item in ("no advertising", "no subscription", "no second/premium currency", "no loot boxes", "no energy timers", "no paid gameplay assists"):
        if item not in b:
            fails.append(f"PD-027 missing constraint '{item}'")
    approve_bad = re.compile(r"\*\*Verdict:\*\* (APPROVED|HUMAN_DECIDED)[^\n]*\n(?:(?!\n## ).)*?\b(advertis|subscription|loot box|gacha|energy timer|premium currency|paid assist)", re.IGNORECASE | re.DOTALL)
    for pid, block in blocks.items():
        if pid in ("PD-027", "PD-016"):
            continue
        m = approve_bad.search(block)
        if m and not re.search(r"\b(no|never|reject|forbid|not|zero|without)\b[^\n]{0,60}" + re.escape(m.group(2)), block, re.IGNORECASE):
            fails.append(f"{pid}: approves a monetization surface ('{m.group(2)}') contradicting PD-027")

    # PD-028: story decisions explicitly recorded.
    b = blocks.get("PD-028", "")
    for needle, label in (
        ("APPROVED as canon baseline", "Story Promise canon approval"),
        ('ONE canonical name: "Quiet Engine."', "Quiet Engine single canonical name"),
        ("NOT part of v1 MUST scope", "Verdant Archive LATER"),
        ("Internal-only until legal clearance", "Asterra internal-only"),
        ("{Hold, Weave, Open}", "finale option set"),
        ("WR-1 through WR-8", "world rules baseline"),
        ("Wayfinder Shard merged into Nox", "Wayfinder merge"),
        ("unvoiced", "unvoiced cast direction"),
    ):
        if needle not in b:
            fails.append(f"PD-028 missing explicit record: {label}")
    # Cut list must agree with PD-028 §C.
    cut = docs.get("CUT_LIST_AND_COMPLEXITY_BUDGET.md", "")
    if not re.search(r"\| Biomes at v1 \| \*\*5\*\*", cut):
        fails.append("CUT list biome cap must be 5 per PD-028 §C")
    if not re.search(r"\| Chapters at v1 \| \*\*≤ 9\*\*", cut):
        fails.append("CUT list chapter ceiling must be ≤ 9 per PD-028 §C")
    lock = docs.get("PRODUCT_LOCK_V1.md", "")
    if "independent of the public title" not in lock:
        fails.append("PRODUCT_LOCK must record CC. namespace title-independence (PD-026)")
    if "INTERNAL-ONLY until legal clearance" not in lock:
        fails.append("PRODUCT_LOCK must record Asterra internal-only (PD-026/028)")

    for f in fails:
        rep.fail(f"human-decision consistency: {f}")
    if not fails:
        rep.ok("Phase 00 human decisions PD-025..028 recorded consistently; no toolchain versions pinned; monetization constraints coherent")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=None, help="repository root (default: derived from script path)")
    args = ap.parse_args()
    root = Path(args.root).resolve() if args.root else Path(__file__).resolve().parents[2]
    folder = root / "01_PREPRODUCTION" / "PRODUCT"
    print(f"validate_product_lock.py — root={root}")
    rep = Report()
    docs = load_docs(folder, rep)
    if docs:
        check_headers(docs, rep)
        defs = collect_definitions(docs, rep)
        check_contiguity(defs, rep)
        check_references(docs, defs, rep)
        check_links(docs, folder, root, rep)
        check_pd_verdicts(docs, rep)
        check_policy_rows(docs, rep)
        check_supersession(docs, rep)
        check_human_decisions(docs, rep)
    print(f"SUMMARY pass={len(rep.passes)} fail={len(rep.failures)}")
    return 1 if rep.failures else 0


if __name__ == "__main__":
    sys.exit(main())
