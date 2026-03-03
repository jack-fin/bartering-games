#!/usr/bin/env bash
# UserPromptSubmit hook: warns when /opsx:propose is invoked while not on main.
# /opsx:propose starts brand-new feature work, which should branch from main.
#
# Reads the UserPromptSubmit JSON payload from stdin.
# Always exits 0 — for UserPromptSubmit, stdout is injected as context (non-blocking).
# Non-zero exit would block the prompt entirely, which is not the intent here.

set +e  # Never let any subcommand failure propagate to an unexpected exit code

# Use Python to parse the JSON payload — more robust than piping through cat+echo+grep,
# and avoids hangs if Claude Code is slow to close the stdin pipe.
prompt=$(python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('prompt', ''))
except Exception:
    pass
" 2>/dev/null) || prompt=""

# DEBUG: uncomment to log the raw prompt to /tmp for troubleshooting
# echo "prompt=${prompt}" >> /tmp/claude-hook-opsx-propose-debug.txt

# Only act on /opsx:propose invocations
if ! echo "${prompt}" | grep -qE '(opsx:propose|openspec-propose)'; then
  exit 0
fi

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || branch=""

if [ "${branch}" = "main" ] || [ -z "${branch}" ]; then
  exit 0
fi

# Extract Shortcut story ID from the prompt if a URL was provided
# Matches: https://app.shortcut.com/*/story/51/...  or  sc-51
story_id=$(echo "${prompt}" | grep -oE 'story/([0-9]+)' | grep -oE '[0-9]+' | head -1) || story_id=""
if [ -z "${story_id}" ]; then
  story_id=$(echo "${prompt}" | grep -oE '\bsc-([0-9]+)\b' | grep -oE '[0-9]+' | head -1) || story_id=""
fi

echo "HOOK WARNING: /opsx:propose starts new feature work, but current branch is '${branch}' (not main)."
echo ""
echo "Before doing anything else:"
if [ -n "${story_id}" ]; then
  echo "  1. Call the stories-get-branch-name MCP tool with storyPublicId=${story_id} to get the"
  echo "     exact branch name. Do NOT construct or guess the branch name yourself."
else
  echo "  1. Call the stories-get-branch-name MCP tool to get the exact branch name."
  echo "     Do NOT construct or guess the branch name yourself."
fi
echo "  2. Confirm with the user before switching branches, showing the exact branch name"
echo "     returned by the tool."
echo "  3. If confirmed:"
echo "     git checkout main && git pull --ff-only origin main"
echo "     git checkout -b <exact-name-from-tool>"
echo "  4. Then proceed with the proposal."

exit 0
