#!/usr/bin/env bash
# Stop hook: the agent cannot report done while the project's check fails.
#
# The plugin provides the enforcement; the project provides the check. Create
# an executable `.claude/verify.sh` in the project that builds, lints and runs
# the unit suite, exiting non-zero on failure. Without one, this hook passes
# silently - verification is then advisory, which SDLC.md tells you to fix.
set -uo pipefail

input=$(cat)

# A previous block already restarted the turn once - don't loop forever.
if printf '%s' "$input" | grep -q '"stop_hook_active":[[:space:]]*true'; then
  exit 0
fi

if [ -x ".claude/verify.sh" ]; then
  if ! out=$(./.claude/verify.sh 2>&1); then
    {
      echo "Project verification failed (.claude/verify.sh). You cannot report done on red - fix the failure, or explicitly hand back as blocked."
      echo "$out" | tail -40
    } >&2
    exit 2
  fi
fi

exit 0
