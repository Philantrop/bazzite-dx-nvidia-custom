# bazzite-dx-nvidia-custom (Philantrop)

Just a personal experiment. Might break horribly. Stay away.

Custom **signed** Universal Blue / Bazzite DX NVIDIA image:

- Base: `ghcr.io/ublue-os/bazzite-dx-nvidia:stable`
- Adds: KDE Discover integrations, snap support, both podman compose variants, Nix daemon
- Nix store: `/nix` bind-mounted from `/var/nix` (atomic/immutable-friendly)

## Tag policy
Operationally supported tag: **`:stable`**  
Always rebase to `:stable`. (or better: don't use this!)
