# lanes-catalog-default

The default [Lanes](https://gitea.xa1.at/xa1.at/lanes) **catalog** — a git repo of shared config (scripts, hooks, template) you subscribe to from Lanes' Settings.

Subscribing clones this repo under `<root>/.lanes/catalog/<id>/checkout/`; you then reference the items you want with `.catalog` pointer files in your own `<root>/.lanes/config/`.
See the Lanes [CONFIGURATION.md](https://gitea.xa1.at/xa1.at/lanes/src/branch/main/CONFIGURATION.md#catalogs) for the full reference.

## Layout

A catalog mirrors the `config/` layout, but with **plainly-named files** — your local `.catalog` pointer's filename supplies the display order, icon, and name, so the catalog only needs to hold content.

```
script/                     ← lane-level actions (cwd = lane dir, $LANE_DIR)
  open-terminal.sh          … focus/create this lane's tagged iTerm2 session
  open-finder.sh            … reveal the lane folder in Finder
  claude.sh                 … run Claude in the lane's iTerm2 session
  opencode.sh               … run opencode in the lane's iTerm2 session
  repository/               ← per-repo actions (cwd = repo dir, $REPO_DIR)
    open-pr.sh              … focus/open the Chrome tab for this branch's PR/MR
    open-github-actions.sh  … open the repo's GitHub Actions for the branch
    open-terminal.sh        … focus/create the repo's tagged iTerm2 session
    open-fork.sh            … open the repo in Fork
    open-android-studio.sh  … open the repo in Android Studio
    open-vscode.sh          … open the repo in VS Code
    open-finder.sh          … reveal the repo in Finder
hook/                       ← lifecycle hooks (cwd = lane dir)
  extract-ticket            … link a ticket from an ABC-1234-style folder name
  update-lane-description    … set the description to git working-tree status
```

These reproduce Lanes' former built-in launchers in plain `osascript` — edit them to fit your toolchain (e.g. swap VS Code for `zed`, Fork for Tower).
The Chrome/iTerm2 Apple Events are sent by a Lanes-spawned child, so they reuse Lanes' Automation permission (no extra prompt).

## Referencing an item

In your lanes root, point a local config file at a catalog item — the pointer's own filename gives the display `<order>---<icon>---<name>`:

`<root>/.lanes/config/script/repository/05---arrow.triangle.pull---Open PR.catalog`

```json
{ "catalog": "<this catalog's id>", "item": "script/repository/open-pr.sh" }
```

(The Catalogs editor in Lanes' Settings writes these pointer files for you.)
