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
PostToolUse hook delegates to it after every write, passing the changed
file's path as `$1` — format just that file when the stack's tooling allows
it, falling back to repo-wide only if it doesn't. Formatting rules never
belong in CLAUDE.md; this script is the enforcement mechanism.

## Step 4 - labels

Create the SDLC labels (idempotent) — the script is the single source of
truth for names, colours and descriptions:

```
bash ${CLAUDE_PLUGIN_ROOT}/scripts/setup-labels.sh
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

## Step 6 - secrets hygiene

Copy `${CLAUDE_PLUGIN_ROOT}/templates/pre-commit` to `.githooks/pre-commit`
(executable), and `${CLAUDE_PLUGIN_ROOT}/templates/SECURITY.md` to
`SECURITY.md` — skip the doc if the repo already has one (root or `docs/`);
the repo's copy is live and gets adapted, with stack-specific guards
appended to the hook *below* the gitleaks section.

Then resolve `git config core.hooksPath` — never clobber another tool's
hooks:

- unset → `git config core.hooksPath .githooks`
- already `.githooks` → nothing to do
- anything else (husky, lefthook, …) → leave it alone; add a gitleaks call
  to the hooks that path already runs, and say what you did

Finally `command -v gitleaks` — if missing, tell the user
(`brew install gitleaks`); the hook fails closed until it's installed. If
the repo has a GitHub remote, remind them to verify push protection is on
(Settings → Code security): it only matches known vendor patterns, and the
hook exists to catch the opaque keys it misses.

## Step 7 - architecture principles

Copy `${CLAUDE_PLUGIN_ROOT}/PRINCIPLES.md` to the repo root if the repo has
no `PRINCIPLES.md`. The repo's copy is the live one — the user adapts it and
adds stack appendices (`PRINCIPLES.ios.md`, `PRINCIPLES.web.md`) as the
project grows. Add a line to the repo's `CLAUDE.md` (create a minimal one if
absent): `Placement rules live in PRINCIPLES.md — read it before creating or
moving files.` A plain mention, not an `@` import: build sessions read it
when placing files; question-answering sessions shouldn't pay ~2k tokens of
architecture rules on every turn.

## Step 8 - prove the loop

Run `.claude/verify.sh` and show the output. If it passes because there is
nothing to check yet (no tests, no build), say so **loudly** — a vacuously
green check is advisory verification wearing a costume.

Finish with a table: file/label → created, updated, or already present. Then
point at the path: `/idea`, `/triage`, `/build`.
