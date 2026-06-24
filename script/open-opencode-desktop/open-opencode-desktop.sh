#!/usr/bin/env bash
# Open this lane folder in the OpenCode desktop app. (Lane-level script-item; cwd = lane dir.)
set -euo pipefail

folder="${LANE_DIR:-$PWD}"
encoded=$(python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))' "$folder")

open "opencode://open-project?directory=$encoded"
