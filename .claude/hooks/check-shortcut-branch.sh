#!/usr/bin/env bash
# Checks that the current branch follows the Shortcut naming convention.
# Pattern: {mention_name}/sc-{story_id}/{description}
# Exits 0 if on main or branch matches, exits 2 (non-blocking warning) otherwise.

set +e  # git failures should not produce an unexpected exit code

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || branch=""

# DEBUG: uncomment to log the branch to /tmp for troubleshooting
# echo "branch=${branch}" >> /tmp/claude-hook-shortcut-branch-debug.txt

if [ "${branch}" = "main" ] || [ -z "${branch}" ]; then
  exit 0
fi

if echo "${branch}" | grep -qE '^[a-z0-9-]+/sc-[0-9]+/.+$'; then
  exit 0
fi

echo "Branch '${branch}' does not follow the Shortcut naming convention."
echo "Expected format: {mention_name}/sc-{story_id}/{description}"
echo ""
echo "To find the correct branch name:"
echo "  1. Check the current conversation context for any mentioned Shortcut story ID or name."
echo "  2. Check recent commits for sc-NNN references:"

story_refs=$(git log --oneline -20 2>/dev/null | grep -oE '\bsc-[0-9]+\b' | sort -u) || story_refs=""
if [ -n "${story_refs}" ]; then
  echo "     Found: ${story_refs}"
else
  echo "     None found."
  active_changes=$(find openspec/changes -maxdepth 1 -mindepth 1 -type d ! -name archive 2>/dev/null \
    | xargs -I{} basename {} | tr '\n' ' ') || active_changes=""
  if [ -n "${active_changes}" ]; then
    echo "  3. Active OpenSpec changes may hint at the story: ${active_changes}"
  fi
  echo "  3. Use stories-search MCP tool to find the associated story."
fi

echo ""
echo "Once the story is identified, use stories-get-branch-name and suggest switching to the correct branch."

exit 2
