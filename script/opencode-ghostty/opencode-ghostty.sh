#!/usr/bin/env bash
#
# opencode (Ghostty) — run the opencode agent in this lane's Ghostty terminal
# (created at the lane folder if needed), re-focusing the same terminal on re-run.
# The agent runs inside the interactive shell (via the surface's `initial input`),
# so when it exits you drop back to a shell in the lane.
#
# Ghostty (1.3.0+) AppleScript: a terminal is created from a `surface configuration`
# (initial working directory + initial input). Each terminal has a stable `id` that
# we remember in a per-purpose state file to focus it again next time. A terminal
# `id` is only stable while the terminal lives, so once it is closed the reuse
# lookup misses and we create a new terminal: a new tab in Ghostty's front window
# when one is open (so you can keep several lanes' terminals as tabs in one window),
# or a fresh window when Ghostty has none.
#
# Raising is done as focus → activate → delay → focus (the same belt-and-suspenders
# sequence the iTerm2 variant uses) because Ghostty's focus/activate are async and
# a lone activate can re-raise the app's previous key window. The Apple Event is
# sent by osascript as a child of Lanes, so it reuses Lanes' Automation permission
# for Ghostty.
#
# Lane-level script-item: cwd = lane dir; LANE_DIR/LANE_NAME/LANE_ID in env.
set -euo pipefail

CWD="${LANE_DIR:-$PWD}"
KEY="${LANE_ID:-lane}:opencode"
CMD="opencode"
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
        -- Reuse: focus the remembered terminal if it still exists.
        if prevId is not "" then
            repeat with t in terminals
                set tid to ""
                try
                    set tid to id of t
                end try
                if tid is prevId then
                    my raiseTerminal(t)
                    return prevId
                end if
            end repeat
        end if
        -- Create a terminal at the working directory; optionally type a command
        -- into its shell (kept interactive, so the shell remains afterwards).
        set cfg to new surface configuration
        set initial working directory of cfg to theCwd
        if theInput is not "" then set initial input of cfg to theInput
        -- Open a new tab in the front window when one exists (so different lanes
        -- can share a window), otherwise a fresh window. The deterministic raise
        -- below brings the new terminal to the front regardless.
        if (count of windows) > 0 then
            set theTab to new tab in (front window) with configuration cfg
        else
            set theTab to selected tab of (new window with configuration cfg)
        end if
        set newTerm to focused terminal of theTab
        my raiseTerminal(newTerm)
        return id of newTerm
    end tell
end run

-- Bring a terminal's window reliably to the front. Ghostty's focus/activate are
-- asynchronous, so we focus before activating (so the right window is already
-- front when the app comes forward) and again afterwards (to correct any window
-- reshuffle activate triggers).
on raiseTerminal(t)
    tell application "Ghostty"
        focus t
        activate
        delay 0.15
        focus t
    end tell
end raiseTerminal
APPLESCRIPT
)"

[ -n "$NEW_ID" ] && printf '%s' "$NEW_ID" > "$STATE_FILE"
