#!/usr/bin/env bash
set -euo pipefail

MARKETPLACE=".claude-plugin/marketplace.json"

# Must be on main and up to date
branch=$(git rev-parse --abbrev-ref HEAD)
if [[ "$branch" != "main" ]]; then
  echo "error: must be on main (currently on $branch)" >&2
  exit 1
fi

git fetch origin main --quiet
if ! git merge-base --is-ancestor origin/main HEAD 2>/dev/null || \
   ! git merge-base --is-ancestor HEAD origin/main 2>/dev/null; then
  echo "error: local main is not in sync with origin/main — pull or push first" >&2
  exit 1
fi

sha=$(git rev-parse HEAD)
short=${sha:0:7}

# Update SHA in marketplace.json
tmp=$(mktemp)
jq --arg sha "$sha" '.plugins[0].source.sha = $sha' "$MARKETPLACE" > "$tmp"
mv "$tmp" "$MARKETPLACE"

git add "$MARKETPLACE"
git commit -m "release: bump sha to $short"
git push origin main

echo "released $short"
