#!/usr/bin/env python3
"""AI-03 Phase 00 content validator (deterministic, stdlib-only).

Validates the DRAFT v0.1.0 fixtures under tracks/ai-03-puzzle-content/fixtures/phase00/ against the design rules
written in tracks/ai-03-puzzle-content/phase_00/*.md. It is an authoring-time tool; it is NOT the runtime solver and
does NOT claim reachability or par verification (those need the AI-02 engine, Phase 03).

Usage:
    python3 validate_phase00_content.py [--fixtures DIR] [--json]
Exit code 0 = all checks pass, 1 = one or more violations, 2 = fixture load error.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

# --------------------------------------------------------------------------------------------------------------------
# Canonical vocabularies (mirror phase_00/01, 02, 03 docs). Changing these is a design change, not a code fix.
# --------------------------------------------------------------------------------------------------------------------
OBJECTIVE_FAMILIES = {
    "objective.align", "objective.pattern", "objective.sequence",
    "objective.stabilize", "objective.plan", "objective.compose",
}
CHALLENGE_CONDITIONS = {
    "challenge.standard", "challenge.limited_assist", "challenge.move_efficiency", "challenge.time",
    "challenge.world_state", "challenge.resonance", "challenge.discovery", "challenge.companion",
}
TILE_TYPES = {"tile.standard", "tile.anchor", "tile.resonant", "tile.veiled", "tile.fractured", "tile.seed"}
LEVEL_RULES = {"rule.axis_lock", "rule.layer_lock", "rule.fog", "rule.fracture_cost", "rule.move_budget", "rule.tile_placement"}
TOPOLOGIES = {"topology.cube.2", "topology.cube.3"}
TIERS = ["T0", "T1", "T2", "T3", "T4"]
SIGNATURE_REFS = {"introduce", "practice", "twist", "test"}
REWARD_CLASSES = {
    "reward_class.knowledge", "reward_class.capability", "reward_class.world_change",
    "reward_class.narrative", "reward_class.collection", "reward_class.expression", "reward_class.resource",
}
DISCOVERY_CATEGORIES = {
    "visual_secret", "puzzle_state_secret", "environmental_secret", "companion_secret",
    "item_memory_secret", "alternate_world_state", "mastery_secret",
}
DISCOVERY_LAYERS = {"surface", "curious", "mastery", "systemic"}
FACES = {"U", "D", "L", "R", "F", "B"}
AXES = {"X", "Y", "Z"}

ID_RE = {
    "chapter": re.compile(r"^chapter\.\d{2}\.[a-z0-9_]+$"),
    "level": re.compile(r"^level\.\d{2}\.[a-z0-9_]+$"),
    "reward": re.compile(r"^reward\.\d{2}\.[a-z0-9_]+$"),
    "discovery": re.compile(r"^discovery\.\d{2}\.[a-z0-9_]+$"),
}
DRAFT_VERSION = "0.1.0"


class Report:
    def __init__(self) -> None:
        self.errors: list[str] = []
        self.warnings: list[str] = []
        self.metrics: dict[str, object] = {}

    def err(self, msg: str) -> None:
        self.errors.append(msg)

    def warn(self, msg: str) -> None:
        self.warnings.append(msg)


def load(path: Path, rep: Report) -> dict | None:
    try:
        with path.open("r", encoding="utf-8") as fh:
            return json.load(fh)
    except FileNotFoundError:
        rep.err(f"MISSING fixture: {path}")
    except json.JSONDecodeError as exc:
        rep.err(f"INVALID JSON in {path}: {exc}")
    return None


def check_envelope(doc: dict, expected_schema: str, name: str, rep: Report) -> None:
    if doc.get("schema_id") != expected_schema:
        rep.err(f"{name}: schema_id must be {expected_schema}, got {doc.get('schema_id')!r}")
    if doc.get("schema_version") != DRAFT_VERSION:
        rep.err(f"{name}: schema_version must be {DRAFT_VERSION}, got {doc.get('schema_version')!r}")
    if doc.get("status") != "DRAFT":
        rep.err(f"{name}: status must be DRAFT in Phase 00 (no contract is RELEASED), got {doc.get('status')!r}")
    if doc.get("owner") != "AI-03":
        rep.err(f"{name}: owner must be AI-03, got {doc.get('owner')!r}")


def chapter_num(cid: str) -> int:
    return int(cid.split(".")[1])


# --------------------------------------------------------------------------------------------------------------------
# Chapter rules R1-R4 (phase_00/05_CHAPTER_ANTI_REPETITION_STRATEGY.md)
# --------------------------------------------------------------------------------------------------------------------
def validate_chapters(doc: dict, rep: Report) -> dict[str, dict]:
    chapters = doc.get("chapters", [])
    by_id: dict[str, dict] = {}
    seen_all: set[str] = set()
    prev_pair: tuple[str, str] | None = None
    prev_ord = 0
    for ch in sorted(chapters, key=lambda c: c.get("ordinal", 0)):
        cid = ch.get("chapter_id", "")
        if not ID_RE["chapter"].match(cid):
            rep.err(f"chapter id malformed: {cid!r}")
            continue
        if cid in by_id:
            rep.err(f"DUPLICATE chapter_id {cid}")
        by_id[cid] = ch
        if chapter_num(cid) != ch.get("ordinal"):
            rep.err(f"{cid}: ordinal {ch.get('ordinal')} != id number {chapter_num(cid)}")
        if ch.get("ordinal") != prev_ord + 1:
            rep.err(f"{cid}: ordinals must be contiguous from 1 (got {ch.get('ordinal')} after {prev_ord})")
        prev_ord = ch.get("ordinal", prev_ord)

        fam = ch.get("primary_family")
        if fam not in OBJECTIVE_FAMILIES:
            rep.err(f"{cid}: unknown primary_family {fam!r}")

        intro = ch.get("signature", {}).get("introduces", {})
        recomb = ch.get("signature", {}).get("recombines", [])
        intro_fams = intro.get("objective_families", [])
        intro_tiles = intro.get("tile_types", [])
        intro_rules = intro.get("level_rules", [])
        intro_topo = intro.get("topologies", [])
        for x in intro_fams:
            if x not in OBJECTIVE_FAMILIES:
                rep.err(f"{cid}: introduces unknown family {x!r}")
        for x in intro_tiles:
            if x not in TILE_TYPES:
                rep.err(f"{cid}: introduces unknown tile type {x!r}")
        for x in intro_rules:
            if x not in LEVEL_RULES:
                rep.err(f"{cid}: introduces unknown level rule {x!r}")
        for x in intro_topo:
            if x not in TOPOLOGIES:
                rep.err(f"{cid}: introduces unknown topology {x!r}")

        introduced = set(intro_fams) | set(intro_tiles) | set(intro_rules) | set(intro_topo)
        origin = bool(ch.get("origin_chapter"))

        # R1: exactly one new signature element (topologies and tile.standard are enablers, not signatures)
        sig_elems = introduced - set(intro_topo) - {"tile.standard"}
        if not origin and len(sig_elems) == 0:
            rep.err(f"{cid}: R1 violated - chapter introduces nothing new")
        if introduced & seen_all:
            rep.err(f"{cid}: R1 violated - re-introduces already-introduced element(s) {sorted(introduced & seen_all)}")

        # R4: bounded novelty (origin chapter exempt)
        if not origin:
            if len(intro_fams) > 1:
                rep.err(f"{cid}: R4 violated - introduces {len(intro_fams)} objective families (max 1)")
            if len(intro_tiles) > 1:
                rep.err(f"{cid}: R4 violated - introduces {len(intro_tiles)} tile types (max 1)")
            if len(intro_rules) > 1:
                rep.err(f"{cid}: R4 violated - introduces {len(intro_rules)} level rules (max 1)")

        # R3: recombination of earlier signatures (non-origin)
        if not origin:
            if not recomb:
                rep.err(f"{cid}: R3 violated - non-origin chapter recombines nothing")
            for x in recomb:
                if x not in seen_all:
                    rep.err(f"{cid}: R3 violated - recombines {x!r} which no earlier chapter introduced")
        elif recomb:
            rep.err(f"{cid}: origin chapter must not list recombines")

        # R2 (refined, DECISION REQUEST AI03-D1): consecutive chapters may not share (primary_family, signature) pair
        sig_key = ",".join(sorted(sig_elems)) if sig_elems else "<none>"
        pair = (fam, sig_key)
        if prev_pair is not None and pair == prev_pair:
            rep.err(f"{cid}: R2 violated - identical (primary_family, signature) to previous chapter")
        prev_pair = pair

        if not ch.get("world_verb"):
            rep.err(f"{cid}: world_verb is required (R5 authored field)")

        seen_all |= introduced

    rep.metrics["chapters"] = len(by_id)
    return by_id


# --------------------------------------------------------------------------------------------------------------------
# Level grammar (phase_00/03_LEVEL_GRAMMAR_AND_DIFFICULTY.md)
# --------------------------------------------------------------------------------------------------------------------
def validate_levels(doc: dict, chapters: dict[str, dict], rep: Report) -> dict[str, dict]:
    levels = doc.get("levels", [])
    by_id: dict[str, dict] = {}
    by_chapter: dict[str, list[dict]] = {}
    tuples_seen: dict[str, set[str]] = {}
    unverified_par = 0
    unverified_reach = 0

    for lv in levels:
        lid = lv.get("level_id", "")
        if not ID_RE["level"].match(lid):
            rep.err(f"level id malformed: {lid!r}")
            continue
        if lid in by_id:
            rep.err(f"DUPLICATE level_id {lid}")
        by_id[lid] = lv
        cid = lv.get("chapter_id")
        if cid not in chapters:
            rep.err(f"{lid}: chapter_id {cid!r} not in chapter fixture")
        elif chapter_num(cid) != int(lid.split(".")[1]):
            rep.err(f"{lid}: level id chapter number does not match chapter_id {cid}")
        by_chapter.setdefault(cid, []).append(lv)

        if lv.get("tier") not in TIERS:
            rep.err(f"{lid}: unknown tier {lv.get('tier')!r}")
        if lv.get("signature_ref") not in SIGNATURE_REFS:
            rep.err(f"{lid}: unknown signature_ref {lv.get('signature_ref')!r}")
        if lv.get("topology_id") not in TOPOLOGIES:
            rep.err(f"{lid}: unknown topology {lv.get('topology_id')!r}")
        if not isinstance(lv.get("scramble", {}).get("seed"), int):
            rep.err(f"{lid}: scramble.seed must be an integer (determinism)")

        obj = lv.get("objective", {})
        fam = obj.get("family")
        if fam not in OBJECTIVE_FAMILIES:
            rep.err(f"{lid}: unknown objective family {fam!r}")
        for f in obj.get("params", {}).get("faces", []):
            if f not in FACES:
                rep.err(f"{lid}: unknown face {f!r}")

        # objective family must be introduced by this chapter or an earlier one
        if cid in chapters and fam in OBJECTIVE_FAMILIES:
            allowed = set()
            for c in chapters.values():
                if c.get("ordinal", 0) <= chapters[cid].get("ordinal", 0):
                    allowed |= set(c["signature"]["introduces"].get("objective_families", []))
            if fam not in allowed:
                rep.err(f"{lid}: uses {fam} before any chapter <= {cid} introduces it")

        rule_ids = []
        for r in lv.get("level_rules", []):
            rid = r.get("rule_id")
            rule_ids.append(rid)
            if rid not in LEVEL_RULES:
                rep.err(f"{lid}: unknown level rule {rid!r}")
            if "relaxable" not in r or not isinstance(r["relaxable"], bool):
                rep.err(f"{lid}: rule {rid} must declare boolean 'relaxable' (equipment Legality surface)")
            if rid == "rule.axis_lock":
                for a in r.get("params", {}).get("axes", []):
                    if a not in AXES:
                        rep.err(f"{lid}: axis_lock unknown axis {a!r}")
                if len(r.get("params", {}).get("axes", [])) >= 3:
                    rep.err(f"{lid}: axis_lock locks all three axes - unreachable by construction")
        if len(rule_ids) != len(set(rule_ids)):
            rep.err(f"{lid}: duplicate level rule ids")

        placements = lv.get("tile_placement", [])
        has_placement_rule = "rule.tile_placement" in rule_ids
        if placements and not has_placement_rule:
            rep.err(f"{lid}: tile_placement present but rule.tile_placement not declared")
        if has_placement_rule and not placements:
            rep.err(f"{lid}: rule.tile_placement declared but no tiles placed")
        allowed_tiles = set()
        if cid in chapters:
            for c in chapters.values():
                if c.get("ordinal", 0) <= chapters[cid].get("ordinal", 0):
                    allowed_tiles |= set(c["signature"]["introduces"].get("tile_types", []))
        for p in placements:
            tt = p.get("tile_type")
            if tt not in TILE_TYPES:
                rep.err(f"{lid}: unknown tile type {tt!r}")
            elif tt not in allowed_tiles:
                rep.err(f"{lid}: uses {tt} before any chapter <= {cid} introduces it")
            if p.get("home_face") not in FACES:
                rep.err(f"{lid}: tile home_face {p.get('home_face')!r} invalid")
        if "rule.layer_lock" in rule_ids and not any(p.get("tile_type") == "tile.anchor" for p in placements):
            rep.err(f"{lid}: rule.layer_lock requires at least one tile.anchor placement")
        if "rule.fog" in rule_ids and not any(p.get("tile_type") == "tile.veiled" for p in placements):
            rep.err(f"{lid}: rule.fog requires at least one tile.veiled placement")
        if "rule.fracture_cost" in rule_ids and not any(p.get("tile_type") == "tile.fractured" for p in placements):
            rep.err(f"{lid}: rule.fracture_cost requires at least one tile.fractured placement")

        conds = [c.get("condition_id") for c in lv.get("challenge_conditions", [])]
        if "challenge.standard" not in conds:
            rep.err(f"{lid}: challenge.standard must always be present (main path)")
        for c in conds:
            if c not in CHALLENGE_CONDITIONS:
                rep.err(f"{lid}: unknown challenge condition {c!r}")
        if len(conds) != len(set(conds)):
            rep.err(f"{lid}: duplicate challenge conditions")
        # time challenge is optional-only; T0 levels may not carry any pressure condition
        if lv.get("tier") == "T0" and any(c in ("challenge.time", "challenge.move_efficiency") for c in conds):
            rep.err(f"{lid}: T0 (Teach) level must not carry pressure conditions")

        if lv.get("protected_mastery") is True:
            for r in lv.get("level_rules", []):
                if r.get("relaxable") is True:
                    rep.err(f"{lid}: protected_mastery level cannot have relaxable rules (Legality surface must be inert)")

        if lv.get("par_source") != "authored_unverified":
            rep.err(f"{lid}: Phase 00 par_source must be 'authored_unverified' (no solver exists)")
        else:
            unverified_par += 1
        if lv.get("reachability_verified") is not False:
            rep.err(f"{lid}: Phase 00 reachability_verified must be false (no solver exists) - do not fabricate evidence")
        else:
            unverified_reach += 1
        if not isinstance(lv.get("par_moves"), int) or lv["par_moves"] <= 0:
            rep.err(f"{lid}: par_moves must be a positive integer")

        for k in ("title_key", "hint_key"):
            v = lv.get(k, "")
            if not v.startswith("loc."):
                rep.err(f"{lid}: {k} must be a LocalizationKey name starting with 'loc.' (no embedded text)")
        for hook in lv.get("world_hooks", []):
            if hook.get("trigger") not in {"on_objective_satisfied", "on_step_satisfied", "on_seed_tile_home"}:
                rep.err(f"{lid}: unknown world hook trigger {hook.get('trigger')!r}")
            if hook.get("trigger") == "on_seed_tile_home" and not any(p.get("tile_type") == "tile.seed" for p in placements):
                rep.err(f"{lid}: on_seed_tile_home hook without a tile.seed placement")

        # within-chapter uniqueness tuple
        key = json.dumps({"o": obj, "r": lv.get("level_rules"), "t": placements, "s": lv.get("scramble")}, sort_keys=True)
        seen = tuples_seen.setdefault(cid, set())
        if key in seen:
            rep.err(f"{lid}: identical (objective, rules, tiles, scramble) tuple to another level in {cid}")
        seen.add(key)

    # chapter tier shape: T0 T1+ T2+ [T3] [T4*], and Slice-partial chapters allowed only if flagged via warning
    for cid, lvls in by_chapter.items():
        lvls_sorted = sorted(lvls, key=lambda l: l.get("ordinal", 0))
        tiers = [l.get("tier") for l in lvls_sorted]
        if tiers[:1] != ["T0"]:
            rep.err(f"{cid}: chapter must open with a T0 (Teach) level, got {tiers}")
        if "T1" not in tiers or "T2" not in tiers:
            rep.err(f"{cid}: chapter must contain at least one T1 and one T2 level, got {tiers}")
        idx = [TIERS.index(t) for t in tiers if t in TIERS]
        if idx != sorted(idx):
            rep.err(f"{cid}: tiers must be non-decreasing in ordinal order, got {tiers}")
        if not any(l.get("signature_ref") == "twist" for l in lvls_sorted):
            rep.warn(f"{cid}: no 'twist' level (required for full chapter; acceptable for Slice-partial chapter)")
        ords = [l.get("ordinal") for l in lvls_sorted]
        if ords != list(range(1, len(ords) + 1)):
            rep.err(f"{cid}: level ordinals must be contiguous from 1, got {ords}")

    # derived metrics (trivial ones only - see 03 doc §3.2)
    rep.metrics["levels"] = len(by_id)
    rep.metrics["rule_load"] = {lid: len(lv.get("level_rules", [])) for lid, lv in by_id.items()}
    rep.metrics["information_ratio"] = {
        lid: (sum(1 for p in lv.get("tile_placement", []) if p.get("tile_type") == "tile.veiled")
              / (24 if lv.get("topology_id") == "topology.cube.2" else 54))
        for lid, lv in by_id.items()
    }
    rep.metrics["par_unverified"] = unverified_par
    rep.metrics["reachability_unverified"] = unverified_reach
    return by_id


# --------------------------------------------------------------------------------------------------------------------
# Rewards & discoveries (phase_00/06_PUZZLE_REWARD_AND_DISCOVERY_MATRIX.md)
# --------------------------------------------------------------------------------------------------------------------
def validate_rewards(doc: dict, levels: dict[str, dict], chapters: dict[str, dict], discoveries: set[str], rep: Report) -> set[str]:
    ids: set[str] = set()
    referenced_by_levels = {r for lv in levels.values() for r in lv.get("reward_refs", [])}
    for rw in doc.get("rewards", []):
        rid = rw.get("reward_id", "")
        if not ID_RE["reward"].match(rid):
            rep.err(f"reward id malformed: {rid!r}")
            continue
        if rid in ids:
            rep.err(f"DUPLICATE reward_id {rid}")
        ids.add(rid)
        lid = rw.get("level_id")
        if lid not in levels:
            rep.err(f"{rid}: level_id {lid!r} not in level fixture")
        elif levels[lid].get("chapter_id") != rw.get("chapter_id"):
            rep.err(f"{rid}: chapter_id does not match level's chapter")
        if rw.get("chapter_id") not in chapters:
            rep.err(f"{rid}: chapter_id {rw.get('chapter_id')!r} not in chapter fixture")
        if rw.get("reward_class") not in REWARD_CLASSES:
            rep.err(f"{rid}: unknown reward_class {rw.get('reward_class')!r}")
        if rw.get("reward_class") == "reward_class.resource":
            rep.err(f"{rid}: reward_class.resource is not permitted in Phase 00 (economy not assumed, V7.1 §6)")
        cond = rw.get("reward_condition", {}).get("condition_id")
        if cond not in CHALLENGE_CONDITIONS:
            rep.err(f"{rid}: unknown reward condition {cond!r}")
        elif lid in levels:
            level_conds = {c.get("condition_id") for c in levels[lid].get("challenge_conditions", [])}
            if cond not in level_conds:
                rep.err(f"{rid}: condition {cond} is not declared on level {lid}")
        if rw.get("idempotent") is not True:
            rep.err(f"{rid}: idempotent must be the constant true")
        if not isinstance(rw.get("protected_progression"), bool):
            rep.err(f"{rid}: protected_progression must be boolean")
        elif rw["protected_progression"] and cond != "challenge.standard":
            rep.err(f"{rid}: DD-006 violated - protected_progression reward gated by {cond}, must be challenge.standard")
        if cond == "challenge.discovery":
            did = rw.get("reward_condition", {}).get("params", {}).get("discovery_id")
            if did not in discoveries:
                rep.err(f"{rid}: challenge.discovery references unknown discovery {did!r}")
        pr = rw.get("payload_ref", {})
        if not all(k in pr for k in ("owner", "kind", "ref")):
            rep.err(f"{rid}: payload_ref must have owner, kind, ref")
        elif pr["owner"] != "AI-03" and not str(pr["ref"]).startswith("PLACEHOLDER:"):
            rep.err(f"{rid}: payload ref to {pr['owner']} must be PLACEHOLDER: while that contract is not RELEASED (no invented IDs)")
        if rid not in referenced_by_levels:
            rep.err(f"{rid}: not referenced by any level's reward_refs (orphan)")
    for r in referenced_by_levels - ids:
        rep.err(f"level references undefined reward {r!r}")
    rep.metrics["rewards"] = len(ids)
    rep.metrics["protected_progression_rewards"] = sum(1 for rw in doc.get("rewards", []) if rw.get("protected_progression"))
    return ids


def validate_discoveries(doc: dict, levels: dict[str, dict], chapters: dict[str, dict], rep: Report) -> set[str]:
    ids: set[str] = set()
    referenced_by_levels = {d for lv in levels.values() for d in lv.get("discovery_refs", [])}
    for d in doc.get("discoveries", []):
        did = d.get("discovery_id", "")
        if not ID_RE["discovery"].match(did):
            rep.err(f"discovery id malformed: {did!r}")
            continue
        if did in ids:
            rep.err(f"DUPLICATE discovery_id {did}")
        ids.add(did)
        lid = d.get("level_id")
        if lid not in levels:
            rep.err(f"{did}: level_id {lid!r} not in level fixture")
        elif levels[lid].get("chapter_id") != d.get("chapter_id"):
            rep.err(f"{did}: chapter_id does not match level's chapter")
        if d.get("chapter_id") not in chapters:
            rep.err(f"{did}: chapter_id not in chapter fixture")
        if d.get("category") not in DISCOVERY_CATEGORIES:
            rep.err(f"{did}: unknown category {d.get('category')!r}")
        if d.get("layer") not in DISCOVERY_LAYERS:
            rep.err(f"{did}: unknown layer {d.get('layer')!r}")
        if d.get("blocks_progression") is not False:
            rep.err(f"{did}: blocks_progression must be the constant false")
        if not str(d.get("breadcrumb_key", "")).startswith("loc."):
            rep.err(f"{did}: breadcrumb_key must be a LocalizationKey name starting with 'loc.'")
        tc = d.get("trigger_condition", {})
        if not tc.get("kind"):
            rep.err(f"{did}: trigger_condition.kind required")
        for k, v in tc.get("params", {}).items():
            if k.endswith("_ref") and not str(v).startswith("PLACEHOLDER:"):
                rep.err(f"{did}: cross-track ref {k} must be PLACEHOLDER: while not RELEASED")
        if "tile_type" in tc.get("params", {}):
            tt = tc["params"]["tile_type"]
            if lid in levels and not any(p.get("tile_type") == tt for p in levels[lid].get("tile_placement", [])):
                rep.err(f"{did}: trigger requires {tt} but level {lid} places none")
        rr = d.get("reveals_ref", {})
        if not all(k in rr for k in ("owner", "kind", "ref")):
            rep.err(f"{did}: reveals_ref must have owner, kind, ref")
        elif rr["owner"] != "AI-03" and not str(rr["ref"]).startswith("PLACEHOLDER:"):
            rep.err(f"{did}: reveals ref to {rr['owner']} must be PLACEHOLDER: while not RELEASED")
        if did not in referenced_by_levels:
            rep.err(f"{did}: not referenced by any level's discovery_refs (orphan)")
    for r in referenced_by_levels - ids:
        rep.err(f"level references undefined discovery {r!r}")
    rep.metrics["discoveries"] = len(ids)
    return ids


def check_global_id_uniqueness(*id_sets: set[str], rep: Report) -> None:
    all_ids: list[str] = [i for s in id_sets for i in s]
    dupes = {i for i in all_ids if all_ids.count(i) > 1}
    if dupes:
        rep.err(f"cross-fixture duplicate IDs: {sorted(dupes)}")
    rep.metrics["total_ids"] = len(set(all_ids))


def run(fixtures: Path) -> Report:
    rep = Report()
    ch_doc = load(fixtures / "chapters.draft.json", rep)
    lv_doc = load(fixtures / "levels.slice.draft.json", rep)
    rw_doc = load(fixtures / "rewards.draft.json", rep)
    dc_doc = load(fixtures / "discoveries.draft.json", rep)
    if rep.errors:
        return rep
    check_envelope(ch_doc, "CC.CONTENT.CHAPTER_SIGNATURE", "chapters", rep)
    check_envelope(lv_doc, "CC.CONTENT.LEVEL", "levels", rep)
    check_envelope(rw_doc, "CC.REWARD.DEFINITION", "rewards", rep)
    check_envelope(dc_doc, "CC.DISCOVERY.DEFINITION", "discoveries", rep)
    chapters = validate_chapters(ch_doc, rep)
    levels = validate_levels(lv_doc, chapters, rep)
    discoveries = validate_discoveries(dc_doc, levels, chapters, rep)
    rewards = validate_rewards(rw_doc, levels, chapters, discoveries, rep)
    check_global_id_uniqueness(set(chapters), set(levels), rewards, discoveries, rep=rep)
    return rep


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--fixtures", type=Path, default=Path(__file__).resolve().parent.parent / "fixtures" / "phase00")
    ap.add_argument("--json", action="store_true", help="emit machine-readable report")
    args = ap.parse_args(argv)
    rep = run(args.fixtures)
    if args.json:
        print(json.dumps({"errors": rep.errors, "warnings": rep.warnings, "metrics": rep.metrics}, indent=2, sort_keys=True))
    else:
        print(f"AI-03 Phase 00 content validator — fixtures: {args.fixtures}")
        for w in rep.warnings:
            print(f"  WARN  {w}")
        for e in rep.errors:
            print(f"  ERROR {e}")
        print("  metrics:", json.dumps(rep.metrics, sort_keys=True))
        print(f"RESULT: {'PASS' if not rep.errors else 'FAIL'} ({len(rep.errors)} errors, {len(rep.warnings)} warnings)")
    if any(e.startswith(("MISSING", "INVALID JSON")) for e in rep.errors):
        return 2
    return 0 if not rep.errors else 1


if __name__ == "__main__":
    sys.exit(main())
