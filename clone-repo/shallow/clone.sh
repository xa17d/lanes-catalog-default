#!/usr/bin/env bash
#
# clone-repo (shallow) — a fast, space-saving clone of the latest commit only.
#
# Enable it as the lane `clone-repo` handler from Settings → Catalogs → Hooks
# (or via a clone-repo.catalog pointer). Lanes runs it with the lane folder as
# the working directory when you clone a repo from the "Clone repo…" menu, in
# place of the built-in `git clone`.
#
# Env from Lanes:
#   REPO_URL   — the clone URL (ssh or https, exactly as stored)
#   REPO_NAME  — the repo slug / destination folder name
#   LANE_DIR, LANE_NAME, LANE_ID
#
# --depth 1 fetches only the latest commit (and implies --single-branch), so the
# clone is much faster and smaller. Run `git fetch --unshallow` inside the repo
# later if you need full history. Lanes has already checked that ./$REPO_NAME
# does not exist; a nonzero exit surfaces stderr as an error toast.
set -euo pipefail

git clone --depth 1 -- "$REPO_URL" "$REPO_NAME"
