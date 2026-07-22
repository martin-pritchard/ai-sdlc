# SDLC on GitHub

Companion to `SDLC.md`. **Issues and labels are the source of truth. A
Project board is an optional dashboard — the system works identically with
it deleted.**

---

## Three rules

1. **Agents touch labels, never a board.** Board automations render state
   that already exists; nothing writes to a board directly.
2. **The agent never queries GitHub mid-build.** One issue read at the
   start, one PR at the end.
3. **Triage happens in batches.** You approve a table of decisions once,
   not a decision per idea.

---

## Labels

Run `/setup` once per repo (or `scripts/setup-labels.sh` for labels alone).

| Label | Meaning | Set by |
|---|---|---|
| `backlog` | Captured, untriaged | issue template (`/setup` creates it) |
| `lane:just-ship` · `lane:think-a-little` · `lane:think-hard` | Triage verdict | `/triage` |
| `needs-shaping` | Not implementable yet | `/triage` (on the two thinking lanes) |

Everything else is derived, so it can't drift:

| State | Derived from |
|---|---|
| Ready for development | lane label present, no `needs-shaping`, no PR |
| In development | draft PR with `Closes #n` |
| In review | that PR marked ready |
| Done | PR merged (closes the issue) |

## Lifecycle

```
idea → issue (backlog)
     → /triage        removes backlog, adds lane (+ needs-shaping), appends AC
     → /shape n       (thinking lanes only) spec onto the issue, removes needs-shaping
     → /build n       draft PR "Closes #n" → implement → verify → scoped review → PR ready
     → you review the PR → merge → issue closes
```

Your manual moments: the triage table, the Think Hard shape approval, the PR.
`Just Ship` work never touches you between triage and the PR.

## Speed concessions

- `Just Ship` items can be captured and landed in the same hour.
- Trivial work skips the issue entirely — open a PR; the PR is the record.
- Nothing waits for a ceremony. No standup, no grooming, no sprint.

## Token rules

- Use `gh` with explicit `--json` fields; never a GitHub MCP server in build
  sessions, never an unfiltered `gh issue list`.
- `gh issue view 42 --json title,body` — tens of tokens. That's the budget.
- Everything the build session needs lives in the issue body. If the agent
  has to go looking, shaping under-specified it.
- Board/backlog operations and code operations are different sessions.

## The optional board

If you want the visual: create a GitHub Project, enable auto-add
(`is:issue is:open`) and the built-in PR-state workflows, and add a Status
single-select mirroring the derived states above. You never move a card;
agents never touch it. If you check it less than weekly, delete it — the
labels keep working.

## If it starts feeling slow

Check in order — it's almost always the first one.

1. Items sitting in `needs-shaping` → you're shaping things that should be `Just Ship`.
2. Sessions are expensive → the agent is querying GitHub mid-build.
3. Triage takes real time → you're triaging one at a time instead of batching.
4. PRs queue on you → too many tickets in flight; cap it, or the tickets are too small.
