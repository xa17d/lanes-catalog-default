#!/usr/bin/env bash
# Open this lane folder in the OpenCode desktop app. (Lane-level script-item; cwd = lane dir.)
set -euo pipefail

folder="${LANE_DIR:-$PWD}"

for app in "OpenCode" "opencode"; do
  if open -a "$app" "$folder" 2>/dev/null; then
    exit 0
  fi
done

for bundle_id in "ai.opencode" "com.opencode.OpenCode" "dev.opencode.OpenCode"; do
  if open -b "$bundle_id" "$folder" 2>/dev/null; then
    exit 0
  fi
done

encoded=$(python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))' "$folder")
open "opencode://open?path=$encoded"
