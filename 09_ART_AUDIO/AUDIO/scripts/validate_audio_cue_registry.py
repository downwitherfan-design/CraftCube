#!/usr/bin/env python3
"""Deterministic structural validator for the CraftCube audio cue registry.

Owner: AI-08 (Audio / Music / Adaptive Sound)
Contract: CC.AUDIO.CUE (DRAFT 0.1.0) — rules defined in
          09_ART_AUDIO/AUDIO/AUDIO_CUE_ID_POLICY_DRAFT.md section 5.

Usage:
    python3 validate_audio_cue_registry.py <registry.json> [--expect-status DRAFT]

Exit codes:
    0  registry valid
    1  one or more validation errors (all listed on stderr)
    2  file could not be read / parsed

Standard library only. No engine or network dependency. Suitable for CI.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

CUE_ID_RE = re.compile(r"^audio\.[a-z0-9_]+\.[a-z0-9_]+\.[a-z0-9_]+(\.[a-z0-9_]+)?$")
MOTIF_ID_RE = re.compile(r"^motif\.[a-z0-9_]+$")
SEMVER_RE = re.compile(r"^\d+\.\d+\.\d+$")

ALLOWED_DOMAINS = {
    "puzzle", "world", "story", "item", "companion", "discovery", "ui", "music", "system",
}
PRIORITY_CLASSES = {
    "P0_PUZZLE_CRITICAL", "P1_NARRATIVE", "P2_WORLD_REACTION",
    "P3_COMPANION_ITEM", "P4_AMBIENT_MUSIC", "P5_UI",
}
BUSES = {"PuzzleCritical", "Narrative", "Companion", "Item", "World", "Music", "UI"}
LAYER_ROLES = {"one_shot", "continuous", "layer", "stinger"}
TRIGGER_SOURCES = {
    "PuzzleState", "WorldStateEvent", "NarrativeEvent", "CompanionReaction",
    "DiscoveryDefinition", "EquipmentEffect", "AccessibilityPreference",
    "Runtime", "AudioInternal",
}
VARIATION = {"none", "round_robin", "micro_variation", "intensity_ladder", "motif_form"}
RECORD_STATUS = {"draft", "frozen", "released", "deprecated"}
ENVELOPE_STATUS = {"DRAFT", "FROZEN", "RELEASED", "DEPRECATED"}

REQUIRED_CUE_FIELDS = {
    "cueId": str,
    "priorityClass": str,
    "bus": str,
    "layerRole": str,
    "triggerSource": str,
    "variationStrategy": str,
    "maxRatePerSecondHint": (int, float),
    "requiresNonAudioEquivalent": bool,
    "motifRef": (str, type(None)),
    "description": str,
    "status": str,
}

# priorityClass -> allowed buses (rule 8)
PRIORITY_BUS_RULES = {
    "P0_PUZZLE_CRITICAL": {"PuzzleCritical"},
    "P5_UI": {"UI"},
    "P4_AMBIENT_MUSIC": {"Music", "World"},
}


def validate(doc: dict, expect_status: str | None) -> list[str]:
    errors: list[str] = []

    # Rule 1 — envelope
    for field in ("schemaVersion", "contractId", "status", "owner", "motifs", "cues"):
        if field not in doc:
            errors.append(f"envelope: missing field '{field}'")
    if errors:
        return errors
    if not SEMVER_RE.match(str(doc["schemaVersion"])):
        errors.append(f"envelope: schemaVersion '{doc['schemaVersion']}' is not semver")
    if doc["contractId"] != "CC.AUDIO.CUE":
        errors.append(f"envelope: contractId must be 'CC.AUDIO.CUE', got '{doc['contractId']}'")
    if doc["status"] not in ENVELOPE_STATUS:
        errors.append(f"envelope: status '{doc['status']}' not in {sorted(ENVELOPE_STATUS)}")
    if expect_status and doc["status"] != expect_status:
        errors.append(f"envelope: expected status {expect_status}, got {doc['status']}")
    if doc["owner"] != "AI-08":
        errors.append(f"envelope: owner must be 'AI-08', got '{doc['owner']}'")
    if not isinstance(doc["motifs"], list) or not isinstance(doc["cues"], list):
        errors.append("envelope: 'motifs' and 'cues' must be arrays")
        return errors

    # Motifs (rule 3 duplicates, rule 7 references)
    motif_ids: set[str] = set()
    for i, m in enumerate(doc["motifs"]):
        mid = m.get("motifId") if isinstance(m, dict) else None
        if not isinstance(mid, str) or not MOTIF_ID_RE.match(mid):
            errors.append(f"motifs[{i}]: invalid or missing motifId '{mid}'")
            continue
        if mid in motif_ids:
            errors.append(f"motifs[{i}]: duplicate motifId '{mid}'")
        motif_ids.add(mid)
        for f in ("audioName", "canonOwner"):
            if not isinstance(m.get(f), str) or not m[f]:
                errors.append(f"motifs[{i}] ({mid}): missing '{f}'")

    # Cues
    cue_ids: set[str] = set()
    for i, c in enumerate(doc["cues"]):
        tag = f"cues[{i}]"
        if not isinstance(c, dict):
            errors.append(f"{tag}: record is not an object")
            continue
        cue_id = c.get("cueId")
        tag = f"{tag} ({cue_id})"

        # Rule 4 — required fields and types
        for field, ftype in REQUIRED_CUE_FIELDS.items():
            if field not in c:
                errors.append(f"{tag}: missing field '{field}'")
            elif not isinstance(c[field], ftype) or (ftype is bool and isinstance(c[field], int) and not isinstance(c[field], bool)):
                errors.append(f"{tag}: field '{field}' has wrong type {type(c[field]).__name__}")
        if any(f not in c for f in REQUIRED_CUE_FIELDS):
            continue  # cannot evaluate semantic rules on incomplete record

        # Rule 2 — grammar and domain
        if not isinstance(cue_id, str) or not CUE_ID_RE.match(cue_id):
            errors.append(f"{tag}: cueId does not match grammar audio.<domain>.<subject>.<action>[.<qualifier>]")
        else:
            domain = cue_id.split(".")[1]
            if domain not in ALLOWED_DOMAINS:
                errors.append(f"{tag}: domain '{domain}' not in {sorted(ALLOWED_DOMAINS)}")
            # Rule 3 — duplicates
            if cue_id in cue_ids:
                errors.append(f"{tag}: duplicate cueId")
            cue_ids.add(cue_id)

        # Rule 4 — enum values
        if c["priorityClass"] not in PRIORITY_CLASSES:
            errors.append(f"{tag}: priorityClass '{c['priorityClass']}' invalid")
        if c["bus"] not in BUSES:
            errors.append(f"{tag}: bus '{c['bus']}' invalid")
        if c["layerRole"] not in LAYER_ROLES:
            errors.append(f"{tag}: layerRole '{c['layerRole']}' invalid")
        if c["triggerSource"] not in TRIGGER_SOURCES:
            errors.append(f"{tag}: triggerSource '{c['triggerSource']}' invalid")
        if c["variationStrategy"] not in VARIATION:
            errors.append(f"{tag}: variationStrategy '{c['variationStrategy']}' invalid")
        if c["status"] not in RECORD_STATUS:
            errors.append(f"{tag}: status '{c['status']}' invalid")
        if c["maxRatePerSecondHint"] < 0:
            errors.append(f"{tag}: maxRatePerSecondHint must be >= 0")
        if not c["description"].strip():
            errors.append(f"{tag}: description is empty")

        # Rule 5 — accessibility redundancy for P0/P1
        if c["priorityClass"] in ("P0_PUZZLE_CRITICAL", "P1_NARRATIVE") and c["requiresNonAudioEquivalent"] is not True:
            errors.append(f"{tag}: {c['priorityClass']} cues must set requiresNonAudioEquivalent=true")

        # Rule 6 — fatigue: high-rate cues need variation
        if c["maxRatePerSecondHint"] > 1.0 and c["variationStrategy"] == "none":
            errors.append(f"{tag}: maxRatePerSecondHint > 1.0 requires a variationStrategy other than 'none'")

        # Rule 7 — motif reference
        if c["motifRef"] is not None and c["motifRef"] not in motif_ids:
            errors.append(f"{tag}: motifRef '{c['motifRef']}' not declared in motifs")

        # Rule 8 — priority/bus consistency
        allowed = PRIORITY_BUS_RULES.get(c["priorityClass"])
        if allowed and c["bus"] not in allowed:
            errors.append(f"{tag}: priorityClass {c['priorityClass']} requires bus in {sorted(allowed)}, got '{c['bus']}'")

        # Envelope/record status coherence: a DRAFT registry may not contain frozen/released records
        if doc["status"] == "DRAFT" and c["status"] in ("frozen", "released"):
            errors.append(f"{tag}: record status '{c['status']}' not allowed inside a DRAFT registry")

    return errors


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print(__doc__, file=sys.stderr)
        return 2
    path = Path(argv[1])
    expect_status = None
    if "--expect-status" in argv:
        idx = argv.index("--expect-status")
        if idx + 1 < len(argv):
            expect_status = argv[idx + 1]
    try:
        doc = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        print(f"ERROR: cannot read/parse {path}: {exc}", file=sys.stderr)
        return 2

    errors = validate(doc, expect_status)
    n_cues = len(doc.get("cues", [])) if isinstance(doc.get("cues"), list) else 0
    n_motifs = len(doc.get("motifs", [])) if isinstance(doc.get("motifs"), list) else 0
    if errors:
        print(f"FAIL: {path} — {len(errors)} error(s)", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1
    p0 = sum(1 for c in doc["cues"] if c.get("priorityClass") == "P0_PUZZLE_CRITICAL")
    p1 = sum(1 for c in doc["cues"] if c.get("priorityClass") == "P1_NARRATIVE")
    print(
        f"OK: {path} — contract {doc['contractId']} v{doc['schemaVersion']} [{doc['status']}] "
        f"motifs={n_motifs} cues={n_cues} P0={p0} P1={p1} (all P0/P1 carry non-audio equivalents)"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
