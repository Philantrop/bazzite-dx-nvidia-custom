#!/usr/bin/env bash
set -euo pipefail

# Workaround for SELinux denying `{ entrypoint }` when executing certain admin tools
# via `run0`/systemd transient units on ostree/overlay-based systems.
#
# These modules were generated from real AVCs using audit2allow and are meant to
# restore expected `run0 <tool>` behaviour without disabling SELinux.

mods_dir=/usr/share/selinux/run0-modules

# In BlueBuild/ostree images, repository `files/` often lands at `/` in the image.
# Support both layouts:
# - baked location: /usr/share/selinux/run0-modules
# - source location: /selinux/run0-modules
if [[ ! -d "$mods_dir" && -d /selinux/run0-modules ]]; then
  install -d -m 0755 "$mods_dir"
  cp -a /selinux/run0-modules/*.pp "$mods_dir"/ || true
fi

if [[ ! -d "$mods_dir" ]]; then
  echo "run0 SELinux modules dir not found (checked $mods_dir and /selinux/run0-modules); skipping" >&2
  exit 0
fi

shopt -s nullglob
pps=("$mods_dir"/*.pp)

if (( ${#pps[@]} == 0 )); then
  echo "No .pp files found in $mods_dir (skipping)" >&2
  exit 0
fi

for pp in "${pps[@]}"; do
  echo "Installing SELinux module: $(basename "$pp")"
  semodule -X 300 -i "$pp"
done
