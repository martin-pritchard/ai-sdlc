# sdlc

A risk-triaged development process for agentic coding. Ideas in one end,
verified PRs out the other, with the amount of ceremony matched to what
breaks if you get it wrong.

## Quickstart

```
/plugin marketplace add martin-pritchard/ai-sdlc
/plugin install sdlc@ai-sdlc
/setup                  # in your repo: verify + format scripts, labels, issue template
```

Then: capture an idea as a one-line issue → `/triage` → (`/shape n` on the
thinking lanes) → `/build n` → review the PR. That's the whole loop.

The process is one page: [`SDLC.md`](SDLC.md). The GitHub wiring
(labels-first, board optional) is [`GITHUB.md`](GITHUB.md). To try locally
without installing: `claude --plugin-dir .`

## Components

| Component | Type | Invoked |
|---|---|---|
| `build-rules` | skill | by Claude, whenever implementing |
| `/setup` | skill | by you, once per repo |
| `/triage` | skill | by you, batched (runs on Haiku) |
| `/shape <n>` | skill | by you, thinking lanes only |
| `/build <n>` | skill | by you — runs unattended to a ready PR |
| `/audit` | skill | by you, occasionally |
| `scoped-reviewer` | agent | spawned by `/build` (pinned to Opus) |
| `blind-test-writer` | agent | spawned on logic seams, every lane |
| formatter | hook | on every write → delegates to `.claude/format.sh` |
| verify | hook | at Stop → blocks "done" while `.claude/verify.sh` fails |

`build-rules` is the only skill Claude invokes on its own. The rest carry
`disable-model-invocation: true`, so they cost nothing until you type them.

## Separation of duties

Four parties, no self-grading:

- **Tests** — `blind-test-writer` writes them from the contract and
  acceptance criteria, forbidden from reading the implementation.
- **Code** — the `/build` session makes those tests pass and never edits them.
- **Review** — `scoped-reviewer`, a fresh context that didn't write the code,
  scoped to correctness only.
- **Enforcement** — hooks, which are deterministic: red check, no "done".

## Human moments

The triage table, the Think Hard plan approval, and the PR. `Just Ship`
work has exactly two: triage and the PR.

## Notes

- Model choices are deliberate: triage on Haiku (mechanical, human-confirmed),
  builds on the session model, review pinned to Opus (judgement, one bounded
  pass). If triage quality drops, delete `model: haiku` from its frontmatter
  and re-measure before adding anything else.
- `/setup` is idempotent; re-run it after a stack change to refresh
  `.claude/verify.sh` and `.claude/format.sh`.
- Edits to a `SKILL.md` take effect immediately. Changes to `hooks/` or
  `agents/` need `/reload-plugins` or a restart.
- CI runs `claude plugin validate` on every push; run it locally after
  manifest changes.
- Keep every file here short — skills stay under ~2k tokens, and `/audit`
  exists to hold that line. A bloated process plugin is the thing this
  process exists to avoid.
