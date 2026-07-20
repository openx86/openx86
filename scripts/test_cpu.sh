#!/usr/bin/env sh
# Verilator TB regression from CI filelist (sim/filelists/ci_verilator_tbs.txt).

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

LIST="${VERILATOR_TB_LIST:-sim/filelists/ci_verilator_tbs.txt}"
FAIL=0
PASS=0
SKIP=0

if [ ! -f "$LIST" ]; then
  echo "error: TB list not found: $LIST" >&2
  exit 2
fi

echo "Verilator TB regression from: $LIST"

while IFS= read -r tb || [ -n "$tb" ]; do
  tb=$(printf '%s' "$tb" | tr -d '\r')
  case "$tb" in
    ""|\#*) continue ;;
  esac
  if [ ! -f "$tb" ]; then
    echo "SKIP missing TB: $tb"
    SKIP=$((SKIP + 1))
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

echo "TB summary: pass=$PASS fail=$FAIL skip=$SKIP"
if [ "$FAIL" -ne 0 ]; then
  exit 1
fi
