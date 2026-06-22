#!/usr/bin/env bash
# Copy the repository's current branch name to the clipboard.
set -euo pipefail
git -C "$REPO_DIR" rev-parse --abbrev-ref HEAD | tr -d '\n' | pbcopy
