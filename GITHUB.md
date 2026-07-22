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
| `needs-spec` | Not implementable yet | `/triage` (on the two thinking lanes) |
| `needs-design` | New/changed layout awaiting a Claude Design turn | `/triage` (any lane); removed when the bundle link lands |

Everything else is derived, so it can't drift:

| State | Derived from |
|---|---|
| Ready for development | lane label present, no `needs-spec`, no `needs-design`, no PR |
| In development | draft PR with `Closes #n` |
| In review | that PR marked ready |
| Done | PR merged (closes the issue) |

## Lifecycle

```
idea → /idea (or the Idea template) → issue (backlog)
     → /triage        removes backlog, adds lane (+ needs-spec, + needs-design), appends AC
     → /spec n        (thinking lanes only) spec onto the issue, removes needs-spec
     → design turn    (layout work, any lane) you, in Claude Design; bundle link onto the
                      issue removes needs-design — the bundle IS the layout spec
     → /build n       draft PR "Closes #n" → implement → verify → scoped review → PR ready
     → you review the PR → merge → issue closes
```

Your manual moments: the triage table, the Think Hard spec approval, the PR.
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
  has to go looking, the spec was too thin.
- Board/backlog operations and code operations are different sessions.

## The optional board

A read-only dashboard. Labels stay the source of truth; you never move a
card; agents never touch it. If you check it less than weekly, delete it —
the labels keep working. Setup is manual (GitHub doesn't expose Project
workflow toggles to the API), but it's five minutes, once:

1. **Create it.** Repo → Projects tab → New project → Board.
2. **Auto-add.** In the project: ⋯ (top right) → Workflows →
   Auto-add to project → choose this repo, filter `is:open`, turn on.
3. **Statuses.** Edit the Status field's options down to `Backlog` and
   `Done` — the only two the built-in workflows can actually maintain
   (they fire on add/close/merge, not on label changes).
4. **Workflows.** On the same Workflows page: *Item added to project* →
   `Backlog`; *Item closed* → `Done`; *Pull request merged* → `Done`;
   *Auto-archive items* → on, filter `is:closed`.
5. **Views for the middle states.** These derive from labels live, so
   they never need maintenance. Add a saved view per state:
   - **Needs spec** — filter `is:open label:needs-spec`
   - **Needs design** — filter `is:open label:needs-design`
   - **Ready to build** — filter `is:open -label:backlog -label:needs-spec
     -label:needs-design no:pr`
   - **In flight** — filter `is:open is:pr` (draft = building, ready =
     awaiting your review)

Don't add In-development/In-review Status columns: no built-in workflow
can move cards into them, so they'd rot into a lie within a week —
exactly what the derived-states table exists to prevent.

## If it starts feeling slow

Check in order — it's almost always the first one.

1. Items sitting in `needs-spec` → you're writing specs for things that should be `Just Ship`.
2. Sessions are expensive → the agent is querying GitHub mid-build.
3. Triage takes real time → you're triaging one at a time instead of batching.
4. PRs queue on you → too many tickets in flight; cap it, or the tickets are too small.
