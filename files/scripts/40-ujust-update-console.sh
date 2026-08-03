#!/usr/bin/env bash
set -euo pipefail

f=/usr/share/ublue-os/just/10-update.just

if [[ ! -f "$f" ]]; then
  echo "Expected $f to exist, but it does not" >&2
  exit 1
fi

# Use uupd's interactive console output for manual updates instead of
# routing through bazzite-updater and the JSON-only systemd service.
sed -Ei 's#^[[:space:]]*bazzite-updater --update[[:space:]]*$#    /usr/bin/run0 /usr/bin/uupd --log-level=info#' "$f"

if ! grep -q -- '/usr/bin/run0 /usr/bin/uupd --log-level=info' "$f"; then
  echo "Failed to replace the upstream update command in $f" >&2
  grep -n -- 'bazzite-updater\|uupd' "$f" >&2 || true
  exit 1
fi
