# lanes-catalog-default

The default [Lanes](https://gitea.xa1.at/xa1.at/lanes) **catalog** — a git repo of shared config (scripts, hooks, template) you subscribe to from Lanes' Settings.

Subscribing clones this repo under `<root>/.lanes/catalog/<id>/checkout/`; you then enable the items you want from the Catalogs editor in Settings, which writes `.catalog` pointer files into your own `<root>/.lanes/config/`.
See the Lanes [CONFIGURATION.md](https://gitea.xa1.at/xa1.at/lanes/src/branch/main/CONFIGURATION.md#catalogs) for the full reference.

## Layout

Every catalog **item is a folder** holding its payload plus a `lanes-item.json` companion (default name, icon, and a description shown in the editor).
A `lanes-catalog.json` at the root declares the catalog's display name.

```
lanes-catalog.json
script/                       ← lane actions (cwd = lane dir)
  open-terminal/   { open-terminal.sh, lanes-item.json }
  open-finder/     { … }
  claude/          { … }
  opencode/        { … }
  copy-ticket/     { … }      … copy the lane's ticket key
  copy-ticket-url/ { … }      … copy the lane's ticket URL
  repository/                 ← per-repo actions (cwd = repo dir)
    open-pr/              { open-pr.sh, lanes-item.json }
    open-github-actions/ { … }
    open-terminal/       { … }
    open-fork/           { … }
    open-android-studio/ { … }
    open-vscode/         { … }
    open-finder/         { … }
    open-repo-in-browser/{ … } … open the repo's page on its git host
    copy-branch/         { … } … copy the current branch name
hook/                         ← <role>/<variant>/{ script, lanes-item.json }
  extract-ticket/leading-key/         { extract.sh, … }
  update-lane-description/git-status/  { describe.sh, … }
```

`lanes-item.json`:

```json
{
  "name": "Open PR",
  "icon": "arrow.triangle.pull",
  "description": "Focus or open this branch's pull-request page in Chrome."
}
```

These reproduce Lanes' former built-in launchers in plain `osascript` — fork the repo and edit them to fit your toolchain (e.g. swap VS Code for `zed`, Fork for Tower).
The Chrome/iTerm2 Apple Events are sent by a Lanes-spawned child, so they reuse Lanes' Automation permission (no extra prompt).

## License

[MIT](LICENSE) — copy, fork, and adapt these scripts freely.
(The Lanes app itself is separately licensed.)
