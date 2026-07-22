---
name: build
description: Implement a single GitHub issue end to end - verify, fresh-context review, PR ready - within the SDLC boundaries. Run when the user asks to build or implement a numbered issue.
disable-model-invocation: true
argument-hint: [issue-number]
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Agent
---

# Build an issue

Implement issue #$1. Run in a fresh session. Once started, there is no human
between here and a ready PR — the checks below are what make that safe.

## Step 0 - check the guarantee

If `.claude/verify.sh` is missing or not executable, verification in this
repo is **advisory** — the Stop hook will pass silently and "done" means
nothing. Stop and say so before any work: the fix is `/setup`. Proceed only
if the user explicitly says to.

## Step 1 - read

```
gh issue view $1 --json title,body,labels
```

Read nothing else from GitHub. Everything needed is in the issue body. If it
is not there, stop and say so rather than going looking — that is a shaping
failure worth surfacing. An issue still carrying `needs-shaping` goes back to
`/shape`, not into code. An issue that changes layout must carry a design
bundle link (or DesignSync project reference) and no `needs-design` label —
otherwise stop and say so; layout is never improvised from the issue's prose.

## Step 2 - branch and open a draft PR

Branch from fresh main. A PR needs a commit to exist, so push an empty one
first (`git commit --allow-empty -m "chore: start #$1"`), then open a draft
pull request whose body contains `Closes #$1` — all before writing any code.

## Step 3 - implement

Apply the build-rules skill. Do not restate its contents; follow them.

- If the issue carries a design handoff bundle, implement against it and
  honour the component names used in the design. Build layout from the
  design, not from the issue's prose.
- On `lane:think-hard`, build in the plan's units, in order.
- **Logic seams are test-first on every lane.** For any slice that is logic
  with a contract (reducer, transform, adapter, domain rule), spawn the
  `blind-test-writer` agent — before implementing — then make its tests pass.
  The agent has no read tools, so paste into its prompt everything it needs:
  the contract text itself, the acceptance criteria, the test framework, and
  the path where tests belong. Anything left out does not exist for it. **Never edit a
  blind-written test to make it pass.** A test that looks wrong is an
  ambiguity: check it against the issue; if it is genuinely wrong, clarify
  the criteria and regenerate blind. Exploratory UI slices skip unit tests —
  the design plus screenshot comparison is their verification loop.
- Commit per coherent step, Conventional Commits (`type(scope): summary`)
  unless the repo's log clearly follows another convention.

**Escalation rule.** If at any point — including halfway through — the work
breaks its lane's assumptions (needs a new dependency, crosses a seam that
wasn't agreed, changes a contract or schema, or hits genuine spec ambiguity),
**stop**. Say which assumption broke, comment it on the issue, and hand back.
Never finish a ticket on a premise that no longer holds; work already done
becomes input to re-shaping, not waste.

## Step 4 - verify

Run the project's build, static checks and tests. For UI work, capture each
screen state, compare it against the design, then list and fix the
differences. Do not report completion until the definition of done in
build-rules holds. The Stop hook enforces the project's check — you cannot
report done on red, and that is a guarantee, not discretion.

## Step 5 - review

Spawn the `scoped-reviewer` agent — fresh context, never this session — with
the diff and the issue's stated requirements. Fix every blocking finding and
re-verify. Log non-blocking findings on the issue rather than expanding scope.

## Step 6 - hand back

Mark the PR ready for review. Summarise in three lines: what changed, what
was verified (with evidence — test output, screenshot paths), what was
deferred to `DECISIONS.md`.

Do not merge.
