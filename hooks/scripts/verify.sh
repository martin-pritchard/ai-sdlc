#!/usr/bin/env bash
# Stop hook: the agent cannot report done while the project's check fails.
#
# The plugin provides the enforcement; the project provides the check. Create
# an executable `.claude/verify.sh` in the project that builds, lints and runs
# the unit suite, exiting non-zero on failure. Without one, this hook passes
# silently - verification is then advisory, which SDLC.md tells you to fix.
#
# Scope: runs only when THIS session wrote something since its last green
# verify - the PostToolUse hook drops a per-session sentinel on every
# Write/Edit and a green run clears it, so question-answering turns and
# read-only sessions (/idea, /spec) stop instantly, and a parallel build's
# WIP cannot ambush an unrelated session's Stop. Strength: blocking
# forces one fix cycle per stop (the stop_hook_active guard prevents an
# infinite loop), so a persistent red ends as an explicit blocked hand-back,
# not an endless retry.
set -uo pipefail

input=$(cat)

# A previous block already restarted the turn once - don't loop forever.
if printf '%s' "$input" | grep -q '"stop_hook_active":[[:space:]]*true'; then
  exit 0
fi

sid=$(printf '%s' "$input" \
  | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
  | head -1)

sentinel="${TMPDIR:-/tmp}/claude-sdlc-needs-verify-${sid:-nosess}-$(pwd | cksum | cut -d' ' -f1)"

# Nothing written since the last green verify - nothing to check.
[ -f "$sentinel" ] || exit 0

if [ -x ".claude/verify.sh" ]; then
  if ! out=$(./.claude/verify.sh 2>&1); then
    {
      echo "Project verification failed (.claude/verify.sh). You cannot report done on red - fix the failure, or explicitly hand back as blocked."
      echo "$out" | tail -40
    } >&2
    exit 2
  fi
fi

rm -f "$sentinel"
exit 0
