#!/usr/bin/env bash
# Copy the lane's primary ticket key to the clipboard.
set -euo pipefail
printf '%s' "${TICKET_KEY:?No ticket linked to this lane}" | pbcopy
