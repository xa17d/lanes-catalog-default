#!/usr/bin/env bash
#
# Open Terminal here (Terminal.app) — focus this lane's Terminal.app window, or
# open a new one at the lane folder.
#
# Terminal.app has no per-session variables like iTerm2, and its window *title*
# is owned by the running process (it changes as soon as you run a command), so
# titles can't be used to find a session again. Instead we remember the tab's
# **tty** (stable for the life of the session) in a small state file and match on
# that. The custom title ("Lanes · <name>") is just a cosmetic label.
# Always opens a new *window* (Terminal has no scriptable "new tab").
set -euo pipefail

CWD="${LANE_DIR:-$PWD}"
KEY="${LANE_ID:-lane}"
TITLE="Lanes · ${LANE_NAME:-lane}"

STATE_DIR="${TMPDIR:-/tmp}/lanes-terminal-app"
mkdir -p "$STATE_DIR"
STATE_FILE="$STATE_DIR/$(printf '%s' "$KEY" | tr -c 'A-Za-z0-9._-' '_')"
PREV_TTY=""
[ -f "$STATE_FILE" ] && PREV_TTY="$(cat "$STATE_FILE")"

TTY="$(osascript - "$PREV_TTY" "$CWD" "$TITLE" <<'APPLESCRIPT'
on run argv
    set prevTty to item 1 of argv
    set theCwd to item 2 of argv
    set theTitle to item 3 of argv
    tell application "Terminal"
        if prevTty is not "" then
            repeat with w in windows
                repeat with t in tabs of w
                    set thisTty to ""
                    try
                        set thisTty to (tty of t) as text
                    end try
                    if thisTty is prevTty then
                        set selected of t to true
                        set frontmost of w to true
                        activate
                        return prevTty
                    end if
                end repeat
            end repeat
        end if
        -- Not found: `do script` (no target) opens a new window.
        do script "cd " & quoted form of theCwd
        delay 0.3
        set newTab to selected tab of front window
        try
            set custom title of newTab to theTitle
        end try
        activate
        return (tty of newTab) as text
    end tell
end run
APPLESCRIPT
)"

printf '%s' "$TTY" > "$STATE_FILE"
