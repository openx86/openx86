#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

out_dir="${1:-build}"
mkdir -p "$out_dir"

echo "=== check_syntax.sh ==="
chmod +x ./check_syntax.sh
./check_syntax.sh

echo "=== test_all_modules.sh ==="
chmod +x ./test_all_modules.sh
./test_all_modules.sh

echo "PASS: all SystemVerilog tests"

