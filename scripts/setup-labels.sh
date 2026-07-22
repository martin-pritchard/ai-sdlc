#!/usr/bin/env bash
# One-time per repo: create the SDLC labels. Idempotent - existing labels are
# updated, not duplicated. Requires `gh` authenticated against the repo.
set -euo pipefail

gh label create "backlog"             --color "ededed" --description "Captured, untriaged" --force
gh label create "needs-shaping"       --color "d4c5f9" --description "Not implementable yet - run /shape" --force
gh label create "needs-design"        --color "bfdadc" --description "New/changed layout awaiting a Claude Design turn" --force
gh label create "lane:just-ship"      --color "0e8a16" --description "No ceremony: build straight from the issue" --force
gh label create "lane:think-a-little" --color "fbca04" --description "Crosses a seam: spec first, human skims" --force
gh label create "lane:think-hard"     --color "d93f0b" --description "Expensive to undo: interview, spec, plan, approval" --force

echo "Labels ready."
