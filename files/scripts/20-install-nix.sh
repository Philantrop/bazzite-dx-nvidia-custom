#!/usr/bin/env bash
set -euo pipefail

# Non-interactive install with defaults.
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --no-confirm -- --no-start-daemon
