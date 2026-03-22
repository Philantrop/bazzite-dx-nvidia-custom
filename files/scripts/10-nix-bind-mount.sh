#!/usr/bin/env bash
set -euo pipefail

# Create /nix mountpoint in the image (do not rely on tmpfiles for /nix; / is immutable at runtime)
rm -rf /nix
mkdir -p /nix

# 1) tmpfiles: create /var/nix on boot
install -D -m 0644 /dev/stdin /usr/lib/tmpfiles.d/nix.conf <<'EOF'
d /var/nix 0755 root root - -
EOF

# 2) systemd mount unit: bind /var/nix -> /nix
install -D -m 0644 /dev/stdin /usr/lib/systemd/system/nix.mount <<'EOF'
[Unit]
Description=Bind mount /var/nix to /nix for Nix store on immutable systems
DefaultDependencies=no
Before=local-fs.target
After=systemd-tmpfiles-setup.service
Requires=systemd-tmpfiles-setup.service

[Mount]
What=/var/nix
Where=/nix
Type=none
Options=bind

[Install]
WantedBy=local-fs.target
EOF

# 3) Ensure nix-daemon waits for nix.mount
mkdir -p /usr/lib/systemd/system/nix-daemon.service.d
install -D -m 0644 /dev/stdin /usr/lib/systemd/system/nix-daemon.service.d/10-nix-store.conf <<'EOF'
[Unit]
Requires=nix.mount
After=nix.mount
EOF

# 4) Enable units by default via systemd preset
install -D -m 0644 /dev/stdin /usr/lib/systemd/system-preset/90-nix.preset <<'EOF'
enable nix.mount
enable nix-daemon.service
EOF

# 5) System nix.conf (flakes enabled)
install -D -m 0644 /dev/stdin /etc/nix/nix.conf <<'EOF'
experimental-features = nix-command flakes
auto-optimise-store = true
warn-dirty = false
EOF
