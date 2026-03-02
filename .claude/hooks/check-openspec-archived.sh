#!/usr/bin/env bash
# Checks for unarchived OpenSpec changes.
# Exits 0 if clean, exits 2 (non-blocking warning) if unarchived changes exist.

unarchived=$(find openspec/changes -name '.openspec.yaml' ! -path '*/archive/*' 2>/dev/null)

if [ -n "$unarchived" ]; then
  echo "Unarchived OpenSpec changes detected:"
  echo "$unarchived" | sed 's|openspec/changes/||' | sed 's|/.openspec.yaml||' | \
    while read -r change; do
      echo "  - $change"
    done
  echo "Run /opsx:archive when implementation is complete."
  exit 2
fi
