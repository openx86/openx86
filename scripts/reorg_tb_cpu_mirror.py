#!/usr/bin/env python3
"""Mirror tb/cpu layout to rtl/cpu 80386 tree (git mv). Run from repo root."""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TB = ROOT / "tb" / "cpu"


def git_mv(src: Path, dst: Path) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(["git", "mv", str(src), str(dst)], cwd=ROOT, check=True)


def main() -> None:
    moves = [
        (TB / "stage_1_ifu" / "instruction_fetch_tb.sv", TB / "instruction_unit" / "prefetch" / "instruction_fetch_tb.sv"),
        (TB / "stage_2_dec" / "decode_opcode_x86_tb.sv", TB / "instruction_unit" / "decode" / "decode_opcode_x86_tb.sv"),
        (TB / "stage_2_dec" / "decode_tb.sv", TB / "instruction_unit" / "decode" / "decode_tb.sv"),
        (TB / "stage_2_dec" / "decode_x87_tb.sv", TB / "instruction_unit" / "decode" / "decode_x87_tb.sv"),
        (TB / "bus_interface_unit_tb.sv", TB / "biu" / "bus_interface_unit_tb.sv"),
        (TB / "stage_3_exe" / "execute_unit_tb.sv", TB / "execute_unit" / "execute_unit_tb.sv"),
        (TB / "stage_3_exe" / "wb_write_back_unit_tb.sv", TB / "write_back" / "write_back_unit_tb.sv"),
        (TB / "stage_3_exe" / "w686_execute_i486_cpuid_tb.sv", TB / "execute_unit" / "extensions_i486" / "execute_i486_cpuid_tb.sv"),
    ]
    for src, dst in moves:
        if src.exists():
            git_mv(src, dst)
    # bulk instructions folder
    src_dir = TB / "stage_3_exe" / "instructions"
    dst_dir = TB / "execute_unit" / "instructions"
    if src_dir.exists():
        git_mv(src_dir, dst_dir)
    # remove empty stage dirs if possible
    for d in (TB / "stage_1_ifu", TB / "stage_2_dec", TB / "stage_3_exe"):
        if d.exists() and not any(d.iterdir()):
            d.rmdir()
    print("tb/cpu mirror done")


if __name__ == "__main__":
    main()
