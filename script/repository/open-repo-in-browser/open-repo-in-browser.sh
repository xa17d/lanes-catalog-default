#!/usr/bin/env bash
# Open the repository's page on its git host (GitHub/GitLab/Bitbucket/…).
set -euo pipefail
url=$(git -C "$REPO_DIR" remote get-url origin)

# scp-like: git@host:owner/repo(.git)
if [[ "$url" == *"@"*":"* && "$url" != *"://"* ]]; then
  host=${url#*@}; host=${host%%:*}
  url="https://${host}/${url#*:}"
fi
# ssh://git@host[:port]/owner/repo(.git)
if [[ "$url" == ssh://* ]]; then
  rest=${url#ssh://}; rest=${rest#*@}
  host=${rest%%/*}; host=${host%%:*}
  url="https://${host}/${rest#*/}"
fi
url=${url%.git}
open "$url"
