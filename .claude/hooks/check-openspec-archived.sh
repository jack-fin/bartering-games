#!/usr/bin/env bash
# Checks for unarchived OpenSpec changes.
# Exits 0 if clean, exits 2 (non-blocking warning) if unarchived changes exist.

set +e  # find/sed failures should not produce an unexpected exit code

unarchived=$(find openspec/changes -name '.openspec.yaml' ! -path '*/archive/*' 2>/dev/null) || unarchived=""

# DEBUG: uncomment to log findings to /tmp for troubleshooting
# echo "unarchived=${unarchived}" >> /tmp/claude-hook-openspec-archived-debug.txt

if [ -n "${unarchived}" ]; then
  echo "Unarchived OpenSpec changes detected:"
  echo "${unarchived}" | sed 's|openspec/changes/||' | sed 's|/.openspec.yaml||' | \
    while read -r change; do
      echo "  - $change"
    done
  echo "Run /opsx:archive when implementation is complete."
  exit 2
fi
