#!/usr/bin/env bash
set -euo pipefail

dnf clean all || true
rm -rf /var/cache/dnf || true
