#!/usr/bin/env bash
set -euo pipefail

mkdir -p /nix
mkdir -p /nix/store
mkdir -p /nix/var/nix/daemon-socket

chown -R root:root /nix
chmod 0755 /nix
chmod 0755 /nix/store
chmod 0755 /nix/var /nix/var/nix /nix/var/nix/daemon-socket


# Create /var/nix at boot via a oneshot service (avoid tmpfiles ordering cycles)
install -D -m 0644 /dev/stdin /usr/lib/systemd/system/nix-var-nix.service <<'EOF'
[Unit]
Description=Create /var/nix for Nix store bind mount

[Service]
Type=oneshot
ExecStart=/usr/bin/mkdir -p /var/nix
ExecStart=/usr/bin/chmod 0755 /var/nix
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Bind mount /var/nix -> /nix, ordered only relative to nix-var-nix.service and local-fs
install -D -m 0644 /dev/stdin /usr/lib/systemd/system/nix.mount <<'EOF'
[Unit]
Description=Mount /nix for Nix store (late, avoids local-fs ordering cycles)
DefaultDependencies=no
After=basic.target nix-var-nix.service
Requires=nix-var-nix.service
Before=multi-user.target nix-daemon.service
Conflicts=umount.target

[Mount]
What=/var/nix
Where=/nix
Type=none
Options=bind

[Install]
WantedBy=multi-user.target
EOF

# Ensure nix-daemon waits for nix.mount (unit name may differ; see note below)
mkdir -p /usr/lib/systemd/system/nix-daemon.service.d
install -D -m 0644 /dev/stdin /usr/lib/systemd/system/nix-daemon.service.d/10-nix-store.conf <<'EOF'
[Unit]
Requires=nix.mount
After=nix.mount
EOF

# Enable by default
install -D -m 0644 /dev/stdin /usr/lib/systemd/system-preset/90-nix.preset <<'EOF'
enable nix-var-nix.service
enable nix.mount
enable nix-daemon.service
EOF

# Nix config (see next section)
install -D -m 0644 /dev/stdin /etc/nix/nix.conf <<'EOF'
experimental-features = nix-command flakes
EOF
