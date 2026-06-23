#!/usr/bin/env bash
#
# update-lane-description hook.

set -euo pipefail

# Lanes is a GUI (LSUIElement) app: when launched from Finder/Dock it does NOT
# inherit a login shell's PATH, so Homebrew dirs are missing and `acli`
# (/opt/homebrew/bin on Apple Silicon, /usr/local/bin on Intel) is not found.
# Prepend the well-known tool locations so this hook resolves acli/jq/git no
# matter how the app was started. Existing PATH entries are kept.
PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:${PATH:-/usr/bin:/bin:/usr/sbin:/sbin}"
export PATH

# How often Lanes should re-run this hook to keep the status badge current.
refresh="10m"

# Use the ticket the extract-ticket hook linked, exported as TICKET_KEY. When no
# ticket is linked the var is unset -> nothing to describe, leave the existing
# description untouched.
key="${TICKET_KEY:-}"
if [[ -z "$key" ]]; then
    exit 0
fi

# acli is required to resolve the ticket. If it's missing we cannot do our job,
# so fail loudly (nonzero exit) rather than silently emitting a wrong/empty
# description. Lanes swallows the failure and keeps the prior description.
command -v acli >/dev/null 2>&1 || { echo "acli not found on PATH" >&2; exit 1; }

# Fetch only the fields we need, as JSON. A failure here (network, auth, unknown
# key) is fatal: leave the description as-is instead of guessing.
json=$(acli jira workitem view "$key" --fields summary,status --json 2>/dev/null) \
    || { echo "acli view failed for $key" >&2; exit 1; }

summary=$(printf '%s' "$json" | jq -r '.fields.summary // empty')
status=$(printf '%s' "$json" | jq -r '.fields.status.name // empty')

# Both fields must be present; otherwise the shape changed and we refuse to
# emit a half-formed description.
[[ -n "$summary" && -n "$status" ]] \
    || { echo "missing summary/status for $key" >&2; exit 1; }

# Map the workflow status to a badge color by keyword matching.
shopt -s nocasematch
case "$status" in
    # Release-candidate band and everything past it (incl. terminal states).
    *"release candidate"*|*released*|*done*|*retired*|*closed*)
        color="red" ;;
    # In review / feature-branch testing.
    *review*|*test*)
        color="blue" ;;
    # Development or prior.
    *backlog*|*open*|*refinement*|*develop*|*"in progress"*|*todo*|*merge*)
        color="green" ;;
    # Unmapped status: neutral, but visible.
    *)
        color="gray" ;;
esac
shopt -u nocasematch

printf '{{refresh:%s}} {{badge:%s:%s}} %s %s\n' "$refresh" "$color" "$status" "$key" "$summary"
