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
  --setopt=tsflags=noscripts \
  "$tmpdir/opensnitch.rpm" \
  "$tmpdir/opensnitch-ui.rpm"

# The RPM's %post script calls systemctl, but image builds do not run systemd.
# Recreate the enablement and UI autostart links without contacting systemd.
install -d /etc/systemd/system/multi-user.target.wants
ln -sfn /usr/lib/systemd/system/opensnitch.service \
  /etc/systemd/system/multi-user.target.wants/opensnitch.service

if [[ -d /etc/xdg/autostart ]]; then
  ln -sfn /usr/share/applications/opensnitch_ui.desktop \
    /etc/xdg/autostart/opensnitch_ui.desktop
fi

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache /usr/share/icons/hicolor/ || true
fi
