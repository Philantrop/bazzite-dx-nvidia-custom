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
  python3-inotify \
  python3-notify2 \
  python3-pyasn \
  python3-slugify \
  python3-text-unidecode \
  "$tmpdir/opensnitch.rpm" \
  "$tmpdir/opensnitch-ui.rpm"

# Python dependencies used by the OpenSnitch GUI. Keep these in the image so
# the GUI does not depend on ad-hoc per-user pip installations.
python3 -m pip install --no-cache-dir --no-deps \
  pyinotify qt-material

# OpenSnitch 1.8.0 can abort while positioning a rule popup under native
# Wayland/Qt. Run the GUI through XWayland and use the session's X authority.
install -D -m 0755 /dev/stdin /usr/local/bin/opensnitch-ui-xcb <<'EOF'
#!/bin/sh
set -eu

for auth in "/run/user/$(id -u)"/xauth_*; do
    if [ -r "$auth" ]; then
        export XAUTHORITY="$auth"
        break
    fi
done

export QT_QPA_PLATFORM=xcb
exec /usr/bin/opensnitch-ui "$@"
EOF
sed -Ei 's#^Exec=opensnitch-ui$#Exec=/usr/local/bin/opensnitch-ui-xcb#' \
  /usr/share/applications/opensnitch_ui.desktop

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
