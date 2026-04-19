#!/bin/sh
set -eu

# Run from any cwd: resolve paths from this script location.
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../../.." && pwd)
DESIGN_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)

cd "$REPO_ROOT"
python3 "$SCRIPT_DIR/gen_librelane_config.py" --repo-root "$REPO_ROOT"

# LibreLane resolves VERILOG_* paths relative to the process cwd unless --design-dir matches;
# generated paths are relative to asic/librelane/, so start the flow from there.
cd "$DESIGN_DIR"
exec librelane generated.config.json
