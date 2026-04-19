#!/usr/bin/env python3
"""
Merge asic/librelane/config.base.json with Verilog sources parsed from sim/filelists/rtl.f.

Outputs asic/librelane/generated.config.json with paths relative to the design directory.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path


def parse_rtl_filelist(repo_root: Path, filelist_path: Path) -> tuple[list[str], list[str]]:
    incdirs: list[str] = []
    verilog: list[str] = []
    seen_inc: set[str] = set()

    for raw in filelist_path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("+incdir+"):
            inc = line[len("+incdir+") :].strip()
            p = (repo_root / inc).resolve()
            if not p.is_dir():
                raise FileNotFoundError(f"Include directory does not exist: {p}")
            key = str(p)
            if key not in seen_inc:
                seen_inc.add(key)
                incdirs.append(str(p))
            continue
        vp = (repo_root / line).resolve()
        if not vp.is_file():
            raise FileNotFoundError(f"Verilog file does not exist: {vp}")
        verilog.append(str(vp))

    return verilog, incdirs


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--repo-root",
        type=Path,
        default=Path.cwd(),
        help="Repository root (contains rtl/ and sim/).",
    )
    ap.add_argument(
        "--filelist",
        type=Path,
        default=Path("sim/filelists/rtl.f"),
        help="Path to rtl.f relative to repo root unless absolute.",
    )
    ap.add_argument(
        "--base",
        type=Path,
        default=Path("asic/librelane/config.base.json"),
        help="Path to config.base.json relative to repo root unless absolute.",
    )
    ap.add_argument(
        "--output",
        type=Path,
        default=Path("asic/librelane/generated.config.json"),
        help="Output path relative to repo root unless absolute.",
    )
    args = ap.parse_args()

    repo_root = args.repo_root.resolve()
    filelist_path = args.filelist if args.filelist.is_absolute() else (repo_root / args.filelist)
    base_path = args.base if args.base.is_absolute() else (repo_root / args.base)
    output_path = args.output if args.output.is_absolute() else (repo_root / args.output)

    if not filelist_path.is_file():
        print(f"ERROR: filelist not found: {filelist_path}", file=sys.stderr)
        return 2
    if not base_path.is_file():
        print(f"ERROR: base config not found: {base_path}", file=sys.stderr)
        return 2

    verilog_abs, incdirs_abs = parse_rtl_filelist(repo_root, filelist_path)
    design_dir = output_path.parent.resolve()

    def rel_to_design(p: str) -> str:
        rel = os.path.relpath(p, start=design_dir)
        return Path(rel).as_posix()

    cfg = json.loads(base_path.read_text(encoding="utf-8"))
    cfg["VERILOG_FILES"] = [rel_to_design(p) for p in verilog_abs]
    cfg["VERILOG_INCLUDE_DIRS"] = [rel_to_design(p) for p in incdirs_abs]

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(cfg, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {output_path} ({len(cfg['VERILOG_FILES'])} verilog files, {len(cfg['VERILOG_INCLUDE_DIRS'])} include dirs)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
