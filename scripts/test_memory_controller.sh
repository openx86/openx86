#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

out_dir="${1:-build}"
exec scripts/run_tb_group.sh --name memory --path tb/unit/memory --name-regex '.*_tb\.sv$' --out-dir "$out_dir"
