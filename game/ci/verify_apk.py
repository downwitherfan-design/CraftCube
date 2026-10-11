#!/usr/bin/env python3
"""CraftCube APK metadata verifier (stdlib only, no network, no third-party deps).

Owner: AI-13 (Integration / Architecture Governance). Build-pipeline use only.
Companion to game/ci/validate_version.py; together they implement the mandatory
versioned-APK release policy (12_RELEASE/ANDROID_RELEASE_POLICY.md).

Why this exists: a successful `--export-debug` exit code does not prove that the
APK actually carries the version, package, architecture and signing we claim. This
tool opens the produced APK and reads them back out of the real artifact, then
fails visibly on any mismatch.

It parses, without aapt/apksigner (which are not guaranteed present):
  * the ZIP central directory (stdlib zipfile)
  * the binary AndroidManifest.xml (AXML) string pool + element/attribute chunks
  * lib/<abi>/ entries for the native architectures
  * META-INF signature entries (v1) and the APK Signing Block magic (v2/v3)

Exit 0 only when every requested --expect-* check passes; otherwise exit 1 with a
human-readable reason on stderr. Always prints a JSON summary to stdout.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import struct
import sys
import zipfile
from pathlib import Path

VERIFIER_ID = "verify_apk"
VERIFIER_VERSION = "0.1.0"

# AXML chunk types
_CHUNK_STRING_POOL = 0x0001
_CHUNK_XML = 0x0100
_CHUNK_START_ELEMENT = 0x0102

# AXML typed-value data types
_TYPE_STRING = 0x03
_TYPE_INT_DEC = 0x10
_TYPE_INT_HEX = 0x11

_ABI_RE = re.compile(r"^lib/([^/]+)/")


def _fail(msg: str) -> None:
    print(f"verify_apk: {msg}", file=sys.stderr)


# --------------------------------------------------------------------------- AXML


def _decode_len8(buf: bytes, pos: int):
    """UTF-8 string-pool length: 1 or 2 bytes (high bit => 2-byte, big-endian)."""
    n = buf[pos]
    if n & 0x80:
        n = ((n & 0x7F) << 8) | buf[pos + 1]
        return n, pos + 2
    return n, pos + 1


def _decode_len16(buf: bytes, pos: int):
    """UTF-16 string-pool length: 1 or 2 uint16 (high bit => 2-word)."""
    n = struct.unpack_from("<H", buf, pos)[0]
    if n & 0x8000:
        n = ((n & 0x7FFF) << 16) | struct.unpack_from("<H", buf, pos + 2)[0]
        return n, pos + 4
    return n, pos + 2


def _parse_string_pool(buf: bytes, off: int):
    chunk_type, header_size, chunk_size = struct.unpack_from("<HHI", buf, off)
    assert chunk_type == _CHUNK_STRING_POOL, "expected string pool chunk"
    string_count, style_count, flags, strings_start, styles_start = struct.unpack_from(
        "<IIIII", buf, off + 8
    )
    is_utf8 = bool(flags & (1 << 8))
    offsets = struct.unpack_from("<%dI" % string_count, buf, off + 28)
    base = off + strings_start
    out = []
    for o in offsets:
        p = base + o
        if is_utf8:
            n, p = _decode_len8(buf, p)
            out.append(buf[p : p + n].decode("utf-8", "replace"))
        else:
            n, p = _decode_len16(buf, p)
            out.append(buf[p : p + n * 2].decode("utf-16-le", "replace"))
    return out, chunk_size


def _parse_manifest(axml: bytes) -> dict:
    """Return {package, version_code, version_name, min_sdk, target_sdk} from AXML.

    The whole file is the RES_XML chunk (type 0x0003, header 8). Its children start at
    offset 8 and are walked directly: string pool (0x0001), resource map (0x0180),
    start-namespace (0x0100), start-element (0x0102), ...
    """
    magic, _size = struct.unpack_from("<HI", axml, 0)
    assert magic == 0x0003, "not a binary AndroidManifest.xml"
    strings, _ = _parse_string_pool(axml, 8)

    result: dict = {}
    pos = 8
    total = len(axml)
    while pos + 8 <= total:
        ctype, hsize, csize = struct.unpack_from("<HHI", axml, pos)
        if ctype == _CHUNK_START_ELEMENT:
            _read_start_element(axml, pos, hsize, strings, result)
        if csize <= 0:
            break
        pos += csize
    return result


def _read_start_element(axml: bytes, off: int, header_size: int, strings, result: dict) -> None:
    # header: type(2) hsize(2) size(4) line(4) comment(4) ns(4) name(4)
    #         attributeStart(2) attributeSize(2) attributeCount(2) id(2) class(2) style(2)
    name_idx = struct.unpack_from("<I", axml, off + 20)[0]
    element = strings[name_idx] if 0 <= name_idx < len(strings) else ""
    attr_start, attr_size, attr_count = struct.unpack_from("<HHH", axml, off + 24)
    attrs_base = off + 16 + attr_start  # 16 = fixed part up to attributeStart field start

    wanted = {
        "versionCode": "version_code",
        "versionName": "version_name",
        "minSdkVersion": "min_sdk",
        "targetSdkVersion": "target_sdk",
        "package": "package",
    }
    for i in range(attr_count):
        a = attrs_base + i * attr_size
        # ns(4) name(4) rawValue(4) size(2) res0(1) dataType(1) data(4)
        aname_idx = struct.unpack_from("<I", axml, a + 4)[0]
        raw_value = struct.unpack_from("<i", axml, a + 8)[0]
        dtype = axml[a + 15]
        data = struct.unpack_from("<I", axml, a + 16)[0]
        aname = strings[aname_idx] if 0 <= aname_idx < len(strings) else ""
        key = wanted.get(aname)
        if key is None:
            continue
        if dtype == _TYPE_STRING:
            idx = raw_value if raw_value >= 0 else data
            result[key] = strings[idx] if 0 <= idx < len(strings) else ""
        elif dtype in (_TYPE_INT_DEC, _TYPE_INT_HEX):
            result[key] = data
    _ = element


# ----------------------------------------------------------------------- APK parts


def _architectures(names) -> list:
    abis = set()
    for n in names:
        m = _ABI_RE.match(n)
        if m:
            abis.add(m.group(1))
    return sorted(abis)


def _signing(apk_path: Path, names) -> dict:
    v1 = sorted(
        n
        for n in names
        if n.startswith("META-INF/")
        and (n.endswith(".RSA") or n.endswith(".DSA") or n.endswith(".EC"))
    )
    has_sig_block = False
    with open(apk_path, "rb") as f:
        f.seek(0, 2)
        size = f.tell()
        f.seek(max(0, size - 65536))
        has_sig_block = b"APK Sig Block 42" in f.read()
    schemes = []
    if v1:
        schemes.append("v1")
    if has_sig_block:
        schemes.append("v2+")
    return {"schemes": schemes, "v1_certs": v1}


def _cert_subject_hints(apk_path: Path, v1_certs) -> list:
    """Printable subject hints extracted from the v1 certificate (PKCS#7 DER).

    Reported for transparency. Godot's built-in debug keystore signs with
    CN=Godot, OU=Godot Engine, O=Stichting Godot; the Android SDK debug keystore
    uses CN=Android Debug. Neither is a release identity.
    """
    hints: list = []
    if not v1_certs:
        return hints
    try:
        with zipfile.ZipFile(apk_path) as z:
            for cert in v1_certs:
                der = z.read(cert)
                for marker in (b"Android Debug", b"Godot Engine", b"Stichting Godot"):
                    if marker in der:
                        hints.append(marker.decode("ascii"))
    except Exception:
        return hints
    return sorted(set(hints))


_DEBUG_CERT_MARKERS = (b"Android Debug", b"Godot Engine", b"Stichting Godot")


def _looks_like_debug_cert(apk_path: Path, v1_certs) -> bool:
    """Heuristic: a debug keystore (Godot's built-in or the Android SDK one) signed
    this APK. Reported as a heuristic, never as proof of a release identity."""
    if not v1_certs:
        return False
    try:
        with zipfile.ZipFile(apk_path) as z:
            for cert in v1_certs:
                der = z.read(cert)
                if any(marker in der for marker in _DEBUG_CERT_MARKERS):
                    return True
    except Exception:
        return False
    return False


def inspect(apk_path: Path) -> dict:
    with zipfile.ZipFile(apk_path) as z:
        names = z.namelist()
        if "AndroidManifest.xml" not in names:
            raise SystemExit("verify_apk: AndroidManifest.xml missing from APK")
        axml = z.read("AndroidManifest.xml")
    manifest = _parse_manifest(axml)
    signing = _signing(apk_path, names)
    signing["debug_certificate"] = _looks_like_debug_cert(apk_path, signing["v1_certs"])
    signing["subject_hints"] = _cert_subject_hints(apk_path, signing["v1_certs"])
    if not signing["schemes"]:
        signing["type"] = "unsigned"
    elif signing["debug_certificate"]:
        signing["type"] = "debug"
    else:
        signing["type"] = "signed-unknown"
    return {
        "file": apk_path.name,
        "size_bytes": apk_path.stat().st_size,
        "sha256": hashlib.sha256(apk_path.read_bytes()).hexdigest(),
        "package": manifest.get("package", ""),
        "version_name": str(manifest.get("version_name", "")),
        "version_code": int(manifest.get("version_code", 0)),
        "min_sdk": int(manifest.get("min_sdk", 0)),
        "target_sdk": int(manifest.get("target_sdk", 0)),
        "architectures": _architectures(names),
        "signing": signing,
    }


def main(argv=None) -> int:
    p = argparse.ArgumentParser(description="Verify a CraftCube APK's real metadata.")
    p.add_argument("apk")
    p.add_argument("--expect-package")
    p.add_argument("--expect-version")
    p.add_argument("--expect-version-code", type=int)
    p.add_argument("--expect-min-sdk", type=int)
    p.add_argument("--expect-arch", action="append", default=[])
    p.add_argument("--expect-signing", choices=["debug", "release", "any"], default="any")
    p.add_argument("--require-signed", action="store_true")
    args = p.parse_args(argv)

    apk_path = Path(args.apk)
    if not apk_path.is_file() or apk_path.stat().st_size == 0:
        _fail(f"APK missing or empty: {apk_path}")
        return 1

    info = inspect(apk_path)
    print(json.dumps(info, indent=2))

    problems = []
    if args.expect_package and info["package"] != args.expect_package:
        problems.append(f"package {info['package']!r} != expected {args.expect_package!r}")
    if args.expect_version and info["version_name"] != args.expect_version:
        problems.append(f"versionName {info['version_name']!r} != expected {args.expect_version!r}")
    if args.expect_version_code is not None and info["version_code"] != args.expect_version_code:
        problems.append(
            f"versionCode {info['version_code']} != expected {args.expect_version_code}"
        )
    if args.expect_min_sdk is not None and info["min_sdk"] != args.expect_min_sdk:
        problems.append(f"minSdk {info['min_sdk']} != expected {args.expect_min_sdk}")
    for abi in args.expect_arch:
        if abi not in info["architectures"]:
            problems.append(f"architecture {abi!r} absent (have {info['architectures']})")
    if args.require_signed and not info["signing"]["schemes"]:
        problems.append("APK is not signed (no v1 cert and no APK Signing Block)")
    if args.expect_signing == "debug" and not info["signing"]["debug_certificate"]:
        problems.append("expected a debug-signed APK but the debug certificate was not detected")
    if args.expect_signing == "release" and info["signing"]["debug_certificate"]:
        problems.append("expected a release-signed APK but the debug certificate is present")

    if problems:
        for prob in problems:
            _fail(prob)
        return 1
    print("verify_apk: OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
