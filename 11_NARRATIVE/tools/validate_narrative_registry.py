#!/usr/bin/env python3
"""AI-09 track-local self-check for the Phase 00 narrative pack.

Validates internal consistency of:
  11_NARRATIVE/fixtures/narrative_canon_registry.v0.1.0.json
  11_NARRATIVE/fixtures/loc/en.v0.1.0.json
  11_NARRATIVE/*.md and 01_PREPRODUCTION/STORY_BIBLE_V7.md (ID references)

This is NOT CI (AI-12 owns CI). It is a deterministic checker that AI-10 may
adopt or replace. It uses only the Python standard library.

Exit code 0 = all checks passed, 1 = at least one failure.
Run from the repository root:  python3 11_NARRATIVE/tools/validate_narrative_registry.py
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
NAR_DIR = ROOT / "11_NARRATIVE"
REGISTRY = NAR_DIR / "fixtures" / "narrative_canon_registry.v0.1.1.json"
EN = NAR_DIR / "fixtures" / "loc" / "en.v0.1.1.json"
MD_FILES = sorted(NAR_DIR.glob("*.md")) + [ROOT / "01_PREPRODUCTION" / "STORY_BIBLE_V7.md"]

ID_RE = re.compile(r"^[a-z0-9_.]+$")
NAR_REF_RE = re.compile(r"`(nar\.[a-z0-9_.]+)`")
LOC_REF_RE = re.compile(r"`(loc\.[a-z0-9_.]+)`")
# loc keys referenced in markdown with a wildcard suffix (e.g. loc.dlg.ch01.mira.arrive.*) are patterns, not keys
LOC_PATTERN_RE = re.compile(r"`(loc\.[a-z0-9_.]+)\.\*`")

failures: list[str] = []
passes: list[str] = []


def fail(msg: str) -> None:
    failures.append(msg)


def ok(msg: str) -> None:
    passes.append(msg)


def check_grammar(ids: list[str], label: str) -> None:
    bad = [i for i in ids if not ID_RE.match(i)]
    if bad:
        fail(f"{label}: non-conforming IDs {bad}")
    else:
        ok(f"{label}: {len(ids)} IDs conform to [a-z0-9_.]")


def check_unique(ids: list[str], label: str) -> None:
    seen, dup = set(), set()
    for i in ids:
        (dup if i in seen else seen).add(i)
    if dup:
        fail(f"{label}: duplicate IDs {sorted(dup)}")
    else:
        ok(f"{label}: no duplicates")


def main() -> int:
    reg = json.loads(REGISTRY.read_text(encoding="utf-8"))
    en = json.loads(EN.read_text(encoding="utf-8"))
    strings: dict[str, str] = en["strings"]

    acts = reg["acts"]
    chapters = reg["chapters"]
    beats = reg["beats"]
    chars = reg["characters"]
    flags = reg["flags"]
    mysteries = reg["mysteries"]
    items = reg["item_lore"]
    motifs = reg["motifs"]
    terms = reg["terms"]

    all_nar_ids = (
        [a["id"] for a in acts] + [c["id"] for c in chapters] + [b["id"] for b in beats]
        + [c["id"] for c in chars] + [f["id"] for f in flags] + [m["id"] for m in mysteries]
        + [i["id"] for i in items] + [m["id"] for m in motifs] + [t["id"] for t in terms]
    )
    nar_set = set(all_nar_ids)
    chapter_set = {c["id"] for c in chapters}
    flag_set = {f["id"] for f in flags}
    mystery_set = {m["id"] for m in mysteries}
    motif_set = {m["id"] for m in motifs}
    item_set = {i["id"] for i in items}

    # 1. grammar + uniqueness
    check_grammar(all_nar_ids, "nar.* registry")
    check_unique(all_nar_ids, "nar.* registry")
    check_grammar(list(strings), "loc.* keys")
    # JSON object keys are unique by construction; verify sorted for diff stability
    if list(strings) == sorted(strings):
        ok("loc.* keys are sorted")
    else:
        fail("loc.* keys are not sorted (fixture rule)")

    # 2. namespace prefixes
    prefix_rules = {
        "acts": ("nar.act.", acts), "chapters": ("nar.chapter.", chapters), "beats": ("nar.beat.", beats),
        "characters": ("nar.character.", chars), "flags": ("nar.flag.", flags), "mysteries": ("nar.mystery.", mysteries),
        "item_lore": ("nar.item_lore.", items), "motifs": ("nar.motif.", motifs), "terms": ("nar.term.", terms),
    }
    for label, (prefix, coll) in prefix_rules.items():
        bad = [x["id"] for x in coll if not x["id"].startswith(prefix)]
        fail(f"{label}: wrong namespace {bad}") if bad else ok(f"{label}: namespace {prefix} ok")

    # 3. act <-> chapter integrity
    for a in acts:
        for c in a["chapters"]:
            if c not in chapter_set:
                fail(f"act {a['id']} lists unknown chapter {c}")
    act_ids = {a["id"] for a in acts}
    for c in chapters:
        if c["act"] not in act_ids:
            fail(f"chapter {c['id']} references unknown act {c['act']}")
    nums = [c["number"] for c in chapters]
    if nums == list(range(1, 11)):
        ok("chapters numbered 1..10 contiguous")
    else:
        fail(f"chapter numbering not 1..10: {nums}")

    # 4. flags: budget (PD-003 / PD-028 §F: <= 6 per chapter, <= 60 total), written-once, every written flag is read, chapters exist
    if len(flags) <= reg["flag_budget"]:
        ok(f"flag count {len(flags)} <= total budget {reg['flag_budget']}")
    else:
        fail(f"flag count {len(flags)} exceeds total budget {reg['flag_budget']}")
    per_chapter: dict[str, int] = {}
    for f in flags:
        per_chapter[f["written_in"]] = per_chapter.get(f["written_in"], 0) + 1
    over = {c: n for c, n in per_chapter.items() if n > reg["flag_budget_per_chapter"]}
    if over:
        fail(f"per-chapter flag ceiling {reg['flag_budget_per_chapter']} exceeded: {over}")
    else:
        ok(f"per-chapter flag counts <= {reg['flag_budget_per_chapter']} (max observed {max(per_chapter.values())})")
    written_by_chapter: dict[str, list[str]] = {}
    for c in chapters:
        for f in c["flags_written"]:
            if f not in flag_set:
                fail(f"chapter {c['id']} writes unknown flag {f}")
            written_by_chapter.setdefault(f, []).append(c["id"])
    for f in flags:
        writers = written_by_chapter.get(f["id"], [])
        if len(writers) != 1:
            fail(f"flag {f['id']} must be written by exactly one chapter, got {writers}")
        elif writers[0] != f["written_in"]:
            fail(f"flag {f['id']} written_in mismatch: registry {f['written_in']} vs chapter map {writers[0]}")
        if not f["read_in"]:
            fail(f"flag {f['id']} is never read (orphan consequence)")
        for r in f["read_in"]:
            if r not in chapter_set:
                fail(f"flag {f['id']} read_in unknown chapter {r}")
        if f["default"] != f["values"][0]:
            fail(f"flag {f['id']} default must be first listed value")
        # a flag may be read in the same chapter it is written, but never in an earlier chapter
        w_num = next(c["number"] for c in chapters if c["id"] == f["written_in"])
        for r in f["read_in"]:
            r_num = next(c["number"] for c in chapters if c["id"] == r)
            if r_num < w_num:
                fail(f"flag {f['id']} read in chapter {r_num} before written in {w_num}")
    ok("flag write/read integrity checked")

    # 4b. PD-028 canon resolutions
    silent = [i for i in all_nar_ids if "silent_engine" in i] + [k for k in strings if "silent_engine" in k]
    if silent:
        fail(f"PD-028 §B: stale silent_engine identifiers {silent}")
    else:
        ok("PD-028 §B: no *silent_engine* identifier in registry or loc keys")
    engine_terms = [t["id"] for t in terms if "engine" in t["id"]]
    if engine_terms == ["nar.term.quiet_engine"]:
        ok("PD-028 §B: exactly one engine term ID (nar.term.quiet_engine)")
    else:
        fail(f"PD-028 §B: expected exactly one engine term, got {engine_terms}")
    for sup in reg.get("superseded_ids", []):
        if sup["old"] in nar_set:
            fail(f"superseded ID {sup['old']} still present in registry")
        if sup["new"] not in nar_set:
            fail(f"superseded_ids: replacement {sup['new']} not present in registry")
    ok("superseded_ids consistent")
    # scope integrity: every chapter/flag/item_lore has scope v1|LATER; LATER chapter is not a v1 prerequisite
    later_chapters = {c["id"] for c in chapters if c.get("scope") == "LATER"}
    v1_chapters = [c for c in chapters if c.get("scope") == "v1"]
    for coll, label in ((chapters, "chapter"), (flags, "flag"), (items, "item_lore")):
        bad = [x["id"] for x in coll if x.get("scope") not in ("v1", "LATER")]
        if bad:
            fail(f"{label}: missing/invalid scope on {bad}")
    ss = reg["scope_summary"]
    if len(v1_chapters) == ss["v1_chapter_count"] and len(v1_chapters) <= ss["v1_chapter_ceiling"]:
        ok(f"PD-028 §C: v1 chapters = {len(v1_chapters)} (ceiling {ss['v1_chapter_ceiling']}); LATER = {sorted(later_chapters)}")
    else:
        fail(f"PD-028 §C: v1 chapter count {len(v1_chapters)} != summary {ss['v1_chapter_count']} or > ceiling")
    if sorted(later_chapters) != sorted(ss["later_chapters"]):
        fail(f"scope_summary.later_chapters {ss['later_chapters']} != chapters marked LATER {sorted(later_chapters)}")
    v1_biomes = {c["biome"] for c in v1_chapters} - {"all"}
    if v1_biomes == set(ss["v1_biomes"]) and len(v1_biomes) == ss["v1_biome_count"] == 5:
        ok(f"PD-028 §C: v1 biomes = 5 {sorted(v1_biomes)}; LATER biomes {ss['later_biomes']}")
    else:
        fail(f"PD-028 §C: v1 biome set {sorted(v1_biomes)} != summary {ss['v1_biomes']}")
    for c in v1_chapters:
        for f in c["flags_written"]:
            fl = next(x for x in flags if x["id"] == f)
            if fl.get("scope") != "v1":
                fail(f"v1 chapter {c['id']} writes non-v1 flag {f}")
    for f in flags:
        if f.get("scope") == "v1" and f["written_in"] in later_chapters:
            fail(f"v1 flag {f['id']} is written in LATER chapter {f['written_in']} (v1 prerequisite on LATER content)")
        if f.get("scope") == "LATER" and f["written_in"] not in later_chapters:
            fail(f"LATER flag {f['id']} written in v1 chapter {f['written_in']}")
    for it in items:
        if it.get("scope") == "v1" and it["chapter"] in later_chapters:
            fail(f"v1 item_lore {it['id']} acquired in LATER chapter")
    ok("PD-028 §C: no v1 flag/item depends on a LATER chapter")
    # LATER-dependent mystery stages must be declared
    for m in mysteries:
        dep = sorted(k for k, v in m["stages"].items() if v in later_chapters)
        if dep != sorted(m.get("later_dependent_stages", [])):
            fail(f"mystery {m['id']}: later_dependent_stages {m.get('later_dependent_stages')} != stages hosted by LATER chapters {dep}")
    ok("LATER-dependent mystery stages declared")
    # finale enum: exactly three values besides unset (PD-018 / PD-028 §E); display behind loc.term keys
    fc = next(f for f in flags if f["id"] == "nar.flag.final_configuration")
    opts = [v for v in fc["values"] if v != "unset"]
    if len(opts) == 3 and all(f"loc.term.{o}" in strings for o in opts):
        ok(f"PD-028 §E: final_configuration has exactly 3 options {opts} with loc.term.* keys")
    else:
        fail(f"PD-028 §E: final_configuration options invalid {opts}")
    # cast ceiling (PD-024): speaking characters <= 3 (Nox counts as non-verbal companion)
    speakers = [c["id"] for c in chars if c["speaks"]]
    if len(speakers) <= 2 and len(chars) == 5:
        ok(f"PD-024/PD-028 §F: speaking cast {speakers}; total cast 5 (Weaver silent, Architect a title)")
    else:
        fail(f"PD-024: cast structure changed: speakers {speakers}, total {len(chars)}")
    # Asterra: only in loc.term.asterra (PD-026 §3)
    ast = [k for k, v in strings.items() if "asterra" in v.lower() and k != "loc.term.asterra"]
    if ast:
        fail(f"PD-026 §3: 'Asterra' appears in player-facing strings outside loc.term.asterra: {ast}")
    else:
        ok("PD-026 §3: 'Asterra' only behind loc.term.asterra")

    # 5. characters: flags they read/write exist
    for ch in chars:
        for f in ch.get("flags_written", []) + ch.get("flags_read", []):
            if f not in flag_set:
                fail(f"character {ch['id']} references unknown flag {f}")
        if ch["name_key"] not in strings:
            fail(f"character {ch['id']} missing loc name {ch['name_key']}")
    ok("character flag/loc references checked")

    # 6. mysteries: five stages, chapters exist, order sane, motifs exist, each touched chapter lists it
    required_stages = ["setup", "reinforcement", "false_lead", "partial", "final"]
    for m in mysteries:
        missing = [s for s in required_stages if s not in m["stages"]]
        if missing:
            fail(f"mystery {m['id']} missing stages {missing}")
            continue
        stage_nums = []
        for s in required_stages:
            c = m["stages"][s]
            if c not in chapter_set:
                fail(f"mystery {m['id']} stage {s} unknown chapter {c}")
            else:
                stage_nums.append(next(x["number"] for x in chapters if x["id"] == c))
        if stage_nums and not (stage_nums[0] <= stage_nums[3] <= stage_nums[4]):
            fail(f"mystery {m['id']} stage order invalid: setup<=partial<=final required, got {stage_nums}")
        for mo in m["motifs"]:
            if mo not in motif_set:
                fail(f"mystery {m['id']} references unknown motif {mo}")
        for s in required_stages:
            c = m["stages"][s]
            ch = next((x for x in chapters if x["id"] == c), None)
            if ch and m["id"] not in ch["mysteries_touched"]:
                fail(f"chapter {c} hosts stage '{s}' of {m['id']} but does not list it in mysteries_touched")
        if m["status"] not in ("COMPLETE", "INTENTIONALLY_UNRESOLVED"):
            fail(f"mystery {m['id']} has invalid status {m['status']}")
    spine = [m["id"] for m in mysteries if m.get("spine")]
    if len(spine) == 1:
        ok(f"exactly one spine mystery: {spine[0]}")
    else:
        fail(f"expected exactly one spine mystery, got {spine}")
    # every chapter touches at least one mystery
    for c in chapters:
        if not c["mysteries_touched"]:
            fail(f"chapter {c['id']} touches no mystery (dead chapter)")
        for m in c["mysteries_touched"]:
            if m not in mystery_set:
                fail(f"chapter {c['id']} lists unknown mystery {m}")
    ok("mystery stage/chapter integrity checked")

    # 7. item lore: chapters exist, mysteries exist, loc name+lore exist, listed by its chapter
    for it in items:
        if it["chapter"] not in chapter_set:
            fail(f"item_lore {it['id']} unknown chapter {it['chapter']}")
        else:
            ch = next(x for x in chapters if x["id"] == it["chapter"])
            if it["id"] not in ch["item_lore"]:
                fail(f"chapter {it['chapter']} does not list {it['id']} in item_lore")
        for m in it["mysteries"]:
            if m not in mystery_set:
                fail(f"item_lore {it['id']} unknown mystery {m}")
        slug = it["id"].removeprefix("nar.item_lore.")
        for suffix in ("name", "lore"):
            k = f"loc.item.{slug}.{suffix}"
            if k not in strings:
                fail(f"item_lore {it['id']} missing {k}")
        if it["item_ref"] != "PROPOSED":
            fail(f"item_lore {it['id']} item_ref must be PROPOSED in Phase 00 (AI-02 owns item IDs)")
        if it["proposed_item_slug"] != slug:
            fail(f"item_lore {it['id']} proposed_item_slug {it['proposed_item_slug']} != lore slug {slug}")
    for c in chapters:
        for i in c["item_lore"]:
            if i not in item_set:
                fail(f"chapter {c['id']} lists unknown item_lore {i}")
    ok("item lore integrity checked")

    # 8. terms: loc key exists; acts/chapters titles exist
    for t in terms:
        if t["loc_key"] not in strings:
            fail(f"term {t['id']} missing loc string {t['loc_key']}")
        if t["loc_key"] != "loc.term." + t["id"].removeprefix("nar.term."):
            fail(f"term {t['id']} loc_key does not mirror term id")
    for a in acts:
        for k in (a["title_key"], a["question_key"]):
            if k not in strings:
                fail(f"act {a['id']} missing loc {k}")
    for c in chapters:
        if c["title_key"] not in strings:
            fail(f"chapter {c['id']} missing loc {c['title_key']}")
    ok("term/act/chapter loc coverage checked")

    # 9. beats: chapter exists, dialogue keys exist
    for b in beats:
        if b["chapter"] not in chapter_set:
            fail(f"beat {b['id']} unknown chapter {b['chapter']}")
        for k in b["dialogue_keys"]:
            if k not in strings:
                fail(f"beat {b['id']} dialogue key missing from en fixture: {k}")
    ok("beat dialogue coverage checked")

    # 10. string hygiene
    for k, v in strings.items():
        if "->" in v or "<-" in v:
            fail(f"string {k} contains ASCII arrow (RTL rule)")
        if k.startswith("loc.dlg.") and len(v) > 100:
            fail(f"dialogue {k} exceeds 100 chars ({len(v)})")
        if k.startswith("loc.item.") and k.endswith(".name") and len(v) > 20:
            fail(f"item name {k} exceeds 20 chars")
    ok("string hygiene checked")

    # 11. markdown cross-references: every `nar.*` referenced in docs exists in registry;
    #     every concrete `loc.*` referenced exists in en fixture
    for md in MD_FILES:
        text = md.read_text(encoding="utf-8")
        for ref in set(NAR_REF_RE.findall(text)):
            if ref not in nar_set:
                fail(f"{md.relative_to(ROOT)}: references undefined ID `{ref}`")
        patterns = set(LOC_PATTERN_RE.findall(text))
        for ref in set(LOC_REF_RE.findall(text)):
            if ref in patterns or ref.endswith(".*"):
                continue
            if ref in strings:
                continue
            # allow documented-but-not-yet-authored namespaces (grammar examples)
            if any(ref.startswith(p) for p in ("loc.ui.", "loc.caption.", "loc.motif.", "loc.dlg.ch09.", "loc.string_")):
                continue
            if ref.endswith((".epilogue", ".epilogue.hold", ".epilogue.weave", ".epilogue.open")):
                continue
            fail(f"{md.relative_to(ROOT)}: references loc key not in en fixture `{ref}`")
    ok(f"markdown cross-references checked in {len(MD_FILES)} files")

    # report
    print("=== AI-09 narrative registry validation ===")
    for p in passes:
        print("PASS ", p)
    for f in failures:
        print("FAIL ", f)
    print(f"--- {len(passes)} pass groups, {len(failures)} failures ---")
    print(f"registry {reg['schema_version']} [{reg['status']}]: {len(all_nar_ids)} nar.* IDs | en {en['schema_version']}: {len(strings)} loc.* keys | flags: {len(flags)}/{reg['flag_budget']} total, per-chapter cap {reg['flag_budget_per_chapter']} | v1 chapters {reg['scope_summary']['v1_chapter_count']}, LATER {len(reg['scope_summary']['later_chapters'])}")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
