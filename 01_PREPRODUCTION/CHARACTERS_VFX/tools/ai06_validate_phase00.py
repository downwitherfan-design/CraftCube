#!/usr/bin/env python3
"""AI-06 Phase 00 validator — Characters / Creatures / Animation / VFX.

Checks the AI-06 Phase 00 artifacts against the rules written in
AI06_CHARACTER_CREATURE_VFX_LOCK_V1.md (§8 hard rules, §10 boundaries CVX-M05/M06/M07/M12)
and AI06_COMPANION_REACTION_MODEL_DRAFT.md (§7 rules V-01..V-11).

Standard library only. Exit code 0 = all checks passed, 1 = at least one failure.

Usage:
    python3 01_PREPRODUCTION/CHARACTERS_VFX/tools/ai06_validate_phase00.py [--root <repo root>]

Scope: DRAFT artifacts only. This validator does not validate released contracts,
production content, Unity assets or runtime behavior. AI-10 owns production validators;
this script exists so downstream tracks can verify the Phase 00 output is usable.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

AI06_DIR = Path("01_PREPRODUCTION/CHARACTERS_VFX")
LOCK_DOC = AI06_DIR / "AI06_CHARACTER_CREATURE_VFX_LOCK_V1.md"
MODEL_DOC = AI06_DIR / "AI06_COMPANION_REACTION_MODEL_DRAFT.md"
REGISTER = AI06_DIR / "AI06_CHARACTERS_VFX_REGISTER_PHASE00.json"
FIXTURE = AI06_DIR / "fixtures" / "AI06_companion_reaction_fixture_DRAFT.json"

DOTTED_LOWER = re.compile(r"^[a-z0-9]+(\.[a-z0-9_]+)+$")
# Player-facing prose heuristics: a sentence-like string with spaces and a capital start.
PROSE = re.compile(r"^[A-Z][a-z]+ [a-z]+ .*")

REQUIRED_DEF_FIELDS = [
    "schemaVersion", "definitionId", "companionId", "triggerClass", "match", "purpose",
    "intensity", "durationMsMax", "cooldownMs", "onBusy", "channels", "meaningChannels",
    "reducedMotion", "occludesPuzzleDuringInput", "flashRateMaxHz", "localizationKeys",
    "placeholder",
]
REQUIRED_CHANNEL_KEYS = ["pose", "locomotion", "facet", "vfx", "audioHook", "dialogueHook", "feedbackCue"]


class Report:
    def __init__(self) -> None:
        self.failures: list[str] = []
        self.passes: list[str] = []

    def ok(self, rule: str, msg: str) -> None:
        self.passes.append(f"PASS {rule}: {msg}")

    def fail(self, rule: str, msg: str) -> None:
        self.failures.append(f"FAIL {rule}: {msg}")

    def check(self, cond: bool, rule: str, msg: str) -> None:
        (self.ok if cond else self.fail)(rule, msg)


def load_json(path: Path, rep: Report) -> dict | None:
    try:
        with path.open(encoding="utf-8") as fh:
            return json.load(fh)
    except FileNotFoundError:
        rep.fail("FILES", f"missing {path}")
    except json.JSONDecodeError as exc:
        rep.fail("FILES", f"invalid JSON in {path}: {exc}")
    return None


def scan_forbidden_terms(text: str, terms: list[str]) -> list[str]:
    hits = []
    for term in terms:
        if re.search(rf"(?<![a-z0-9]){re.escape(term.lower())}(?![a-z0-9])", text.lower()):
            hits.append(term)
    return hits


def strip_ip_policy_sections(text: str) -> str:
    """Remove the lines that *define* the forbidden-term policy so they do not self-trigger.

    Stripped: (a) single lines that explicitly mention 'forbidden' or 'avoid'; (b) every row
    of a markdown table whose header row declares an 'Avoid' column (an avoid-list table is
    policy by definition). Table membership ends at the first non-table line. Everything
    else is scanned.
    """
    kept = []
    in_avoid_table = False
    for line in text.splitlines():
        low = line.lower()
        is_table_row = line.lstrip().startswith("|")
        if not is_table_row:
            in_avoid_table = False
        elif "| avoid" in low or "avoid |" in low:
            in_avoid_table = True
        if in_avoid_table or "forbidden" in low or "avoid" in low:
            continue
        kept.append(line)
    return "\n".join(kept)


def validate_register(reg: dict, rep: Report) -> dict:
    rep.check(reg.get("status") == "DRAFT", "REG-STATUS", "register is labeled DRAFT")
    rep.check(reg.get("owner") == "AI-06", "REG-OWNER", "register owner is AI-06")
    cs = reg.get("closedSets", {})
    trig = cs.get("triggerClass", {}).get("values", [])
    rep.check(
        sorted(trig) == sorted(["puzzle_state", "biome_health", "relic", "story_revelation", "mastery_moment", "player_choice"]),
        "REG-TRIGGERS", "trigger classes are exactly the six PD-005 / Bond Bible classes",
    )
    rep.check(len(cs.get("bondStage", {}).get("values", [])) == 6, "REG-BOND", "six bond stages (Bond Bible)")
    rep.check(cs.get("biomeTier", {}).get("values") == [0, 1, 2, 3, 4], "REG-TIERS", "biome tiers 0-4 (Biome Bible)")

    # ID uniqueness across all AI-06 document-ID families in the register.
    ids: list[str] = []
    for key in ("hardRules", "measurableBoundaries", "domainCutList", "boundaryProposals"):
        ids += [e["id"] for e in reg.get(key, [])]
    for group in reg.get("openItems", {}).values():
        ids += [e["id"] for e in group]
    dupes = sorted({i for i in ids if ids.count(i) > 1})
    rep.check(not dupes, "REG-ID-UNIQUE", f"{len(ids)} document IDs unique" + (f" (dupes: {dupes})" if dupes else ""))
    keys = [r["key"] for r in reg.get("roster", [])]
    rep.check(len(keys) == len(set(keys)), "REG-ROSTER-UNIQUE", "roster concept keys unique")

    # Combat must be excluded from the roster and closed sets.
    companions = [r for r in reg.get("roster", []) if r.get("kind") == "companion" and r.get("v1Status") != "REJECT"]
    rep.check(len(companions) == 1 and companions[0].get("combat") is False, "REG-ONE-COMPANION", "exactly one non-rejected companion, non-combat (CUT-004/CUT-005)")
    purposes = cs.get("purpose", {}).get("values", [])
    rep.check(not any(p in purposes for p in ("attack", "damage", "defend")), "REG-NO-COMBAT-PURPOSE", "no combat purposes in closed set")
    return cs


def validate_fixture(fx: dict, cs: dict, forbidden: list[str], rep: Report) -> None:
    rep.check(fx.get("fixture") is True and fx.get("production") is False, "V-10", "fixture labeled fixture=true, production=false")
    trig_set = set(cs.get("triggerClass", {}).get("values", []))
    purpose_set = set(cs.get("purpose", {}).get("values", []))
    intensity_set = set(cs.get("intensity", {}).get("values", []))
    peak_allowed = set(cs.get("intensity", {}).get("peakAllowedTriggerClasses", []))
    bond_set = set(cs.get("bondStage", {}).get("values", []))
    loco_set = set(cs.get("locomotion", []))
    shake_set = set(cs.get("feedbackShake", []))
    haptic_set = set(cs.get("feedbackHaptic", []))

    defs = fx.get("definitions", [])
    rep.check(len(defs) >= 6, "FX-COVERAGE", f"{len(defs)} definitions present (>= 6)")
    covered = {d.get("triggerClass") for d in defs}
    rep.check(covered == trig_set, "FX-ONE-PER-CLASS", f"every trigger class has at least one fixture definition ({sorted(covered)})")

    seen_ids: set[str] = set()
    for d in defs:
        did = d.get("definitionId", "<missing>")
        missing = [f for f in REQUIRED_DEF_FIELDS if f not in d]
        rep.check(not missing, "FX-FIELDS", f"{did}: required fields present" + (f" (missing {missing})" if missing else ""))
        if missing:
            continue
        rep.check(d["triggerClass"] in trig_set, "V-01", f"{did}: triggerClass '{d['triggerClass']}' in whitelist")
        rep.check(d["purpose"] in purpose_set and d["intensity"] in intensity_set, "V-02", f"{did}: purpose/intensity in closed sets")
        rep.check(d["intensity"] != "peak" or d["triggerClass"] in peak_allowed, "V-03", f"{did}: peak only for {sorted(peak_allowed)}")
        ch = d["channels"]
        ch_missing = [k for k in REQUIRED_CHANNEL_KEYS if k not in ch]
        rep.check(not ch_missing, "FX-CHANNELS", f"{did}: all channel keys present" + (f" (missing {ch_missing})" if ch_missing else ""))
        mc = d["meaningChannels"]
        rep.check(len(mc) >= 2 and all(k in ch for k in mc), "V-04", f"{did}: meaningChannels >= 2 and present ({mc})")
        rep.check(mc != ["facet"], "V-04b", f"{did}: facet is not the sole meaning channel")
        rm = d["reducedMotion"]
        rep.check(isinstance(rm, dict) and len(rm) > 0 and rm.get("pose"), "V-05", f"{did}: reducedMotion present, non-empty, has pose")
        rep.check(d["occludesPuzzleDuringInput"] is False, "V-06", f"{did}: occludesPuzzleDuringInput is false")
        pulse = ch.get("facet", {}).get("pulseHz", 0)
        rm_pulse = rm.get("facet", {}).get("pulseHz", 0) if isinstance(rm, dict) else 0
        rep.check(d["flashRateMaxHz"] <= 3 and pulse <= 3 and rm_pulse <= 3, "V-07", f"{did}: flash/pulse <= 3 Hz")
        rep.check(DOTTED_LOWER.match(did) is not None and did not in seen_ids, "V-08", f"{did}: dotted lowercase and unique")
        seen_ids.add(did)
        rep.check(did.startswith("draft."), "FX-DRAFT-PREFIX", f"{did}: draft-prefixed (cannot collide with released IDs)")
        # V-09: no embedded prose strings in channel/hook fields.
        prose_hits = []
        for k, v in ch.items():
            if isinstance(v, str) and (" " in v or PROSE.match(v)):
                prose_hits.append(k)
        rep.check(not prose_hits, "V-09", f"{did}: no embedded player-facing strings in channels" + (f" ({prose_hits})" if prose_hits else ""))
        rep.check(d["localizationKeys"] == [] or all(isinstance(k, str) and " " not in k for k in d["localizationKeys"]), "V-09b", f"{did}: localizationKeys are keys, not text")
        rep.check(ch.get("locomotion") in loco_set, "FX-LOCO", f"{did}: locomotion in closed set")
        fc = ch.get("feedbackCue", {})
        rep.check(fc.get("shake") in shake_set and fc.get("haptic") in haptic_set, "VFX-R5", f"{did}: feedbackCue uses intensity classes only")
        rep.check(d["match"].get("minBondStage") in bond_set, "FX-BOND", f"{did}: match.minBondStage valid")
        rep.check(d["placeholder"] is True, "FX-PLACEHOLDER", f"{did}: placeholder=true (Phase 00 fixture must be mechanically detectable)")
        rep.check(d["durationMsMax"] <= cs.get("intensity", {}).get("durationMsMaxHypothesis", {}).get(d["intensity"], 10**9), "FX-DURATION", f"{did}: duration within intensity envelope")

    # Negative trigger example must exist and be outside the whitelist.
    negatives = [t for t in fx.get("triggerExamples", []) if t.get("expectedResult") == "REJECTED_BY_VALIDATOR"]
    rep.check(len(negatives) >= 1 and all(t["triggerClass"] not in trig_set for t in negatives), "FX-NEGATIVE", "negative trigger example present and correctly outside whitelist")
    positives = [t for t in fx.get("triggerExamples", []) if "expectedDefinitionId" in t]
    for t in positives:
        rep.check(t["triggerClass"] in trig_set and t["bondStage"] in bond_set, "FX-TRIGGER", f"trigger example -> {t['expectedDefinitionId']}: class/bond valid")
        rep.check(t["expectedDefinitionId"] in seen_ids, "FX-TRIGGER-REF", f"trigger example references existing definition {t['expectedDefinitionId']}")

    hits = scan_forbidden_terms(json.dumps(fx), forbidden)
    rep.check(not hits, "V-11", "fixture free of forbidden IP terms" + (f" (hits: {hits})" if hits else ""))


def validate_docs(root: Path, forbidden: list[str], rep: Report) -> None:
    for doc in (LOCK_DOC, MODEL_DOC):
        p = root / doc
        if not p.exists():
            rep.fail("FILES", f"missing {doc}")
            continue
        text = p.read_text(encoding="utf-8")
        hits = scan_forbidden_terms(strip_ip_policy_sections(text), forbidden)
        rep.check(not hits, "CVX-M12", f"{doc.name} free of forbidden IP terms outside policy lines" + (f" (hits: {hits})" if hits else ""))
    lock = (root / LOCK_DOC).read_text(encoding="utf-8") if (root / LOCK_DOC).exists() else ""
    for rid in [f"VFX-R{i}" for i in range(1, 9)] + [f"CVX-M{i:02d}" for i in range(1, 13)] + [f"CVX-CUT-{i:03d}" for i in range(1, 13)]:
        rep.check(rid in lock, "DOC-IDS", f"{rid} defined in lock document")
    model = (root / MODEL_DOC).read_text(encoding="utf-8") if (root / MODEL_DOC).exists() else ""
    rep.check("DRAFT" in model and "not consumable" in model, "DOC-DRAFT", "model doc explicitly labeled DRAFT / not consumable")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--root", default=".", help="repository root (default: cwd)")
    ap.add_argument("--verbose", action="store_true", help="print passes as well as failures")
    args = ap.parse_args()
    root = Path(args.root).resolve()
    rep = Report()

    reg = load_json(root / REGISTER, rep)
    fx = load_json(root / FIXTURE, rep)
    if reg is None or fx is None:
        for f in rep.failures:
            print(f)
        return 1

    forbidden = reg.get("ipForbiddenTerms", {}).get("terms", [])
    rep.check(len(forbidden) > 0, "REG-IP", f"{len(forbidden)} forbidden IP terms declared")
    cs = validate_register(reg, rep)
    validate_fixture(fx, cs, forbidden, rep)
    validate_docs(root, forbidden, rep)

    if args.verbose:
        for p in rep.passes:
            print(p)
    for f in rep.failures:
        print(f)
    print(f"\nAI-06 Phase 00 validator: {len(rep.passes)} passed, {len(rep.failures)} failed")
    return 1 if rep.failures else 0


if __name__ == "__main__":
    sys.exit(main())
