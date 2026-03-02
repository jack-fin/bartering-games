#!/usr/bin/env bash
# UserPromptSubmit hook: warns when /opsx:propose is invoked while not on main.
# /opsx:propose starts brand-new feature work, which should branch from main.
#
# Reads the UserPromptSubmit JSON payload from stdin.
# Always exits 0 — for UserPromptSubmit, stdout is injected as context (non-blocking).
# Non-zero exit would block the prompt entirely, which is not the intent here.

input=$(cat)

# Only act on /opsx:propose invocations
if ! echo "$input" | grep -qE '(opsx:propose|openspec-propose)'; then
  exit 0
fi

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

if [ "$branch" = "main" ]; then
  exit 0
fi

# Extract Shortcut story ID from the prompt if a URL was provided
# Matches: https://app.shortcut.com/*/story/51/...  or  sc-51
story_id=$(echo "$input" | grep -oE 'story/([0-9]+)' | grep -oE '[0-9]+' | head -1)
if [ -z "$story_id" ]; then
  story_id=$(echo "$input" | grep -oE '\bsc-([0-9]+)\b' | grep -oE '[0-9]+' | head -1)
fi

echo "HOOK WARNING: /opsx:propose starts new feature work, but current branch is '$branch' (not main)."
echo ""
echo "It is recommended to:"
echo "  1. Ensure main is up to date:"
echo "     git fetch origin main"
echo "     git checkout main && git pull --ff-only origin main"
if [ -n "$story_id" ]; then
  echo "  2. Get the Shortcut branch name: call stories-get-branch-name with storyPublicId=$story_id"
  echo "  3. Create the feature branch from updated main using that branch name"
  echo "     git checkout -b <branch-name>"
  echo "  4. Then proceed with the proposal."
else
  echo "  2. Get the correct branch name from the Shortcut story (stories-get-branch-name)"
  echo "  3. Create the feature branch from updated main"
  echo "  4. Then proceed with the proposal."
fi
echo ""
echo "Confirm with the user before switching branches."

exit 0
