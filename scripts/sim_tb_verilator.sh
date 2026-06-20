#!/usr/bin/env sh
# Run a single SystemVerilog testbench with Verilator.
# Usage: scripts/sim_tb_verilator.sh [--tb path/to/tb.sv] [--top MODULE]

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TB=""
TOP=""

while [ $# -gt 0 ]; do
  case "$1" in
    --tb)
      TB="$2"
      shift 2
      ;;
    --top)
      TOP="$2"
      shift 2
      ;;
    *)
      if [ -z "$TB" ]; then
        TB="$1"
      else
        echo "error: unknown argument: $1" >&2
        exit 2
      fi
      shift
      ;;
  esac
done

if [ -z "$TB" ]; then
  echo "error: missing --tb or TB path argument" >&2
  exit 2
fi

if ! command -v verilator >/dev/null 2>&1; then
  echo "error: verilator not installed or not on PATH" >&2
  exit 127
fi

if [ ! -f "$TB" ]; then
  echo "error: testbench not found: $TB" >&2
  exit 2
fi

if [ -z "$TOP" ]; then
  TOP="$(basename "$TB" .sv)"
fi

OBJDIR="${TMPDIR:-/tmp}/openx86_verilator_tb_${TOP}_$$"
mkdir -p "$OBJDIR"
trap 'rm -rf "$OBJDIR"' EXIT INT TERM

RTL_LIST="${OBJDIR}/rtl_sv_files.lst"
: >"$RTL_LIST"
find rtl -type f -name '*_pkg.sv' | LC_ALL=C sort >>"$RTL_LIST"
find rtl -type f -name '*.sv' ! -name '*_pkg.sv' | LC_ALL=C sort >>"$RTL_LIST"

CMDFILE="${OBJDIR}/verilator_tb.vf"
{
  printf '%s\n' "-Iinclude" "-Irtl/cpu" "-Irtl/cpu/include" "-Irtl/cpu/pipeline/stage_5_exu/include"
  cat "$RTL_LIST"
  printf '%s\n' "$TB"
} >"$CMDFILE"

echo "Verilator TB: top=$TOP tb=$TB"
verilator --version
verilator \
  --binary \
  -Wall \
  -Wno-fatal \
  -Wno-DECLFILENAME \
  -Wno-UNUSEDSIGNAL \
  -Wno-UNUSEDPARAM \
  -Wno-SYNCASYNCNET \
  --top-module "$TOP" \
  -Mdir "$OBJDIR" \
  -f "$CMDFILE"

"${OBJDIR}/V${TOP}"
echo "TB completed: $TOP"
