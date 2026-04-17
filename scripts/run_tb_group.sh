#!/usr/bin/env bash
set -euo pipefail

name=""
out_dir="build"
name_regex='.*_tb\.sv$'
continue_on_fail=0
paths=()

usage() {
  cat <<'EOF'
Usage:
  scripts/run_tb_group.sh --name <group> --path <tb/dir> [--path <tb/dir> ...]
                          [--name-regex <regex>] [--out-dir <dir>] [--continue-on-fail]

Notes:
  - Uses scripts/sim_tb_verilator.sh as the underlying runner.
  - Filters by testbench basename against --name-regex.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      name="${2:-}"; shift 2;;
    --path)
      paths+=("${2:-}"); shift 2;;
    --name-regex)
      name_regex="${2:-}"; shift 2;;
    --out-dir)
      out_dir="${2:-}"; shift 2;;
    --continue-on-fail)
      continue_on_fail=1; shift;;
    -h|--help)
      usage; exit 0;;
    *)
      echo "Unknown arg: $1" >&2
      usage >&2
      exit 2;;
  esac
done

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

if [[ -z "$name" ]]; then
  echo "ERROR: --name is required" >&2
  exit 2
fi
if [[ ${#paths[@]} -eq 0 ]]; then
  echo "ERROR: at least one --path is required" >&2
  exit 2
fi

runner="scripts/sim_tb_verilator.sh"
if [[ ! -f "$runner" ]]; then
  echo "ERROR: missing runner: $runner" >&2
  exit 2
fi
chmod +x "$runner"

mkdir -p "$out_dir"

mapfile -t all_tbs < <(
  for p in "${paths[@]}"; do
    if [[ -d "$p" ]]; then
      find "$p" -type f -name "*_tb.sv"
    fi
  done | sort -u
)

tbs=()
for tb in "${all_tbs[@]}"; do
  base="$(basename "$tb")"
  if [[ "$base" =~ $name_regex ]]; then
    tbs+=("$tb")
  fi
done

if [[ ${#tbs[@]} -eq 0 ]]; then
  echo "ERROR: no testbenches found for group '$name'" >&2
  exit 1
fi

passed=0
failed=0

for tb in "${tbs[@]}"; do
  echo ""
  echo "==============================="
  echo "GROUP: $name"
  echo "TB: $tb"
  echo "==============================="

  if "$runner" --tb "$tb" --out-dir "$out_dir"; then
    passed=$((passed + 1))
  else
    failed=$((failed + 1))
    if [[ $continue_on_fail -eq 0 ]]; then
      exit 1
    fi
  fi
done

echo ""
echo "==============================="
echo "GROUP DONE: $name"
echo "Passed: $passed"
echo "Failed: $failed"
echo "==============================="

if [[ $failed -ne 0 ]]; then
  exit 1
fi
exit 0
