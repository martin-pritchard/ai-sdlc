# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Orientation

This is a **Claude Code plugin** (`sdlc`), not an application — the "source" is
prompts (skill and agent markdown) plus a few bash hooks; there is no build
step and no test suite. `README.md` is the full picture: the process, a worked
example, the component table, the separation-of-duties model, and the
contributor notes (model pinning, what-takes-effect-when, keeping files short).
Read it — plus `SDLC.md` and `GITHUB.md` — before changing how the process
behaves. This file only adds the operational detail README doesn't carry.

## Commands

- `claude plugin validate .` — validate the manifest; CI runs it on every push
  and PR. Run locally after touching `.claude-plugin/*.json`, skill/agent
  frontmatter, or hook wiring.
- `claude --plugin-dir .` — load the plugin locally without installing.
- `bash -n hooks/scripts/verify.sh` — syntax-check a hook script.
- `bash scripts/setup-labels.sh` — the single source of truth for SDLC label
  names, colours and descriptions.

## The sentinel — the one mechanism that is easy to break silently

The two hook scripts coordinate through a sentinel file, and their correctness
is coupled:

- `hooks/scripts/format.sh` (PostToolUse on `Write|Edit`) **arms** the
  sentinel, recording that this session wrote something.
- `hooks/scripts/verify.sh` (Stop) runs the project's `.claude/verify.sh` and
  blocks "done" on a non-zero exit — but only if the sentinel is armed. A
  `stop_hook_active` guard caps this at one fix cycle per stop.
- The key is **`session_id` + working directory**, so read-only sessions
  (`/idea`, `/spec`) never arm it and a parallel build's WIP cannot block an
  unrelated session. Both scripts build the key string independently; if you
  edit one, keep the two **byte-identical** or the gate silently stops firing.

## Maintaining the repo

- **Releases:** bump `version` in `.claude-plugin/plugin.json` (that file only),
  in its own `chore(release): bump plugin to X.Y.Z` commit, straight to `main`.
- **`templates/PRINCIPLES.md` is plugin-managed:** a consuming repo's
  `docs/PRINCIPLES.md` is overwritten from it wholesale, never merged — so it is
  not designed to be hand-edited downstream. Project-specific rules live in that
  repo's stack appendices and its own `CLAUDE.md`.
- **Doc placement:** the root holds only `README.md`, `LICENSE`, and this
  `CLAUDE.md` (Claude Code auto-loads it only from root); every other doc lives
  under `docs/`.
- **`.gitignore` gotcha:** the user-level gitignore excludes `build/`
  directories, which would swallow the `/build` skill — `!skills/build/`
  re-includes it. Don't remove that line.
