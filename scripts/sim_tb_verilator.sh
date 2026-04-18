#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/sim_tb_verilator.sh --tb <path/to/*_tb.sv> [--out-dir build] [--] [plusargs...]

Notes:
  - Requires: verilator (and a C++ toolchain available via verilator --binary)
  - RTL sources come from sim/filelists/*.f when present (fallback: scan rtl/).
  - Default filelist is auto-selected by TB path (tb/cpu tests use rtl_fullcore.f).
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

bootstrap_windows_toolchain() {
  local uname_s
  uname_s="$(uname -s 2>/dev/null || true)"

  case "$uname_s" in
    MINGW*|MSYS*|CYGWIN*)
      if [[ -x "/c/Strawberry/perl/bin/perl" ]]; then
        if ! perl -MPod::Usage -e1 >/dev/null 2>&1; then
          export PATH="/c/Strawberry/perl/bin:$PATH"
        fi
      fi

      if command -v mingw32-make >/dev/null 2>&1; then
        export PATH="/c/Strawberry/c/bin:$PATH"
        if ! command -v make >/dev/null 2>&1; then
          export MAKE="mingw32-make"
        fi
      fi

      if [[ -z "${VERILATOR_ROOT:-}" || "${VERILATOR_ROOT:-}" == *\\* || "${VERILATOR_ROOT:-}" =~ ^[A-Za-z]: ]]; then
        local verilator_path
        verilator_path="$(command -v verilator || true)"
        if [[ -n "$verilator_path" ]]; then
          if command -v cygpath >/dev/null 2>&1; then
            verilator_path="$(cygpath -u "$verilator_path" 2>/dev/null || echo "$verilator_path")"
          fi
          export VERILATOR_ROOT="$(cd "$(dirname "$verilator_path")/.." && pwd)"
        fi
      fi

      if [[ -z "${PYTHON3:-}" ]]; then
        if command -v python3 >/dev/null 2>&1; then
          export PYTHON3="$(command -v python3)"
        elif command -v python >/dev/null 2>&1; then
          export PYTHON3="$(command -v python)"
        fi
      fi
      ;;
  esac
}

bootstrap_windows_toolchain

tb_full="$(cd "$(dirname "$tb")" && pwd)/$(basename "$tb")"
tb_name="$(basename "$tb_full" .sv)"

build_root="$root/$out_dir/verilator"
obj_dir="$build_root/obj_dir_${tb_name}"
bin="$build_root/${tb_name}.bin"
mkdir -p "$build_root"

# On Windows, a stale running testbench can keep ${tb_name}.bin locked.
# Prefer canonical output name, but fall back to a per-process name when locked.
rm -f "$bin" 2>/dev/null || true
if [[ -e "$bin" ]]; then
  bin="$build_root/${tb_name}_$$.bin"
  echo "WARN: output binary is locked, using alternate path: $bin"
fi

select_default_filelist() {
  local tb_path="$1"
  if [[ "$tb_path" == *"/tb/cpu/"* ]]; then
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
  rtl_scan_dir="rtl"
  if [[ ! -d "$rtl_scan_dir" ]]; then
    echo "ERROR: missing rtl/ directory and filelist not found: $rtl_filelist" >&2
    exit 2
  fi
  mapfile -t rtl_sources < <(find "$rtl_scan_dir" -type f -name "*.sv" ! -name "*_tb.sv" | sort)
  incdirs+=("$rtl_scan_dir")
fi

inc_args=()
for d in "${incdirs[@]}"; do
  if [[ "$d" = /* || "$d" =~ ^[A-Za-z]:[/\\] ]]; then
    inc_args+=("-I$d")
  else
    inc_args+=("-I$root/$d")
  fi
done

compile_log="${tb_name}_compile.log"
run_log="${tb_name}_run.log"

tb_extra_sources=()
case "$tb_full" in
  */tb/*)
    while IFS= read -r f; do
      tb_extra_sources+=("$f")
    done < <(find "$root/tb/common" -maxdepth 1 -type f -name "*.sv" | sort)
    ;;
esac

tb_dir="$(dirname "$tb_full")"
if [[ -d "$tb_dir" ]]; then
  while IFS= read -r f; do
    [[ "$f" == "$tb_full" ]] && continue
    tb_extra_sources+=("$f")
  done < <(find "$tb_dir" -maxdepth 1 -type f -name "*.sv" | sort)
fi

verilator_split_args=(--output-split 0)

echo "== Verilator compile: $tb_full =="
echo "== RTL filelist: $rtl_filelist =="
set +e
verilator \
  --binary \
  -sv \
  --timing \
  "${verilator_split_args[@]}" \
  -Wall \
  -Wno-fatal \
  -CFLAGS "-std=gnu++20" \
  "${inc_args[@]}" \
  --top-module "$tb_name" \
  --Mdir "$obj_dir" \
  -o "$bin" \
  "${rtl_sources[@]}" \
  "${tb_extra_sources[@]}" \
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

