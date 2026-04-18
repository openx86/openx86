#!/usr/bin/env sh
# 依次运行 Verilator testbench。可选第一个参数为输出目录（默认 build）。
#
# 默认：tb/ 下全部 *_tb.sv。
# 若设置 VERILATOR_TB_LIST（相对仓库根的文件路径），则仅运行该文件中列出的 TB
#（每行一个路径；以 # 开头的行与空行忽略）。GitHub Actions 使用 sim/filelists/ci_verilator_tbs.txt。
#
# 依赖 scripts/sim_tb_verilator.sh

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

RUNNER="$ROOT/scripts/sim_tb_verilator.sh"
if [ ! -f "$RUNNER" ]; then
  echo "error: missing $RUNNER" >&2
  exit 2
fi

OUT_DIR="${1:-build}"
mkdir -p "$ROOT/$OUT_DIR"

if [ ! -d tb ]; then
  echo "error: tb/ directory not found" >&2
  exit 2
fi

LIST="${TMPDIR:-/tmp}/openx86_tb_list_$$"
trap 'rm -f "$LIST"' EXIT INT TERM

if [ "${VERILATOR_TB_LIST+set}" = set ] && [ -n "$VERILATOR_TB_LIST" ]; then
  TB_LIST_FILE="$ROOT/$VERILATOR_TB_LIST"
  if [ ! -f "$TB_LIST_FILE" ]; then
    echo "error: VERILATOR_TB_LIST not found: $TB_LIST_FILE" >&2
    exit 2
  fi
  sed -e '/^[[:space:]]*$/d' -e '/^[[:space:]]*#/d' "$TB_LIST_FILE" | LC_ALL=C sort -u >"$LIST"
  if ! [ -s "$LIST" ]; then
    echo "error: no TB paths in $VERILATOR_TB_LIST" >&2
    exit 2
  fi
  echo "Using TB list: $VERILATOR_TB_LIST ($(wc -l <"$LIST") path(s)))"
else
  find tb -type f -name '*_tb.sv' | LC_ALL=C sort -u >"$LIST"
  if ! [ -s "$LIST" ]; then
    echo "error: no *_tb.sv under tb/" >&2
    exit 2
  fi
  echo "Running all tb/*_tb.sv ($(wc -l <"$LIST") file(s)))"
fi

FAILED=0
PASSED=0

while IFS= read -r tb; do
  if [ ! -f "$ROOT/$tb" ]; then
    echo "error: TB file missing: $ROOT/$tb" >&2
    exit 2
  fi
  echo ""
  echo "==============================="
  echo "TB: $tb"
  echo "==============================="
  if sh "$RUNNER" --tb "$tb" --out-dir "$OUT_DIR"; then
    PASSED=$((PASSED + 1))
  else
    FAILED=$((FAILED + 1))
    exit 1
  fi
done <"$LIST"

echo ""
echo "==============================="
echo "DONE (verilator)"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "==============================="

exit 0
