#!/usr/bin/env sh
# 对 sim/filelists/ 下全部 *.f 做一次 Verilator --lint-only（逐个 filelist）。
# 用法:
#   ./scripts/build_all_filelists_verilator.sh [--out-dir build] [--top-module openx86_soc_top]
# 环境变量:
#   FILELISTS_DIR — 覆盖默认 filelists 目录（相对仓库根，默认 sim/filelists）
#   VERILATOR_EXTRA_ARGS — 追加传给 Verilator 的参数
#
# 目的：快速验证每个 filelist 都能被 Verilator 正确解析并通过基础 lint。

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v verilator >/dev/null 2>&1; then
  echo "error: verilator not installed or not on PATH" >&2
  exit 127
fi

OUT_DIR="build"
TOP_MODULE="openx86_soc_top"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --out-dir)
      OUT_DIR="${2:-}"
      shift 2
      ;;
    --top-module)
      TOP_MODULE="${2:-}"
      shift 2
      ;;
    *)
      echo "error: unknown option: $1" >&2
      echo "usage: $0 [--out-dir <dir>] [--top-module <name>]" >&2
      exit 2
      ;;
  esac
done

FILELISTS_DIR_REL="${FILELISTS_DIR:-sim/filelists}"
FILELISTS_DIR_ABS="$ROOT/$FILELISTS_DIR_REL"

if [ ! -d "$FILELISTS_DIR_ABS" ]; then
  echo "error: filelists directory not found: $FILELISTS_DIR_ABS" >&2
  exit 2
fi

mkdir -p "$ROOT/$OUT_DIR/verilator_filelists"

TMPDIR_BASE="${TMPDIR:-/tmp}"
WORKDIR="$TMPDIR_BASE/openx86_verilator_filelists_$$"
mkdir -p "$WORKDIR"
trap 'rm -rf "$WORKDIR"' EXIT INT TERM

PASSED=0
FAILED=0

echo "Verilator: $(verilator --version | head -n 1)"
echo "Filelists dir: $FILELISTS_DIR_REL"
echo "Top module: $TOP_MODULE"

for fl in "$FILELISTS_DIR_ABS"/*.f; do
  [ -f "$fl" ] || continue

  fl_rel="$(printf '%s\n' "$fl" | sed "s|^$ROOT/||")"
  base="$(basename "$fl")"
  name="${base%.f}"

  echo ""
  echo "==============================="
  echo "FILELIST: $fl_rel"
  echo "==============================="

  vf="$WORKDIR/${name}.vf"
  # 去掉空行与 # 注释行，其余原样交给 Verilator（支持 +incdir+、源文件路径等）
  sed -e '/^[[:space:]]*$/d' -e '/^[[:space:]]*#/d' "$fl" >"$vf"

  log="$ROOT/$OUT_DIR/verilator_filelists/${name}.lint.log"
  : >"$log"

  set +e
  verilator \
    --lint-only \
    -Wall \
    -Wno-DECLFILENAME \
    -Wno-UNUSEDSIGNAL \
    -Wno-UNUSEDPARAM \
    -Wno-SYNCASYNCNET \
    -Wno-fatal \
    --top-module "$TOP_MODULE" \
    -f "$vf" \
    ${VERILATOR_EXTRA_ARGS:-} >>"$log" 2>&1
  rc=$?
  set -e

  if [ "$rc" -eq 0 ]; then
    echo "PASS $fl_rel"
    PASSED=$((PASSED + 1))
  else
    echo "FAIL $fl_rel (exit $rc). log: $log" >&2
    FAILED=$((FAILED + 1))
  fi
done

echo ""
echo "==============================="
echo "DONE (verilator filelists)"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Logs: $OUT_DIR/verilator_filelists/"
echo "==============================="

if [ "$FAILED" -ne 0 ]; then
  exit 1
fi
exit 0

