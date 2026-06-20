#!/usr/bin/env sh
# CPU-focused Verilator TB regression subset.

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

LIST="${VERILATOR_TB_LIST:-sim/filelists/ci_verilator_tbs.txt}"
FAIL=0
PASS=0

if [ ! -f "$LIST" ]; then
  echo "error: TB list not found: $LIST" >&2
  exit 2
fi

echo "CPU TB subset from: $LIST"

while IFS= read -r tb || [ -n "$tb" ]; do
  case "$tb" in
    ""|\#*) continue ;;
  esac
  case "$tb" in
    tb/cpu/*|tb/openx86_soc_top_tb.sv|tb/cpu/biu/*)
      ;;
    *)
      continue
      ;;
  esac
  if [ ! -f "$tb" ]; then
    echo "SKIP missing TB: $tb"
    continue
  fi
  echo "=== RUN $tb ==="
  if ./scripts/sim_tb_verilator.sh --tb "$tb"; then
    PASS=$((PASS + 1))
  else
    echo "FAIL: $tb" >&2
    FAIL=$((FAIL + 1))
  fi
done <"$LIST"

echo "CPU TB summary: pass=$PASS fail=$FAIL"
if [ "$FAIL" -ne 0 ]; then
  exit 1
fi
