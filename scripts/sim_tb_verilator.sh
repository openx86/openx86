#!/usr/bin/env sh
# Run a single SystemVerilog testbench with Verilator.
# Usage:
#   scripts/sim_tb_verilator.sh --tb path/to/tb.sv [--top MODULE] [-- +PLUSARGS...]
# Extra args after "--" (or VERILATOR_TB_EXTRA_ARGS) are forwarded to the sim binary.

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TB=""
TOP=""
EXTRA_ARGS=""

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
    --)
      shift
      EXTRA_ARGS="$*"
      break
      ;;
    *)
      if [ -z "$TB" ]; then
        TB="$1"
      else
        echo "error: unknown argument: $1 (use -- before plusargs)" >&2
        exit 2
      fi
      shift
      ;;
  esac
done

if [ -n "${VERILATOR_TB_EXTRA_ARGS:-}" ]; then
  EXTRA_ARGS="${EXTRA_ARGS} ${VERILATOR_TB_EXTRA_ARGS}"
fi

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
if [ -n "$EXTRA_ARGS" ]; then
  echo "Plusargs: $EXTRA_ARGS"
fi
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

LOG="${OBJDIR}/sim.log"
set +e
# shellcheck disable=SC2086
"${OBJDIR}/V${TOP}" $EXTRA_ARGS 2>&1 | tee "$LOG"
SIM_EC=$?
set -e

if grep -Eiq '^FAIL( |$)|FAIL:|%Fatal|Assertion failed' "$LOG"; then
  echo "error: TB reported FAIL: $TOP" >&2
  exit 1
fi
if ! grep -E '^PASS( |$)|PASS:' "$LOG" >/dev/null 2>&1; then
  if [ "$SIM_EC" -ne 0 ]; then
    echo "error: TB exited $SIM_EC without PASS: $TOP" >&2
    exit 1
  fi
fi
if [ "$SIM_EC" -ne 0 ]; then
  echo "error: TB simulator exit $SIM_EC: $TOP" >&2
  exit 1
fi
echo "TB completed: $TOP"
