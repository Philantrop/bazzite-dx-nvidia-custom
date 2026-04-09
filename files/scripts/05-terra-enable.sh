#!/usr/bin/env bash
set -euo pipefail

# BlueBuild's dnf module uses dnf inside the build container.
# In upstream Bazzite images, the Terra repo files exist but are disabled by default.
# Enable Terra temporarily so packages like opensnitch (from Terra) can be installed.

if [[ -f /etc/yum.repos.d/terra.repo ]]; then
  sed -i 's/^enabled=0$/enabled=1/' /etc/yum.repos.d/terra.repo
else
  echo "WARN: /etc/yum.repos.d/terra.repo not found, cannot enable Terra" >&2
fi
