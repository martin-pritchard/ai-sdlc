# SDLC

One page. If it grows past one page, it's wrong.

**Guiding lights:** quality, speed, simplicity, repeatability.

---

## The one rule

**Triage before you flesh out.**

The most common waste is writing a spec for something that needed a
15-minute change. An idea enters as a one-line issue (`/idea`, or the Idea
template). It gets triaged. *Then* it gets specced — if its lane calls
for it.

## Triage

Ask in order. Stop at the first yes.

| | Question | Lane |
|---|---|---|
| 1 | If we get this wrong, is it expensive or impossible to undo? (user data, money, auth, public contracts, anything migrations touch) | **Think Hard** |
| 2 | Does it cross a seam? (new persistence, new external dependency, new shared state, or changes an existing contract) | **Think A Little** |
| 3 | Otherwise | **Just Ship** |

**Unsure? Use blast radius, not effort.** Worst outcome is a screen looks
wrong → Just Ship. Worst outcome is data is wrong → Think Hard.

**Importance is not size.** A one-line change to a pricing calculation is
Think Hard. A 2,000-line UI build against existing components is Just Ship.

---

## The path

Three commands, two human moments. Everything between them is agent-owned.

| Station | Just Ship | Think A Little | Think Hard |
|---|:-:|:-:|:-:|
| **`/triage`** — lane + acceptance criteria, batched | ● | ● | ● |
| **`/spec`** — make it implementable | – | ● spec, you skim | ● interview → spec → plan, **you approve** |
| **`/build`** — implement, verify, review, PR | ● | ● | ● |
| **PR review** — the second human moment | ● | ● | ● |

- **Spec, user-facing** → Claude Design. The handoff bundle *is* the spec —
  don't duplicate it in prose: issue prose describes states and behaviour,
  only the design describes layout. Name components as you want them in
  code; ask for empty, loading, error and populated states before exporting.
  Needing a design turn is orthogonal to lane (`needs-design`) — even a Just
  Ship ticket waits for its bundle before build.
- **Spec, Think Hard** → the agent interviews you first, one question at a
  time with its recommended answer, until you hold the same model. The spec
  is the residue of that alignment, not a substitute for it.
- **Decompose (Think Hard only):** split into units that can each be built,
  verified and landed alone. The right unit is the *largest* change one fresh
  session can build and verify — split by verifiability and blast radius,
  never by layer. A UI-only build against sample scenarios is one unit;
  "wire it to persistence" is another, in a different lane.
- **Logic seams are test-first on every lane.** An isolated agent writes
  the tests from the contract and acceptance criteria without ever seeing
  the implementation; the implementer makes them pass and never edits them.
  UI is verified by capture against the design instead. Lanes decide
  ceremony; checks run everywhere.
- **`/build` runs unattended** — fresh session, hooks block "done" on red,
  UI captured against the design, then a fresh-context scoped review, then
  the PR is marked ready. If mid-build the work breaks its lane's assumptions
  (new dependency, crossed seam, contract change, real ambiguity), it stops
  and surfaces rather than finishing on a stale premise.

## Definition of done

Mechanically checkable, all must hold. The canonical checklist lives in the
`build-rules` skill — one list, in the thing that enforces it, so it cannot
drift from itself.

## Models

Expensive models where a wrong *decision* is costly; cheap models where the
output is *mechanically checkable* — the verification loop catches a cheap
model's mistakes; nothing catches a bad plan except you, later.

Only two of these are pinned by the plugin (triage in its skill, review in
its agent). Specs and builds run on whatever the session runs — the middle
column is the recommendation, chosen per session by you.

| Job | Model |
|---|---|
| Triage, label plumbing | Haiku *(pinned)* |
| Just Ship / Think A Little builds | Sonnet |
| Interviews, specs, plans, Think Hard builds | Opus |
| Scoped review | Opus *(pinned)* |

## Speed rules

- The `Just Ship` lane has no ceremony. That is the point of it.
- Plan in cheap context; execute in a fresh session.
- Fork heavy work (research, test generation, audits) to subagents.
- Guarantees are hooks; requests are prompts.
- Two failed corrections → clear and restate, don't push on.
- More than ~5 screens in one build → split it, even though it feels slower.
- Parallel tickets in worktrees, but cap in-flight work at your PR-review
  attention — that is the real bottleneck.
