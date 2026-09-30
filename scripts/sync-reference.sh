#!/usr/bin/env bash
# Copy reference/api.md into every skill folder, or verify the copies with --check.
set -euo pipefail
cd "$(dirname "$0")/.."
SRC="reference/api.md"
status=0
for dir in skills/*/; do
  dest="${dir}reference.md"
  if [ "${1:-}" = "--check" ]; then
    if ! cmp -s "$SRC" "$dest"; then echo "DRIFT: $dest differs from $SRC (run scripts/sync-reference.sh)"; status=1; fi
  else
    cp "$SRC" "$dest"; echo "synced $dest"
  fi
done
exit $status
