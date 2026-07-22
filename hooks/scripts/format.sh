#!/usr/bin/env bash
# PostToolUse hook: deterministic formatting after every write or edit.
#
# The plugin provides the trigger; the project provides the formatter. /setup
# scaffolds an executable `.claude/format.sh` for the repo's stack. Without
# one, this passes silently. Nothing about formatting or naming should ever
# appear in CLAUDE.md - the project script is the enforcement mechanism.
set -uo pipefail

if [ -x ".claude/format.sh" ]; then
  ./.claude/format.sh >/dev/null 2>&1 || true
fi

exit 0
