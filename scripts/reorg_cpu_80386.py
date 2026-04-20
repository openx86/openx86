#!/usr/bin/env python3
"""
One-shot rtl/cpu 80386 directory + module rename helper.
Run from repository root: python scripts/reorg_cpu_80386.py apply
"""
from __future__ import annotations

import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CPU = ROOT / "rtl" / "cpu"


def norm_rel(p: Path) -> str:
    return p.as_posix().replace("\\", "/")


def compute_module(rel_under_cpu: str, stem: str) -> str:
    """rel_under_cpu: path under rtl/cpu without trailing slash, no .sv suffix."""
    if rel_under_cpu == "top" and stem == "i486_cpu":
        return "i486_cpu"
    if rel_under_cpu == "top" and stem == "i486_cpu_core":
        return "i486_cpu_core"
    parts = [x for x in rel_under_cpu.split("/") if x]
    if not parts:
        return stem
    last = parts[-1]
    new_stem = stem
    if stem == last:
        new_stem = stem
    elif stem.startswith(last + "_"):
        # Only strip full path-token prefix (avoid "memory" matching "memory_stage").
        new_stem = stem[len(last) + 1 :]
    prefix = "_".join(parts)
    return f"{prefix}_{new_stem}" if new_stem else prefix


def map_old_rel_to_new(old_rel: str) -> tuple[str, str] | None:
    """
    old_rel like 'stage_3_exe/alu/arithmetic/stage_3_exe_ari_add.sv'
    Returns (new_rel, new_stem_without_ext) or None if unhandled.
    """
    parts = old_rel.split("/")
    fname = parts[-1]

    def joinp(*ps: str) -> str:
        return "/".join(ps)

    # --- root singles ---
    if old_rel == "cpu.sv":
        return "top/i486_cpu.sv", "i486_cpu"
    if old_rel == "cpu_core.sv":
        return "top/i486_cpu_core.sv", "i486_cpu_core"
    if old_rel == "bus_interface_unit.sv":
        return "biu/bus_interface_unit.sv", "bus_interface_unit"
    if old_rel == "w686_decode_outputs_decl.svh":
        return "include/iu_decode_outputs_decl.svh", "iu_decode_outputs_decl"

    # --- IU prefetch ---
    if parts[0] == "stage_1_ifu":
        rest = "/".join(parts[1:]) if len(parts) > 1 else ""
        if fname == "stage_1_ifu.sv":
            return joinp("instruction_unit", "prefetch", "prefetch_unit.sv"), "prefetch_unit"
        if fname.startswith("stage_1_ifu_"):
            short = fname[len("stage_1_ifu_") : -3] + ".sv"
            return joinp("instruction_unit", "prefetch", short), fname[len("stage_1_ifu_") : -3]

    # --- IU decode ---
    if parts[0] == "stage_2_dec":
        if fname == "stage_2_dec.sv":
            return joinp("instruction_unit", "decode", "decode_stage.sv"), "decode_stage"
        if fname.startswith("stage_2_dec_decode_"):
            short = fname[len("stage_2_dec_decode_") : -3] + ".sv"
            return joinp("instruction_unit", "decode", short), fname[len("stage_2_dec_decode_") : -3]
        if fname.startswith("stage_2_dec_"):
            short = fname[len("stage_2_dec_") : -3] + ".sv"
            return joinp("instruction_unit", "decode", short), fname[len("stage_2_dec_") : -3]

    # --- EU (was stage_3_exe) ---
    if parts[0] == "stage_3_exe":
        sub = parts[1:-1]  # middle dirs
        if fname == "stage_3_exe.sv":
            return joinp("execute_unit", "control", "execute_stall.sv"), "execute_stall"
        if fname == "stage_3_exe_execute_unit.sv":
            return joinp("execute_unit", "execute_unit.sv"), "execute_unit"
        if fname == "stage_3_exe_w686_core_execute_i486.sv":
            return joinp("execute_unit", "extensions_i486", "execute_unit.sv"), "execute_unit"
        if fname.startswith("stage_3_exe_"):
            core = fname[len("stage_3_exe_") : -3]
            if sub:
                return joinp("execute_unit", *sub, core + ".sv"), core
            return joinp("execute_unit", core + ".sv"), core

    # --- memory / write_back ---
    if parts[0] == "stage_4_mem":
        if fname == "stage_4_mem.sv":
            return joinp("memory", "memory_stage.sv"), "memory_stage"
        if fname == "stage_4_mem_access_memory.sv":
            return joinp("memory", "access_memory.sv"), "access_memory"

    if parts[0] == "stage_5_wrb":
        if fname == "stage_5_wrb.sv":
            return joinp("write_back", "write_back_stage.sv"), "write_back_stage"
        if fname == "stage_5_wrb_wb_write_back_unit.sv":
            return joinp("write_back", "write_back_unit.sv"), "write_back_unit"

    # --- pipeline boundaries ---
    if parts[0] == "stage_1_2_ifu_dec" and fname == "stage_1_2_ifu_dec.sv":
        return joinp("pipeline", "if_to_dec", "pipeline_boundary.sv"), "pipeline_boundary"
    if parts[0] == "stage_2_3_dec_exe" and fname == "stage_2_3_dec_exe.sv":
        return joinp("pipeline", "dec_to_exe", "pipeline_boundary.sv"), "pipeline_boundary"
    if parts[0] == "stage_3_4_exe_mem" and fname == "stage_3_4_exe_mem.sv":
        return joinp("pipeline", "exe_to_mem", "pipeline_boundary.sv"), "pipeline_boundary"
    if parts[0] == "stage_4_5_mem_wrb" and fname == "stage_4_5_mem_wrb.sv":
        return joinp("pipeline", "mem_to_wb", "pipeline_boundary.sv"), "pipeline_boundary"

    # --- register files ---
    if parts[0] == "register_files":
        return joinp("register_file", fname), fname[:-3]

    # --- MMU ---
    if parts[0] == "mmu":
        if fname == "mmu_memory_management_unit.sv":
            return joinp("mmu", "memory_management_unit.sv"), "memory_management_unit"
        if fname.startswith("mmu_seg_"):
            core = fname[len("mmu_seg_") : -3] + ".sv"
            return joinp("mmu", "segmentation", core), fname[len("mmu_seg_") : -3]
        if fname.startswith("mmu_pg_"):
            core = fname[len("mmu_pg_") : -3] + ".sv"
            return joinp("mmu", "paging", core), fname[len("mmu_pg_") : -3]

    return None


def collect_mappings() -> list[tuple[Path, Path, str, str]]:
    """Returns list of (old_abs, new_abs, old_module, new_module)."""
    rows: list[tuple[Path, Path, str, str]] = []
    for p in sorted(CPU.rglob("*")):
        if not p.is_file():
            continue
        if p.suffix not in (".sv", ".svh"):
            continue
        old_rel = norm_rel(p.relative_to(CPU))
        mapped = map_old_rel_to_new(old_rel)
        if mapped is None:
            print("UNMAPPED:", old_rel, file=sys.stderr)
            sys.exit(1)
        new_rel, stem = mapped
        new_path = CPU / new_rel
        rel_dir = str(Path(new_rel).parent.as_posix())
        if rel_dir == ".":
            rel_dir = ""
        new_mod = compute_module(rel_dir, stem) if p.suffix == ".sv" else stem
        old_mod = None
        if p.suffix == ".sv":
            txt = p.read_text(encoding="utf-8", errors="replace")
            m = re.search(r"^\s*module\s+(\w+)\s*[#(]", txt, re.M)
            if not m:
                print("NO MODULE:", old_rel, file=sys.stderr)
                sys.exit(1)
            old_mod = m.group(1)
        rows.append((p, new_path, old_mod or "", new_mod))
    return rows


def git_mv(src: Path, dst: Path) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(["git", "mv", str(src), str(dst)], cwd=ROOT, check=True)


def apply_moves(rows: list[tuple[Path, Path, str, str]]) -> dict[str, str]:
    """Move files; return old_module -> new_module for .sv only."""
    mod_map: dict[str, str] = {}
    for old_p, new_p, old_m, new_m in rows:
        if old_m:
            mod_map[old_m] = new_m
        if old_p.resolve() == new_p.resolve():
            continue
        if new_p.exists():
            print("DEST EXISTS:", new_p, file=sys.stderr)
            sys.exit(1)
    # deepest paths first: sort by depth descending
    order = sorted(rows, key=lambda r: -str(r[0]).count(os.sep))
    for old_p, new_p, old_m, new_m in order:
        if old_p.resolve() == new_p.resolve():
            continue
        new_p.parent.mkdir(parents=True, exist_ok=True)
        if not old_p.exists():
            continue
        try:
            git_mv(old_p, new_p)
        except subprocess.CalledProcessError:
            # git mv fails if not in index; fall back to shutil
            shutil.move(str(old_p), str(new_p))

    return mod_map


def replace_in_text(content: str, mod_map: dict[str, str], extra: list[tuple[str, str]]) -> str:
    keys = sorted(mod_map.keys(), key=len, reverse=True)
    for k in keys:
        v = mod_map[k]
        content = re.sub(r"\b" + re.escape(k) + r"\b", v, content)
    for a, b in extra:
        content = content.replace(a, b)
    return content


def rewrite_all_sources(mod_map: dict[str, str]) -> None:
    extra = [
        ('`include "w686_decode_outputs_decl.svh"', '`include "iu_decode_outputs_decl.svh"'),
        ("w686_decode_outputs_decl.svh", "iu_decode_outputs_decl.svh"),
    ]
    for pat in ("rtl", "tb", "scripts"):
        d = ROOT / pat
        if not d.exists():
            continue
        for p in d.rglob("*"):
            if not p.is_file():
                continue
            if p.suffix not in (".sv", ".svh", ".f", ".qsf", ".sh", ".txt", ".json", ".yml", ".md"):
                continue
            if "asic" in p.parts and "runs" in p.parts:
                continue
            txt = p.read_text(encoding="utf-8", errors="replace")
            new_txt = replace_in_text(txt, mod_map, extra)
            if new_txt != txt:
                p.write_text(new_txt, encoding="utf-8", newline="\n")


def main() -> None:
    cmd = sys.argv[1] if len(sys.argv) > 1 else "plan"
    rows = collect_mappings()
    mod_map: dict[str, str] = {}
    for old_p, new_p, old_m, new_m in rows:
        if old_m:
            mod_map[old_m] = new_m
    if cmd == "plan":
        for old_p, new_p, old_m, new_m in rows:
            print(
                f"{old_p.relative_to(ROOT)} -> {new_p.relative_to(ROOT)} :: {old_m} -> {new_m}"
            )
        print("TOTAL", len(rows))
        return
    if cmd == "apply":
        mod_map = apply_moves(rows)
        # Legacy typo: core instantiated a non-existent module name.
        mod_map["stage_3_exe_w686_core_execute_i486"] = "eu_extensions_i486_execute_unit"
        # refresh module declarations in each moved sv (already have old name in file)
        for old_p, new_p, old_m, new_m in rows:
            if not new_m or not new_p.suffix == ".sv":
                continue
            if not new_p.exists():
                continue
            t = new_p.read_text(encoding="utf-8", errors="replace")
            if old_m:
                t2 = re.sub(
                    r"^(\s*)module\s+" + re.escape(old_m) + r"(\s*[#(])",
                    r"\1module " + new_m + r"\2",
                    t,
                    count=1,
                    flags=re.M,
                )
                new_p.write_text(t2, encoding="utf-8", newline="\n")
        rewrite_all_sources(mod_map)
        print("Done apply; update filelists if script did not cover.")
        return
    print("usage: plan | apply", file=sys.stderr)
    sys.exit(1)


if __name__ == "__main__":
    main()
