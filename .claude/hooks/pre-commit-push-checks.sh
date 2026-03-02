#!/usr/bin/env bash
# PreToolUse hook: runs checks before git commit, git push, or gh pr create.
# Reads the Bash tool input from stdin as JSON.

input=$(cat)

if echo "$input" | grep -qE '"(git commit|git push|gh pr create|gh pr edit)'; then
  bash .claude/hooks/check-shortcut-branch.sh >&2
  bash .claude/hooks/check-openspec-archived.sh >&2
fi
