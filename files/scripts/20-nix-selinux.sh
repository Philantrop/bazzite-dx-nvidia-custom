#!/usr/bin/env bash
set -euo pipefail

# Persistently label Nix paths so confined services (notably PID 1 / systemd) can
# read unit files and other resources living in /nix/store.
#
# Without this, /nix is typically labelled var_t on Fedora-family systems,
# leading to AVCs like:
#   init_t denied { read } ... tcontext=var_t
#
# We store local file-context rules in file_contexts.local (equivalent to
# `semanage fcontext -a ...`) and run restorecon at boot once /nix is mounted.

install -D -m 0644 /dev/stdin /etc/selinux/targeted/contexts/files/file_contexts.local <<'EOF'
/nix/store(/.*)?    system_u:object_r:usr_t:s0
/nix/var/nix(/.*)?  system_u:object_r:usr_t:s0
EOF

# Apply the contexts at boot (after the /var/nix -> /nix bind mount is active).
install -D -m 0644 /dev/stdin /usr/lib/systemd/system/nix-selinux-label.service <<'EOF'
[Unit]
Description=Apply SELinux contexts for Nix (/nix)
After=nix.mount
Requires=nix.mount
Before=nix-daemon.service
ConditionPathIsDirectory=/nix/store

[Service]
Type=oneshot
ExecStart=/usr/sbin/restorecon -RF /nix/store /nix/var/nix

[Install]
WantedBy=multi-user.target
EOF

# Enable by default
install -D -m 0644 /dev/stdin /usr/lib/systemd/system-preset/91-nix-selinux.preset <<'EOF'
enable nix-selinux-label.service
EOF
