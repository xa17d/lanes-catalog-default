# Lane working agreement

This folder is a **lane**: a workspace whose immediate subfolders are the
**repositories** you will work in. There is no single project here; each
repository is independent and carries its own conventions.

## Before doing anything in a repository

For **every** immediate subfolder of this lane (each repository), read that
repository's own agent instructions first and follow them while working inside
it:

1. List the immediate subfolders of this lane directory.
2. In each subfolder, look for an `AGENTS.md` (preferred) or a `CLAUDE.md` at its
   root and read it in full.
3. Treat those per-repository instructions as authoritative for any work in that
   repository. They override anything generic.

If a repository has neither file, fall back to its `README` and the surrounding
repo conventions, and ask before assuming project-specific behavior.

## Scope rules

- Keep changes scoped to one repository at a time; do not let one repo's
  conventions leak into another.
- When a task spans multiple repositories, read each one's `AGENTS.md` /
  `CLAUDE.md` before touching it.
- Do not modify files in this lane root or in sibling repositories unless the
  task explicitly calls for it.
