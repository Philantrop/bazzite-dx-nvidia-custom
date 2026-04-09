#!/usr/bin/env bash
set -euo pipefail

# Restore upstream default (Terra disabled) after build-time installs.

if [[ -f /etc/yum.repos.d/terra.repo ]]; then
  sed -i 's/^enabled=1$/enabled=0/' /etc/yum.repos.d/terra.repo
fi
