#!/usr/bin/env sh
# 使用 Verilator 对 rtl/ 下全部 *.sv 做一次合并编译的 --lint-only 检查（语法与可静态检查的问题）。
# 依赖：已安装 verilator，且在仓库根目录执行（或通过下方 ROOT 自动定位）。

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v verilator >/dev/null 2>&1; then
  echo "error: verilator 未安装或不在 PATH 中" >&2
  exit 127
fi

if [ ! -d rtl ]; then
  echo "error: 未找到 rtl/ 目录（当前 ROOT=$ROOT）" >&2
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
  echo "error: rtl/ 下未发现任何 *.sv 文件" >&2
  exit 2
fi

# Verilator 命令文件：选项 + 全部源文件（避免命令行长度上限）
# `include "openx86_defs.h.sv"` -> @include/
# `include "w686_decode_outputs_decl.svh"` -> rtl/cpu/
CMDFILE="${LINT_OBJDIR}/verilator_rtl_lint.vf"
{
  printf '%s\n' "-I@include" "-Irtl/cpu"
  cat "$RTL_SV_LIST"
} >"$CMDFILE"

echo "Verilator RTL lint: 共 $(wc -l <"$RTL_SV_LIST") 个文件"
verilator --version
echo "运行: verilator --lint-only -f $CMDFILE"

# shellcheck disable=SC2086
# -Wno-fatal：整库 -Wall 时警告量很大，默认达到上限会以非零退出；lint 脚本以“打印问题”为主，不因警告终止。
exec verilator \
  --lint-only \
  -Wall \
  -Wno-DECLFILENAME \
  -Wno-fatal \
  --top-module openx86_soc_top \
  -Mdir "$LINT_OBJDIR" \
  -f "$CMDFILE" \
  ${VERILATOR_EXTRA_ARGS:-}
