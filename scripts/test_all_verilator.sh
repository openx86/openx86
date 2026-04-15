#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

out_dir="${1:-build}"
mkdir -p "$out_dir"

if ! command -v verilator >/dev/null 2>&1; then
  echo "ERROR: verilator not found on PATH" >&2
  exit 2
fi

runner="scripts/sim_tb_verilator.sh"
chmod +x "$runner"

tb_roots=()
[[ -d "tb" ]] && tb_roots+=("tb")
[[ -d "rtl" ]] && tb_roots+=("rtl")
if [[ ${#tb_roots[@]} -eq 0 ]]; then
  echo "ERROR: no tb/ or rtl/ directory found" >&2
  exit 1
fi

mapfile -t tbs < <(find "${tb_roots[@]}" -name "*_tb.sv" -type f | sort)
if [[ ${#tbs[@]} -eq 0 ]]; then
  echo "ERROR: no testbenches found under tb/ or rtl/" >&2
  exit 1
fi

passed=0
failed=0

for tb in "${tbs[@]}"; do
  tb_name="$(basename "$tb" .sv)"
  echo ""
  echo "==============================="
  echo "TB: $tb"
  echo "==============================="
  if "$runner" --tb "$tb" --out-dir "$out_dir"; then
    passed=$((passed + 1))
  else
    failed=$((failed + 1))
  fi
done

echo ""
echo "==============================="
echo "DONE (verilator)"
echo "Passed: $passed"
echo "Failed: $failed"
echo "==============================="

if [[ $failed -ne 0 ]]; then
  exit 1
fi
exit 0

