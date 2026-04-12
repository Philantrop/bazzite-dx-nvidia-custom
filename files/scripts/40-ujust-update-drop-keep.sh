#!/usr/bin/env bash
set -euo pipefail

f=/usr/share/ublue-os/just/10-update.just

if [[ ! -f "$f" ]]; then
  echo "Expected $f to exist, but it does not" >&2
  exit 1
fi

# Drop Topgrade's --keep flag from the uBlue `ujust update` recipe.
# We match the exact pinned invocation to avoid unintended edits.
sed -Ei 's#(/usr/bin/topgrade --config /usr/share/ublue-os/topgrade\.toml) --keep#\1#' "$f"

if grep -q -- ' --keep' "$f"; then
  echo "Failed to remove --keep from $f (upstream recipe likely changed)" >&2
  echo "Current /usr/bin/topgrade line(s):" >&2
  grep -n -- '/usr/bin/topgrade' "$f" >&2 || true
  exit 1
fi
