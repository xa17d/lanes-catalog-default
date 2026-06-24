#!/usr/bin/env bash
#
# Open Terminal here (Terminal.app) — focus this lane's tagged Terminal.app
# window, or open a new one at the lane folder.
#
# Terminal.app has no per-session variables like iTerm2, so the window is tagged
# by its *custom title* and re-found by matching it. It always opens a new
# *window* (Terminal has no scriptable "new tab"). The title is human-readable;
# two lanes with the same name would share a window.
set -euo pipefail

CWD="${LANE_DIR:-$PWD}"
TITLE="Lanes · ${LANE_NAME:-lane}"

osascript - "$TITLE" "$CWD" <<'APPLESCRIPT'
on run argv
    set theTitle to item 1 of argv
    set theCwd to item 2 of argv
    tell application "Terminal"
        repeat with w in windows
            repeat with t in tabs of w
                set tt to ""
                try
                    set tt to (custom title of t) as text
                end try
                if tt is theTitle then
                    set selected of t to true
                    set frontmost of w to true
                    activate
                    return "focused"
                end if
            end repeat
        end repeat
        -- Not found: `do script` with no target opens a new window.
        set newTab to do script "cd " & quoted form of theCwd
        set custom title of newTab to theTitle
        activate
        return "created"
    end tell
end run
APPLESCRIPT
