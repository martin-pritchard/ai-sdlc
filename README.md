# sdlc

A risk-triaged development process for agentic coding. Ideas in one end,
verified PRs out the other, with the amount of ceremony matched to what
breaks if you get it wrong.

## Quickstart

```
/plugin marketplace add martin-pritchard/ai-sdlc
/plugin install sdlc@ai-sdlc
/sdlc:setup             # in your repo: verify + format scripts, labels, issue template, secrets hook
```

Then: `/sdlc:idea one sentence` → `/sdlc:triage` → (`/sdlc:spec n` on the
thinking lanes) → `/sdlc:build n` → review the PR. That's the whole loop.

Installed as a plugin, every command carries the `sdlc:` prefix — Claude
Code namespaces all plugin skills, no opt-out. The rest of these docs use
the short names (`/idea`, `/triage`) for readability.

The names, in plain English: **idea** captures a one-liner into the backlog,
**triage** sorts the backlog by blast radius, **spec** turns an issue into
something an agent can build unattended, and **build** takes it from issue
to ready PR.

## What it looks like in practice

Say you're building an invoicing app. Ideas arrive as one-liners the moment
you have them — 30 seconds each, no thinking yet:

```
/idea Settings screen typo: 'Curency'
/idea Export invoices as CSV
/idea Support multiple currencies on invoices
```

Each becomes a title-only issue labelled `backlog`. (Away from a terminal,
the repo's "Idea" issue template — created by `/setup` — does the same
thing from the GitHub UI.)

An idea can also be epic-shaped: `/idea Build the invoicing MVP from the
design bundle` is legal. It triages `think-hard` — the decomposition is the
expensive decision — and `/spec`'s decompose step fans it out into child
issues, each with its own lane. You never split work up before capture.

**`/triage`** — one session, the whole backlog at once. Claude proposes a
table; nothing happens until you confirm it:

| # | Title | Lane | Why |
|---|---|---|---|
| 12 | Settings screen typo | `just-ship` | worst outcome: a screen looks wrong |
| 13 | Export invoices as CSV | `think-a-little` | new seam: export touches the invoice data contract |
| 14 | Multiple currencies | `think-hard` | money, stored amounts — wrong is expensive to undo |

You say "yes". Labels land, acceptance criteria are appended, and #12 is
buildable *right now* — a `just-ship` issue never gets a spec.

**`/build 12`** — fresh session, then hands-off: branch → draft PR → fix →
the Stop hook won't let it claim done until `.claude/verify.sh` is green →
a fresh-context review → PR flips to ready. Your only involvement is the
merge button.

**`/spec 13`** — Claude surveys the code and writes a one-page spec into
the issue body: files touched, the data shape at the seam, edge cases,
what's out of scope. You skim it whenever, then `/build 13`.

**`/spec 14`** — the interview lane. One question at a time, each with a
recommendation:

> Existing invoices have no currency field. Backfill them as GBP, or treat
> a missing currency as GBP at display time? **Recommended: backfill** — a
> one-off migration now beats a null-check forever.

Ten minutes of that, then the spec and plan land in the issue body. You
approve — the one human gate before the PR — and `/build 14` runs against
the plan.

Your total involvement across all three: one triage table, one interview,
three PR reviews. Everything between those moments is agent-owned.

## Docs

The process is one page: [`SDLC.md`](SDLC.md). The GitHub wiring
(labels-first, board optional) is [`GITHUB.md`](GITHUB.md). Architecture
rules — where code goes — are [`PRINCIPLES.md`](templates/PRINCIPLES.md), which
`/setup` copies into each repo for the project to own and adapt. To try locally
without installing: `claude --plugin-dir .`

## Components

| Component | Type | Invoked |
|---|---|---|
| `build-rules` | skill | by Claude, whenever implementing |
| `/setup` | skill | by you, once per repo |
| `/idea <sentence>` | skill | by you, the moment an idea strikes |
| `/triage` | skill | by you, batched (runs on Haiku) |
| `/spec <n>` | skill | by you, thinking lanes only |
| `/build <n>` | skill | by you — runs unattended to a ready PR |
| `/audit` | skill | by you, occasionally |
| `scoped-reviewer` | agent | spawned by `/build` (pinned to Opus) |
| `blind-test-writer` | agent | spawned on logic seams, every lane |
| formatter | hook | on every write → delegates to `.claude/format.sh` with the file path |
| verify | hook | at Stop, on turns that wrote files → blocks "done" while `.claude/verify.sh` fails |

`build-rules` is the only skill Claude invokes on its own. The rest carry
`disable-model-invocation: true`, so they cost nothing until you type them.

## Separation of duties

Four parties, no self-grading:

- **Tests** — `blind-test-writer` writes them from the contract and
  acceptance criteria. It has no read tools, so the blindness is structural,
  not a request.
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
- The Stop hook skips turns that wrote nothing, and a block forces one fix
  cycle per stop rather than looping forever — a stubborn red ends as an
  explicit blocked hand-back, not a silent pass and not an infinite retry.
- Edits to a `SKILL.md` take effect immediately. Changes to `hooks/` or
  `agents/` need `/reload-plugins` or a restart.
- CI runs `claude plugin validate` on every push; run it locally after
  manifest changes.
- Keep every file here short — skills stay under ~2k tokens, and `/audit`
  exists to hold that line. A bloated process plugin is the thing this
  process exists to avoid.
