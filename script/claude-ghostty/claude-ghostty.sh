#!/usr/bin/env bash
#
# Claude (Ghostty) — run the Claude agent in this lane's Ghostty terminal (created
# at the lane folder if needed), re-focusing the same terminal on re-run. The agent
# runs inside the interactive shell (via the surface's `initial input`), so when
# it exits you drop back to a shell in the lane. Swap CMD for a different agent.
#
# Ghostty (1.3.0+) AppleScript: a terminal is created from a `surface configuration`
# (initial working directory + initial input). Like the iTerm2 variant we open a
# new tab in the front window when one is already open (a fresh window is spawned
# only when Ghostty has none); each terminal has a stable `id` that we remember in
# a per-purpose state file to focus it again next time.
#
# Lane-level script-item: cwd = lane dir; LANE_DIR/LANE_NAME/LANE_ID in env.
set -euo pipefail

CWD="${LANE_DIR:-$PWD}"
KEY="${LANE_ID:-lane}:claude"
CMD="claude"
INPUT="${CMD}"$'\n'   # typed into the shell; trailing newline runs it

STATE_DIR="${TMPDIR:-/tmp}/lanes-ghostty"
mkdir -p "$STATE_DIR"
STATE_FILE="$STATE_DIR/$(printf '%s' "$KEY" | tr -c 'A-Za-z0-9._-' '_')"
PREV_ID=""
[ -f "$STATE_FILE" ] && PREV_ID="$(cat "$STATE_FILE")"

NEW_ID="$(osascript - "$PREV_ID" "$CWD" "$INPUT" <<'APPLESCRIPT'
on run argv
    set prevId to item 1 of argv
    set theCwd to item 2 of argv
    set theInput to item 3 of argv
    tell application "Ghostty"
        if prevId is not "" then
            try
                repeat with t in terminals
                    if (id of t) is prevId then
                        focus t
                        activate
                        return prevId
                    end if
                end repeat
            end try
        end if
        set cfg to new surface configuration
        set initial working directory of cfg to theCwd
        if theInput is not "" then set initial input of cfg to theInput
        if (count of windows) > 0 then
            set theTab to new tab in (front window) with configuration cfg
        else
            set theTab to selected tab of (new window with configuration cfg)
        end if
        activate
        return id of (focused terminal of theTab)
    end tell
end run
APPLESCRIPT
)"

[ -n "$NEW_ID" ] && printf '%s' "$NEW_ID" > "$STATE_FILE"
