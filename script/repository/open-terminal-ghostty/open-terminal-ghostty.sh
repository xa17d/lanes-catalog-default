#!/usr/bin/env bash
#
# Open Ghostty here — focus this repository's Ghostty window, or create one at the
# repo folder. Re-running focuses the same window instead of spawning a new one.
#
# Ghostty (1.3.0+) exposes an AppleScript dictionary: a window is created from a
# `surface configuration` whose `initial working directory` places the new shell,
# and each terminal surface has a stable `id`. Like the Terminal.app variant we
# remember that id in a per-purpose state file and focus it again next time.
#
# Per-repository script-item: cwd = repo dir; REPO_DIR/REPO_NAME (plus LANE_*) in
# env. The session key includes the repo path so each repo gets its own window.
set -euo pipefail

CWD="${REPO_DIR:-$PWD}"
KEY="repo:${CWD}:shell"
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
        set w to new window with configuration cfg
        activate
        return id of (focused terminal of (selected tab of w))
    end tell
end run
APPLESCRIPT
)"

[ -n "$NEW_ID" ] && printf '%s' "$NEW_ID" > "$STATE_FILE"
