#!/usr/bin/env sh
# 使用 Verilator 编译并运行单个 `*_tb.sv`（仓库根目录执行，或通过 ROOT 自动定位）。
# 用法: scripts/sim_tb_verilator.sh --tb tb/common/edge_detect_tb.sv [--out-dir build]
# 环境变量:
#   RTL_FILELIST — 覆盖默认 RTL filelist（相对仓库根，如 sim/filelists/rtl_experimental.f）
#   VERILATOR_RUN_TIMEOUT — 仿真超时秒数（默认 900），需系统提供 timeout(1)

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v verilator >/dev/null 2>&1; then
  echo "error: verilator not installed or not on PATH" >&2
  exit 127
fi

TB=""
OUT_DIR="build"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --tb)
      TB="${2:-}"
      shift 2
      ;;
    --out-dir)
      OUT_DIR="${2:-}"
      shift 2
      ;;
    *)
      echo "error: unknown option: $1" >&2
      echo "usage: $0 --tb <path/to/foo_tb.sv> [--out-dir <dir>]" >&2
      exit 2
      ;;
  esac
done

if [ -z "$TB" ]; then
  echo "error: missing --tb" >&2
  exit 2
fi

case "$TB" in
  /*) TB_PATH="$TB" ;;
  *) TB_PATH="$ROOT/$TB" ;;
esac

if [ ! -f "$TB_PATH" ]; then
  echo "error: testbench not found: $TB_PATH" >&2
  exit 2
fi

TB_REL="$(printf '%s\n' "$TB_PATH" | sed "s|^$ROOT/||")"
TOP="$(basename "$TB_PATH" .sv)"

if [ "${RTL_FILELIST+set}" = set ] && [ -n "$RTL_FILELIST" ]; then
  RTL_F="$ROOT/$RTL_FILELIST"
else
  case "$TB_REL" in
    tb/cpu/*) RTL_F="$ROOT/sim/filelists/rtl_fullcore.f" ;;
    *) RTL_F="$ROOT/sim/filelists/rtl.f" ;;
  esac
fi

if [ ! -f "$RTL_F" ]; then
  echo "error: RTL filelist not found: $RTL_F" >&2
  exit 2
fi

LOGPREFIX="$(printf '%s' "$TB_REL" | tr '/' '_' | sed 's|\.sv$||')"
COMPILE_LOG="$ROOT/${LOGPREFIX}_compile.log"
RUN_LOG="$ROOT/${LOGPREFIX}_run.log"

: >"$COMPILE_LOG"
: >"$RUN_LOG"

WORKDIR="$ROOT/$OUT_DIR/verilator/${LOGPREFIX}_$$"
OBJDIR="$WORKDIR/obj"
mkdir -p "$OBJDIR"
trap 'rm -rf "$WORKDIR"' EXIT INT TERM

VF="$WORKDIR/sources.vf"
RAW="$WORKDIR/raw_sources.txt"
: >"$RAW"
# 去掉 filelist 里的空行与 shell 风格注释，其余原样交给 Verilator
sed -e '/^[[:space:]]*$/d' -e '/^[[:space:]]*#/d' "$RTL_F" >>"$RAW"
# 与 SDRAM / 总线类 TB 共用的 16-bit PHY 存根（若 TB 已在同目录引用则去重）
if [ -f "$ROOT/tb/common/sdram_x16_stub.sv" ]; then
  printf '%s\n' "tb/common/sdram_x16_stub.sv" >>"$RAW"
fi
# TB 同目录下除 *_tb.sv 以外的源（如 sd_mmc 卡模型）
TB_DIR="$(dirname "$TB_REL")"
if [ -d "$ROOT/$TB_DIR" ]; then
  for f in "$ROOT/$TB_DIR"/*.sv; do
    [ -f "$f" ] || continue
    base="$(basename "$f")"
    case "$base" in
      *_tb.sv) continue ;;
    esac
    printf '%s\n' "$TB_DIR/$base" >>"$RAW"
  done
fi
printf '%s\n' "$TB_REL" >>"$RAW"
awk 'NF && !seen[$0]++' "$RAW" >"$VF"

RUN_TIMEOUT="${VERILATOR_RUN_TIMEOUT:-900}"
TIMEOUT_CMD=""
if command -v timeout >/dev/null 2>&1; then
  TIMEOUT_CMD="timeout --kill-after=60 $RUN_TIMEOUT"
fi

echo "=== verilator TB: $TB_REL (top=$TOP) ===" | tee -a "$COMPILE_LOG"
echo "RTL filelist: $RTL_F" | tee -a "$COMPILE_LOG"

set +e
verilator \
  --binary \
  --timing \
  -j 0 \
  -Wall \
  -Wno-fatal \
  -Wno-DECLFILENAME \
  --top-module "$TOP" \
  -Mdir "$OBJDIR" \
  -o "V${TOP}" \
  -f "$VF" \
  ${VERILATOR_EXTRA_ARGS:-} >>"$COMPILE_LOG" 2>&1
VC=$?
set -e

if [ "$VC" -ne 0 ]; then
  echo "error: verilator compile failed for $TB_REL (exit $VC)" >&2
  exit "$VC"
fi

SIM="$OBJDIR/V${TOP}"
if [ ! -x "$SIM" ] && [ -f "$SIM" ]; then
  chmod +x "$SIM" || true
fi
if [ ! -x "$SIM" ]; then
  echo "error: expected simulator not executable: $SIM" >&2
  exit 3
fi

echo "=== run: $SIM ===" >>"$RUN_LOG"
set +e
if [ -n "$TIMEOUT_CMD" ]; then
  $TIMEOUT_CMD "$SIM" >>"$RUN_LOG" 2>&1
  RC=$?
else
  "$SIM" >>"$RUN_LOG" 2>&1
  RC=$?
fi
set -e

if [ "$RC" -ne 0 ]; then
  echo "error: simulation failed for $TB_REL (exit $RC)" >&2
  exit "$RC"
fi

echo "PASS $TB_REL" >>"$RUN_LOG"
exit 0
