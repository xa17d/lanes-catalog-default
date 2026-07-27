#!/usr/bin/env bash
#
# Open Ghostty here — focus this lane's Ghostty terminal, or create one at the lane
# folder. Re-running focuses the same terminal instead of spawning a new one.
#
# Ghostty (1.3.0+) exposes an AppleScript dictionary: a terminal is created from a
# `surface configuration` whose `initial working directory` places the new shell,
# and each terminal surface has a stable `id`. Like the iTerm2 variant we open a
# new tab in the front window when one is already open (a fresh window is spawned
# only when Ghostty has none), and remember that id in a per-purpose state file to
# focus it again next time. The Apple Event is sent by osascript as a child of
# Lanes, so it reuses Lanes' Automation permission for Ghostty.
#
# Lane-level script-item: cwd = lane dir; LANE_DIR/LANE_NAME/LANE_ID in env.
set -euo pipefail

CWD="${LANE_DIR:-$PWD}"
KEY="${LANE_ID:-lane}:shell"
INPUT=""   # bare shell — no command typed

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
        -- Reuse: focus the remembered terminal if it still exists.
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
        -- Create a terminal at the working directory; optionally type a command
        -- into its shell (kept interactive, so the shell remains afterwards). Open
        -- a tab in the front window when Ghostty already has one, else a new window.
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
