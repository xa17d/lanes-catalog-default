#!/usr/bin/env bash
# Copy the lane's primary ticket URL to the clipboard.
set -euo pipefail
printf '%s' "${TICKET_URL:?No ticket URL for this lane (set a ticket base URL in Settings)}" | pbcopy
