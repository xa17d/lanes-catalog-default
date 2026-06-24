#!/usr/bin/env bash
# Open this lane folder in VS Code. (Lane-level script-item; cwd = lane dir.)
set -euo pipefail
open -a "Visual Studio Code" "${LANE_DIR:-$PWD}"
