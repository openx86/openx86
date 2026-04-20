#!/usr/bin/env python3
"""Refresh Quartus .qsf rtl/cpu/* file lists after CPU reorg."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CPU = ROOT / "rtl" / "cpu"
cpu_files = sorted(CPU.rglob("*.sv"), key=lambda p: p.as_posix())


def patch_qsf(path: Path, use_absolute: bool) -> None:
    lines = path.read_text(encoding="utf-8").splitlines()
    out: list[str] = []
    added_include = False
    for line in lines:
        if "rtl/cpu" in line.replace("\\", "/") and "SYSTEMVERILOG_FILE" in line:
            continue
        out.append(line)
        if added_include:
            continue
        if use_absolute:
            if "SEARCH_PATH" in line and 'rtl/cpu"' in line.replace("\\", "/") and "include" not in line:
                inc = (ROOT / "rtl" / "cpu" / "include").as_posix()
                out.append(f'set_global_assignment -name SEARCH_PATH "{inc}"')
                added_include = True
        else:
            if "SEARCH_PATH" in line and "@include" in line:
                out.append("set_global_assignment -name SEARCH_PATH ../../../rtl/cpu/include")
                added_include = True

    if not added_include:
        raise SystemExit(f"SEARCH_PATH anchor not found: {path}")

    insert_at = None
    for j, line in enumerate(out):
        if "true_dual_port_ram.sv" in line:
            insert_at = j + 1
            break
    if insert_at is None:
        raise SystemExit(f"anchor not found: {path}")

    block: list[str] = []
    for p in cpu_files:
        rel = p.relative_to(ROOT).as_posix()
        if use_absolute:
            fp = p.as_posix()
            block.append(f'set_global_assignment -name SYSTEMVERILOG_FILE "{fp}"')
        else:
            block.append(f'set_global_assignment -name SYSTEMVERILOG_FILE ../../../{rel}')

    out = out[:insert_at] + block + out[insert_at:]
    path.write_text("\n".join(out) + "\n", encoding="utf-8")


def main() -> None:
    patch_qsf(ROOT / "fpga/quartus/openx86_soc/openx86_soc.qsf", True)
    patch_qsf(ROOT / "fpga/boards/de2_115/x86_soc_on_de2_115.qsf", False)
    print("patched qsf files,", len(cpu_files), "cpu sv")


if __name__ == "__main__":
    main()
