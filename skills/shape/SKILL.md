---
name: shape
description: Turn a triaged issue into something implementable, with effort scaled to its lane. Run when the user asks to shape, flesh out or spec a numbered issue.
disable-model-invocation: true
argument-hint: [issue-number]
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
---

# Shape an issue

Shape issue #$1. Read it first:

```
gh issue view $1 --json title,body,labels
```

The lane label decides everything below. No lane label → stop; it needs
`/triage` first.

## `lane:just-ship`

Nothing to shape. Say so and stop — the one-liner plus acceptance criteria is
the spec. If the issue genuinely can't be implemented from its body, that's a
triage miss: say what's missing and suggest the lane it should have had.

## `lane:think-a-little`

Write the spec yourself; the user skims it asynchronously.

1. Survey first: grep for the components, types and utilities this touches.
   For a wider surface, dispatch an Explore subagent rather than reading
   files into this session.
2. Write a spec **under one page** into the issue body, below the acceptance
   criteria: what changes, which files/components are involved, the data
   shapes at the seam, edge cases as observable outcomes, and what is
   explicitly out of scope.
3. Remove `needs-shaping`. Tell the user it's ready for a skim and `/build`.

## `lane:think-hard`

Alignment before spec. The spec is the residue of a shared understanding,
not a substitute for one.

1. **Interview the user** with AskUserQuestion — one question at a time, each
   with your recommended answer. Dig into what they haven't considered:
   edge cases, failure modes, migration/rollback, what happens to existing
   data, tradeoffs. Don't ask obvious questions. Continue until you both
   hold the same model of the change.
2. **Write the spec** into the issue body: the agreed behaviour, edge cases
   as observable outcomes, explicit non-goals, and any decision that was
   deliberately deferred.
3. **Decompose if needed.** Units must each be buildable, verifiable and
   landable alone — the *largest* such unit, not the smallest describable
   one. Split by verifiability and blast radius, never by layer. Each extra
   unit becomes its own issue with its own lane (a follow-up "wire it up"
   unit is usually `lane:think-a-little`, not Think Hard).
4. **Plan.** Files to touch and why — placement justified by the project's
   `PRINCIPLES.md`, not invented — test seams with their Given/When/Then,
   risks, decision points. Post the plan as an issue comment.
5. **Stop for approval.** This is the one human gate before the PR. On
   approval, remove `needs-shaping`.

## User-facing work, any lane

The Claude Design handoff bundle **is** the spec — link it in the issue and
do not restate its layout in prose. Prose describes states and behaviour;
only the design describes layout. If there is no bundle yet, shaping's output
is a note of what to design: the screens, and the empty/loading/error/
populated states each needs. When the bundle link lands in the issue, remove
`needs-design`. On the thinking lanes, do the behaviour spec here *before*
the design turn, so the design is drawn against agreed behaviour.

## Constraints

- Never expand a Just Ship issue "while you're here"
- The spec states what is out of scope, or it isn't finished
- An ambiguity discovered here is a success, not friction — it was about to
  cost a build session
