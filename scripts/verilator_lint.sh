#!/usr/bin/env sh
# Scan all *.sv files in rtl/ individually with Verilator lint-only.
# Continue scanning even if errors are found in individual files.
# All output messages are in English.

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v verilator >/dev/null 2>&1; then
  echo "error: verilator not installed or not on PATH" >&2
  exit 127
fi

if [ ! -d rtl ]; then
  echo "error: rtl/ directory not found (ROOT=$ROOT)" >&2
  exit 2
fi

# Collect all SystemVerilog source files (sorted for consistent ordering)
RTL_SV_LIST=$(mktemp)
find rtl -type f -name '*.sv' | LC_ALL=C sort >"$RTL_SV_LIST"

if ! [ -s "$RTL_SV_LIST" ]; then
  echo "error: no *.sv files found under rtl/" >&2
  rm -f "$RTL_SV_LIST"
  exit 2
fi

TOTAL_FILES=$(wc -l <"$RTL_SV_LIST")
ERROR_COUNT=0

echo "Verilator individual file lint: $TOTAL_FILES file(s) to scan"
echo "Verilator version:"
verilator --version
echo "========================================"

# Scan each file individually
while IFS= read -r sv_file; do
  echo ""
  echo "Scanning: $sv_file"
  
  # Temporary objdir for this file
  FILE_OBJDIR="${TMPDIR:-/tmp}/openx86_verilator_lint_$$"
  mkdir -p "$FILE_OBJDIR"
  
  # Run verilator lint-only on this single file
  # -I@include for common definitions, plus all RTL subdirectories for module resolution
  if verilator \
    --lint-only \
    -Wall \
    -Wno-DECLFILENAME \
    -Wno-UNUSEDSIGNAL \
    -Wno-UNUSEDPARAM \
    -Wno-SYNCASYNCNET \
    -Wno-fatal \
    -I@include \
    -Irtl \
    -Irtl/chipset \
    -Irtl/common \
    -Irtl/cpu \
    -Irtl/cpu/biu \
    -Irtl/cpu/include \
    -Irtl/cpu/load_store_unit \
    -Irtl/cpu/mmu \
    -Irtl/cpu/mmu/paging \
    -Irtl/cpu/mmu/segmentation \
    -Irtl/cpu/pipeline \
    -Irtl/cpu/pipeline/stage_1_ifu \
    -Irtl/cpu/pipeline/stage_1_ifu/prefetch \
    -Irtl/cpu/pipeline/stage_2_dec \
    -Irtl/cpu/pipeline/stage_3_uop \
    -Irtl/cpu/pipeline/stage_4_exu \
    -Irtl/cpu/pipeline/stage_4_exu/agu_lsu \
    -Irtl/cpu/pipeline/stage_4_exu/alu \
    -Irtl/cpu/pipeline/stage_4_exu/alu/arithmetic \
    -Irtl/cpu/pipeline/stage_4_exu/alu/bitmanip \
    -Irtl/cpu/pipeline/stage_4_exu/alu/logic \
    -Irtl/cpu/pipeline/stage_4_exu/alu/misc \
    -Irtl/cpu/pipeline/stage_4_exu/alu/shift_rotate \
    -Irtl/cpu/pipeline/stage_4_exu/branch \
    -Irtl/cpu/pipeline/stage_4_exu/control \
    -Irtl/cpu/pipeline/stage_4_exu/extensions_i486 \
    -Irtl/cpu/pipeline/stage_4_exu/fpu \
    -Irtl/cpu/pipeline/stage_4_exu/muldiv \
    -Irtl/cpu/pipeline/stage_5_mem \
    -Irtl/cpu/pipeline/stage_6_wbu \
    -Irtl/cpu/register_file \
    -Irtl/device \
    -Irtl/device/ps2 \
    -Irtl/device/vga \
    -Irtl/memory \
    -Irtl/peripheral \
    -Irtl/peripheral/sdcard \
    -Mdir "$FILE_OBJDIR" \
    "$sv_file" 2>&1; then
    echo "  Status: PASS"
  else
    echo "  Status: ERROR found"
    ERROR_COUNT=$((ERROR_COUNT + 1))
  fi
  
  # Clean up temporary objdir
  rm -rf "$FILE_OBJDIR"
done <"$RTL_SV_LIST"

# Clean up
rm -f "$RTL_SV_LIST"

echo ""
echo "========================================"
echo "Lint scan completed"
echo "Total files scanned: $TOTAL_FILES"
echo "Files with errors: $ERROR_COUNT"

if [ "$ERROR_COUNT" -gt 0 ]; then
  echo "Summary: $ERROR_COUNT file(s) contained errors"
  exit 1
else
  echo "Summary: All files passed lint check"
  exit 0
fi
