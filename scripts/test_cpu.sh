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
  EXTRA=""
  case "$tb" in
    tb/dos_boot_tb.sv)
      if [ -f artifacts/seabios/dos_bios.bin ] && [ -f artifacts/freedos/disk.img ]; then
        EXTRA="-- +SEABIOS_BIN=artifacts/seabios/dos_bios.bin +DISK_IMG=artifacts/freedos/disk.img +REQUIRE_DOS=1 +MAX_CYCLES=200000"
      elif [ -f artifacts/seabios/bios.bin ] && [ -f artifacts/freedos/disk.img ]; then
        EXTRA="-- +SEABIOS_BIN=artifacts/seabios/bios.bin +DISK_IMG=artifacts/freedos/disk.img +REQUIRE_DOS=1 +MAX_CYCLES=200000"
      else
        echo "error: dos_boot requires artifacts/seabios/{dos_bios,bios}.bin and artifacts/freedos/disk.img" >&2
        echo "       run: scripts/fetch_build_seabios.sh && scripts/fetch_freedos_img.sh && scripts/build_openx86_dos_bios.py" >&2
        FAIL=$((FAIL + 1))
        continue
      fi
      ;;
    tb/seabios_post_tb.sv)
      if [ -f artifacts/seabios/bios.bin ]; then
        EXTRA="-- +SEABIOS_BIN=artifacts/seabios/bios.bin +REQUIRE_POST=1 +MAX_CYCLES=200000"
      fi
      ;;
  esac
  # shellcheck disable=SC2086
  if ./scripts/sim_tb_verilator.sh --tb "$tb" $EXTRA; then
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
