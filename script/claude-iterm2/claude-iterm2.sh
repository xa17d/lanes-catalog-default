#!/usr/bin/env bash
#
# Claude — run the Claude agent in this lane's tagged iTerm2 session (created if
# needed), with the lane root as the working directory. Re-running focuses the
# existing session instead of spawning a new window. Replaces the former built-in
# Agents › Claude action. Swap CMD to point at a different agent CLI.
#
# A new session resumes the lane's most recent Claude conversation (`--continue`)
# when one exists. Interactive `claude --continue` aborts with "No conversation
# found to continue" otherwise, so we first look for an interactive transcript
# (`-p`/SDK runs are tagged differently and are not resumable that way) in Claude's
# session store: <config dir>/projects/<physical cwd, non-alphanumerics as "-">.
#
# Lane-level script-item: cwd = lane dir; LANE_DIR/LANE_NAME/LANE_ID in env.
set -euo pipefail

TAG="claude"
CWD="${LANE_DIR:-$PWD}"
CMD="claude"

SESSION_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects/$(cd "$CWD" && pwd -P | sed 's/[^A-Za-z0-9]/-/g')"
grep -qs '"entrypoint":"cli"' "$SESSION_DIR"/*.jsonl && CMD="$CMD --continue"

osascript - "«lane:${LANE_ID:-}:${TAG}»" "$CWD" "$CMD" <<'APPLESCRIPT'
on run argv
    set theTag to item 1 of argv
    set theCwd to item 2 of argv
    set theCmd to item 3 of argv
    tell application "iTerm2"
        repeat with w in windows
            repeat with t in tabs of w
                repeat with s in sessions of t
                    set sTag to ""
                    try
                        tell s to set sTag to (variable named "user.lane")
                    end try
                    if sTag is theTag then
                        tell t to select
                        tell s to select
                        select w
                        activate
                        delay 0.15
                        repeat with w2 in windows
                            repeat with t2 in tabs of w2
                                repeat with s2 in sessions of t2
                                    set tg2 to ""
                                    try
                                        tell s2 to set tg2 to (variable named "user.lane")
                                    end try
                                    if tg2 is theTag then
                                        tell t2 to select
                                        tell s2 to select
                                        select w2
                                    end if
                                end repeat
                            end repeat
                        end repeat
                        return "focused"
                    end if
                end repeat
            end repeat
        end repeat
        if (count of windows) > 0 then
            tell current window to set newTab to (create tab with default profile)
            set newSession to current session of newTab
        else
            set newWindow to (create window with default profile)
            set newSession to current session of newWindow
        end if
        tell newSession
            set variable named "user.lane" to theTag
            write text "cd " & quoted form of theCwd
            if theCmd is not "" then write text theCmd
        end tell
        activate
        return "created"
    end tell
end run
APPLESCRIPT
