# lanes-catalog-default

The default [Lanes](https://github.com/xa17d/lanes) **catalog** — a git repo of shared config (scripts, hooks, template) you subscribe to from Lanes' Settings.

Subscribing clones this repo under `<root>/.lanes/catalog/<id>/checkout/`; you then enable the items you want from the Catalogs editor in Settings, which writes `.catalog` pointer files into your own `<root>/.lanes/config/`.
See the Lanes [CONFIGURATION.md](https://github.com/xa17d/lanes/blob/main/doc/CONFIGURATION.md#catalogs) for the full reference.

## Layout

Every catalog **item is a folder** holding its payload plus a `lanes-item.json` companion (default name, icon, and a description shown in the editor).
A `lanes-catalog.json` at the root declares the catalog's display name.

```
lanes-catalog.json
script/                       ← lane actions (cwd = lane dir)
  open-terminal-iterm2/  { … }  … iTerm2 (focus/create a tagged session)
  open-terminal-app/     { … }  … Terminal.app (focus/create a title-tagged window)
  open-terminal-ghostty/ { … }  … Ghostty (focus/create via its AppleScript API)
  open-finder/     { … }
  claude-iterm2/   { … }      … Claude in an iTerm2 session
  claude-ghostty/  { … }      … Claude in a Ghostty window
  opencode-iterm2/ { … }      … opencode in an iTerm2 session
  opencode-ghostty/{ … }      … opencode in a Ghostty window
  copy-ticket/     { … }      … copy the lane's ticket key
  copy-ticket-url/ { … }      … copy the lane's ticket URL
  repository/                 ← per-repo actions (cwd = repo dir)
    open-pr/              { open-pr.sh, lanes-item.json }
    open-github-actions/ { … }
    open-terminal-iterm2/  { … }  … iTerm2
    open-terminal-app/     { … }  … Terminal.app
    open-terminal-ghostty/ { … }  … Ghostty
    open-fork/           { … }
    open-android-studio/ { … }
    open-vscode/         { … }
    open-finder/         { … }
    open-repo-in-browser/{ … } … open the repo's page on its git host
    copy-branch/         { … } … copy the current branch name
hook/                         ← <role>/<variant>/{ script, lanes-item.json }
  extract-ticket/leading-key/         { extract.sh, … }
  update-lane-description/jira-status/{ describe.sh, … } … Jira status badge
  cleanup/close-windows/              { cleanup.sh, … }  … close the lane's windows/tabs on archive/delete
clone-repo/                   ← <variant>/{ clone.sh, lanes-item.json } — custom "Clone repo…" handler
  shallow/                            { clone.sh, … }    … fast shallow clone (git clone --depth 1)
template/                     ← <variant>/ seeded into each new lane
  basic-agent-instructions/ { CLAUDE.md, lanes-item.json } … lane working agreement
```

`lanes-item.json`:

```json
{
  "name": "Open PR",
  "icon": "arrow.triangle.pull",
  "description": "Open this branch's pull-request page in the configured browser, reusing Chrome tabs when using Chrome."
}
```

These reproduce Lanes' former built-in launchers in plain `osascript` — fork the repo and edit them to fit your toolchain (e.g. swap VS Code for `zed`, Fork for Tower).
The Chrome/iTerm2/Ghostty Apple Events are sent by a Lanes-spawned child, so they reuse Lanes' Automation permission (no extra prompt).
The Ghostty variants use Ghostty's AppleScript API (1.3.0+) and are drop-in alternatives to the iTerm2/Terminal.app ones — enable whichever terminal you use.

## Browser preference

With Lanes 1.1.0 or newer, put a macOS application name in `<root>/.lanes/config/browser` to choose the browser for work links:

```text
Google Chrome
```

Lanes passes this value as `LANES_BROWSER` to action scripts.
**Open GitHub Actions**, **Open repo in browser**, and **Open PR** honor it for HTTP/HTTPS URLs.
Any app name supported by macOS `open -a` works, including `Safari` and `Firefox`; `default` explicitly selects the system default browser.
With no preference (missing or empty), GitHub Actions and repository pages use the system default browser, and Open PR keeps its existing Chrome behavior.
Open PR also reuses Chrome tabs when `Google Chrome` is explicitly selected.
Other actions, including Finder and editor launchers, are unaffected.
Apply the catalog update in Lanes' Settings to use the updated actions.

## License

[MIT](LICENSE) — copy, fork, and adapt these scripts freely.
(The Lanes app itself is separately licensed.)
