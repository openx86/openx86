#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/sim_tb_verilator.sh --tb <path/to/*_tb.sv> [--out-dir build] [--] [plusargs...]

Notes:
  - Requires: verilator (and a C++ toolchain available via verilator --binary)
  - RTL sources come from sim/filelists/*.f when present (fallback: scan rtl/).
  - Default filelist is auto-selected by TB path (cpu/core unit tests use rtl_fullcore.f).
  - Extra arguments after '--' are forwarded to the produced binary, e.g. +SEABIOS_BIN=...
EOF
}

tb=""
out_dir="build"
plusargs=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tb)
      tb="${2:-}"; shift 2;;
    --out-dir)
      out_dir="${2:-}"; shift 2;;
    -h|--help)
      usage; exit 0;;
    --)
      shift
      plusargs=("$@")
      break;;
    *)
      echo "Unknown arg: $1" >&2
      usage >&2
      exit 2;;
  esac
done

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

if [[ -z "$tb" ]]; then
  echo "ERROR: missing --tb" >&2
  usage >&2
  exit 2
fi
if [[ ! -f "$tb" ]]; then
  echo "ERROR: testbench not found: $tb" >&2
  exit 2
fi
if ! command -v verilator >/dev/null 2>&1; then
  echo "ERROR: verilator not found on PATH" >&2
  exit 2
fi

tb_full="$(cd "$(dirname "$tb")" && pwd)/$(basename "$tb")"
tb_name="$(basename "$tb_full" .sv)"

build_root="$out_dir/verilator"
obj_dir="$build_root/obj_dir_${tb_name}"
bin="$build_root/${tb_name}.bin"
mkdir -p "$build_root"

select_default_filelist() {
  local tb_path="$1"
  if [[ "$tb_path" == *"/tb/unit/cpu/"* || "$tb_path" == *"/tb/unit/core/"* ]]; then
    echo "sim/filelists/rtl_fullcore.f"
    return
  fi
  echo "sim/filelists/rtl.f"
}

rtl_filelist="${RTL_FILELIST:-}"
if [[ -z "$rtl_filelist" ]]; then
  rtl_filelist="$(select_default_filelist "$tb_full")"
fi
rtl_sources=()
incdirs=()
if [[ -f "$rtl_filelist" ]]; then
  while IFS= read -r line; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" ]] && continue
    [[ "$line" == \#* ]] && continue
    if [[ "$line" == +incdir+* ]]; then
      incdirs+=("${line#'+incdir+'}")
      continue
    fi
    rtl_sources+=("$line")
  done < "$rtl_filelist"
else
  mapfile -t rtl_sources < <(find src/rtl -type f -name "*.sv" ! -name "*_tb.sv" | sort)
  incdirs+=("src/rtl")
fi

inc_args=()
for d in "${incdirs[@]}"; do
  inc_args+=("-I$d")
done

compile_log="${tb_name}_compile.log"
run_log="${tb_name}_run.log"

echo "== Verilator compile: $tb_full =="
echo "== RTL filelist: $rtl_filelist =="
set +e
verilator \
  --binary \
  -sv \
  --timing \
  -Wall \
  "${inc_args[@]}" \
  --top-module "$tb_name" \
  --Mdir "$obj_dir" \
  -o "$bin" \
  "${rtl_sources[@]}" \
  "$tb_full" \
  2>&1 | tee "$compile_log"
rc=${PIPESTATUS[0]}
set -e
if [[ $rc -ne 0 ]]; then
  echo "ERROR: verilator compile failed for $tb_name" >&2
  exit $rc
fi

echo "== Verilator run: $tb_full =="
set +e
"$bin" "${plusargs[@]}" 2>&1 | tee "$run_log"
rc=${PIPESTATUS[0]}
set -e
exit $rc

