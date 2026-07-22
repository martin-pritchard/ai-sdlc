---
name: idea
description: Capture a feature idea as a one-line backlog issue, untriaged and unelaborated. Run when the user wants to capture, note down or file an idea.
disable-model-invocation: true
argument-hint: [one sentence]
allowed-tools: Bash(gh:*)
---

# Capture an idea

Capture is a reflex, not a session. For each idea in `$ARGUMENTS`:

```
gh issue create --title "<the sentence>" --label backlog --body ""
```

Reply with issue number and title, one line each. Nothing else.

## Constraints

- The title is the user's sentence, trimmed — never rewritten, never
  improved.
- No body, no acceptance criteria, no other labels, no opinion on lane or
  effort. Thinking starts at `/triage`; anything added here pre-empts it.
- Several ideas in one invocation → one issue each.
- No argument → ask for the one sentence: who it's for, what changes for
  them.
- If the `backlog` label is missing, `gh label create` it (colour and
  description in the plugin's `scripts/setup-labels.sh`), then retry.
