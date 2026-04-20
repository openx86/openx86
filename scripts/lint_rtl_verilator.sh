#!/usr/bin/env sh
# 使用 Verilator 对 rtl/ 下全部 *.sv 做一次合并编译的 --lint-only 检查（语法与可静态检查的问题）。
# 依赖：已安装 verilator，且在仓库根目录执行（或通过下方 ROOT 自动定位）。

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

# 临时输出目录，避免污染仓库根目录的默认 obj_dir
LINT_OBJDIR="${TMPDIR:-/tmp}/openx86_verilator_rtl_lint_$$"
mkdir -p "$LINT_OBJDIR"
trap 'rm -rf "$LINT_OBJDIR"' EXIT INT TERM

# 收集 rtl 下全部 SystemVerilog 源（稳定排序便于日志对比）
# 先列出 package 源（*_pkg.sv），再列其余 *.sv，避免按路径名排序时包定义排在 import 之后（Verilator PKGNODECL）。
RTL_SV_LIST="${LINT_OBJDIR}/rtl_sv_files.lst"
: >"$RTL_SV_LIST"
find rtl -type f -name '*_pkg.sv' | LC_ALL=C sort >>"$RTL_SV_LIST"
find rtl -type f -name '*.sv' ! -name '*_pkg.sv' | LC_ALL=C sort >>"$RTL_SV_LIST"

if ! [ -s "$RTL_SV_LIST" ]; then
  echo "error: no *.sv files found under rtl/" >&2
  exit 2
fi

# Verilator 命令文件：选项 + 全部源文件（避免命令行长度上限）
# `include "openx86_defs.h.sv"` -> @include/
# `include "iu_decode_outputs_decl.svh"` -> rtl/cpu/include/
CMDFILE="${LINT_OBJDIR}/verilator_rtl_lint.vf"
{
  printf '%s\n' "-I@include" "-Irtl/cpu" "-Irtl/cpu/include"
  cat "$RTL_SV_LIST"
} >"$CMDFILE"

echo "Verilator RTL lint: $(wc -l <"$RTL_SV_LIST") file(s)"
verilator --version
echo "Running: verilator --lint-only -f $CMDFILE"
# 英文提示便于 CI/日志工具稳定抓取，中文信息保留在注释里帮助本地维护。
echo "Info: temporary lint objdir = $LINT_OBJDIR"

# shellcheck disable=SC2086
# -Wno-fatal：整库 -Wall 时警告量很大，默认达到上限会以非零退出；lint 脚本以“打印问题”为主，不因警告终止。
verilator \
  --lint-only \
  -Wall \
  -Wno-DECLFILENAME \
  -Wno-UNUSEDSIGNAL \
  -Wno-UNUSEDPARAM \
  -Wno-SYNCASYNCNET \
  -Wno-fatal \
  --top-module openx86_soc_top \
  -Mdir "$LINT_OBJDIR" \
  -f "$CMDFILE" \
  ${VERILATOR_EXTRA_ARGS:-}

echo "Lint completed: no fatal Verilator errors."
