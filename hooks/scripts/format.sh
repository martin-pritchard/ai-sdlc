#!/usr/bin/env bash
# PostToolUse hook: deterministic formatting after every write or edit.
#
# The plugin provides the trigger; the project provides the formatter. /setup
# scaffolds an executable `.claude/format.sh` for the repo's stack. Without
# one, this passes silently. Nothing about formatting or naming should ever
# appear in CLAUDE.md - the project script is the enforcement mechanism.
#
# The changed file's path is passed to the project script as $1 so it can
# format just that file - repo-wide formatting on every edit does not scale.
#
# Also drops the sentinel the Stop hook checks, so verification only runs on
# turns that actually wrote something.
set -uo pipefail

input=$(cat)

file=$(printf '%s' "$input" \
  | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
  | head -1)

touch "${TMPDIR:-/tmp}/claude-sdlc-needs-verify-$(pwd | cksum | cut -d' ' -f1)"

if [ -x ".claude/format.sh" ]; then
  ./.claude/format.sh "$file" >/dev/null 2>&1 || true
fi

exit 0
