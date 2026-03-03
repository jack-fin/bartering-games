#!/usr/bin/env bash
# PreToolUse hook: runs checks before git commit, git push, or gh pr create.
# Reads the Bash tool input from stdin as JSON.

set +e  # Never let subcommand failures cause an unexpected non-zero exit;
        # intentional failures are managed explicitly via $rc below.

# Use Python to extract the Bash command field from the PreToolUse JSON payload —
# more robust than piping through cat+echo+grep on the raw JSON blob.
cmd=$(python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('tool_input', {}).get('command', ''))
except Exception:
    pass
" 2>/dev/null) || cmd=""

# DEBUG: uncomment to log the extracted command to /tmp for troubleshooting
# echo "cmd=${cmd}" >> /tmp/claude-hook-pre-commit-debug.txt

if echo "${cmd}" | grep -qE '^(git commit|git push|gh pr create|gh pr edit)'; then
  rc=0
  bash .claude/hooks/check-shortcut-branch.sh >&2 || rc=1
  bash .claude/hooks/check-openspec-archived.sh >&2 || rc=1
  exit $rc
fi
