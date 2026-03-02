#!/usr/bin/env bash
# PreToolUse hook: warns about unarchived OpenSpec changes before git commit/push.
# Reads the Bash tool input from stdin as JSON.

input=$(cat)
if echo "$input" | grep -qE '"git (commit|push)'; then
  bash .claude/hooks/check-openspec-archived.sh
fi
