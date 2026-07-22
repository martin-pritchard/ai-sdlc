---
name: setup
description: One-command per-repo SDLC setup - verification script, formatter, labels, issue template, and proof the loop works. Run when the user asks to set up the sdlc in a repo.
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Set up this repo

From install to a working, hook-enforced loop in one command. Idempotent —
safe to re-run. Never overwrite an existing file without showing what would
change and asking.

## Step 1 - detect the stack

Look for manifests: `package.json`, `*.xcodeproj` / `Package.swift`,
`build.gradle*`, `Cargo.toml`, `pyproject.toml`, `go.mod`. From them, work
out the real build, static-check, unit-test and format commands (npm scripts,
schemes, targets). If the repo is empty or the stack is undecided, say so and
create the files as loud stubs rather than guessing.

## Step 2 - the verification script

Write an executable `.claude/verify.sh`: build + static checks + **unit**
tests (fast — the full suite belongs in CI), exiting non-zero on any failure.
This is what the plugin's Stop hook runs; it is the guarantee that lets
`/build` run unattended.

## Step 3 - the formatter

Write an executable `.claude/format.sh` for the detected stack. The plugin's
PostToolUse hook delegates to it after every write. Formatting rules never
belong in CLAUDE.md; this script is the enforcement mechanism.

## Step 4 - labels

Create the SDLC labels (idempotent):

```
gh label create "backlog"             --color "ededed" --description "Captured, untriaged" --force
gh label create "needs-shaping"       --color "d4c5f9" --description "Not implementable yet - run /shape" --force
gh label create "needs-design"        --color "bfdadc" --description "New/changed layout awaiting a Claude Design turn" --force
gh label create "lane:just-ship"      --color "0e8a16" --description "No ceremony: build straight from the issue" --force
gh label create "lane:think-a-little" --color "fbca04" --description "Crosses a seam: spec first, human skims" --force
gh label create "lane:think-hard"     --color "d93f0b" --description "Expensive to undo: interview, spec, plan, approval" --force
```

If `gh` isn't authenticated or there's no remote yet, skip with a note —
everything else still works locally.

## Step 5 - the issue template

Write `.github/ISSUE_TEMPLATE/idea.md` so capture is one line and triage
finds it:

```markdown
---
name: Idea
about: "One sentence: who it's for, what changes for them. Nothing more."
labels: backlog
---
```

## Step 6 - architecture principles

Copy `${CLAUDE_PLUGIN_ROOT}/PRINCIPLES.md` to the repo root if the repo has
no `PRINCIPLES.md`. The repo's copy is the live one — the user adapts it and
adds stack appendices (`PRINCIPLES.ios.md`, `PRINCIPLES.web.md`) as the
project grows. Add `See @PRINCIPLES.md` to the repo's `CLAUDE.md` (create a
minimal one if absent) so placement rules are always in context.

## Step 7 - prove the loop

Run `.claude/verify.sh` and show the output. If it passes because there is
nothing to check yet (no tests, no build), say so **loudly** — a vacuously
green check is advisory verification wearing a costume.

Finish with a table: file/label → created, updated, or already present. Then
point at the path: capture an idea, `/triage`, `/build`.
