# sdlc

A risk-triaged development process for agentic coding. Ideas in one end,
verified PRs out the other, with the amount of ceremony matched to what
breaks if you get it wrong.

The process is one page: [`SDLC.md`](SDLC.md). The GitHub wiring
(labels-first, board optional) is [`GITHUB.md`](GITHUB.md). Everything below
is the machinery.

## Components

| Component | Type | Invoked |
|---|---|---|
| `build-rules` | skill | by Claude, whenever implementing |
| `/triage` | skill | by you, batched (runs on Haiku) |
| `/shape <n>` | skill | by you, thinking lanes only |
| `/build <n>` | skill | by you — runs unattended to a ready PR |
| `/audit` | skill | by you, occasionally |
| `scoped-reviewer` | agent | spawned by `/build` (pinned to Opus) |
| `blind-test-writer` | agent | spawned on Think Hard logic seams |
| formatter | hook | automatically on every write |
| verify | hook | Stop hook — blocks "done" while `.claude/verify.sh` fails |

`build-rules` is the only skill Claude invokes on its own. The rest carry
`disable-model-invocation: true`, so they cost nothing until you type them.

## The path

```
idea → issue (backlog)
     → /triage           lane labels + acceptance criteria, you approve a table
     → /shape n          spec (Think A Little) or interview→spec→plan (Think Hard)
     → /build n          implement → verify → fresh-context review → PR ready
     → you review the PR → merge
```

Human moments: the triage table, the Think Hard plan approval, the PR.
`Just Ship` work has exactly two: triage and the PR.

## Install

This repo is its own marketplace:

```
/plugin marketplace add martin-pritchard/ai-sdlc
/plugin install sdlc@ai-sdlc
```

Or, to try it locally without installing:

```
claude --plugin-dir .
```

## Per-repo setup

Three things the plugin cannot do for you:

1. **Labels** — run `scripts/setup-labels.sh` once in each repo (needs `gh`).
2. **`.claude/verify.sh`** — create it in the project: build + lint + unit
   tests, non-zero exit on failure, `chmod +x`. This is what lets `/build`
   run unattended; without it the Stop hook passes silently and verification
   is advisory.
3. **`hooks/scripts/format.sh`** — fill in the formatter for your stack. It
   is a stub until you do.

Optional: a GitHub Project as a dashboard — see `GITHUB.md`. The system
works identically without one.

## Notes

- Model choices are deliberate: triage on Haiku (mechanical, human-confirmed),
  builds on the session model, review pinned to Opus (judgement, one bounded
  pass). If triage quality drops, delete `model: haiku` from its frontmatter
  and re-measure before adding anything else.
- Edits to a `SKILL.md` take effect immediately. Changes to `hooks/` or
  `agents/` need `/reload-plugins` or a restart.
- Run `claude plugin validate .` after changes.
- Keep every file here short. A bloated process plugin is the thing this
  process exists to avoid.
