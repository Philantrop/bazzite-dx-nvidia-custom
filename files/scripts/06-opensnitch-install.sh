#!/usr/bin/env bash
set -euo pipefail

latest_version="$(curl -fsSL \
  -H 'Accept: application/vnd.github+json' \
  https://api.github.com/repos/evilsocket/opensnitch/releases/latest \
  | sed -n 's/^[[:space:]]*"tag_name": "\(v[0-9][0-9.]*\)".*/\1/p' \
  | head -n1)"

if [[ -z "$latest_version" ]]; then
  echo "ERROR: Could not determine the latest OpenSnitch release." >&2
  exit 1
fi

version="${latest_version#v}"
echo "Installing latest stable OpenSnitch release: $latest_version"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

curl -fL \
  -o "$tmpdir/opensnitch.rpm" \
  "https://github.com/evilsocket/opensnitch/releases/download/v${version}/opensnitch-${version}-1.x86_64.rpm"

curl -fL \
  -o "$tmpdir/opensnitch-ui.rpm" \
  "https://github.com/evilsocket/opensnitch/releases/download/v${version}/opensnitch-ui-${version}-1.noarch.rpm"

dnf install -y \
  "$tmpdir/opensnitch.rpm" \
  "$tmpdir/opensnitch-ui.rpm"

systemctl enable opensnitch.service
