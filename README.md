# bazzite-dx-nvidia-custom (Philantrop)

This is a custom-built Universal Blue / Bazzite DX NVIDIA image, tailored for a personalized setup with extended tooling and configurations.

**Disclaimer:** This image is a personal experiment and might break. Use with caution.

## Base Image
Built upon `ghcr.io/ublue-os/bazzite-dx-nvidia:stable`.

## Key Features & Additions:

*   **KDE Discover Integrations:** Enhanced Discover experience with support for Flatpak, KNS, offline updates, packagekit,rpm-ostree, and snap.
*   **Containerization Tools:** Includes Podman and `podman-compose` for container management.
*   **Nix Integration:** Nix package manager and daemon installed, with the Nix store bind-mounted from `/var/nix` to `/nix` for atomic and immutable-friendly package management.
*   **Snap Support:** Full integration for Snap packages.
*   **SELinux Policies:** Custom SELinux policies included to support `run0` operations and mitigate potential denials.
*   **System Utilities:** Essential tools like `curl`, `git`, `xz`, `bzip2`, `gzip`, `tar`, `openssl`, `shadow-utils`, and `python3-pyqt6` are pre-installed.
*   **Signing:** Images are signed for supply chain security.

## Known Changes & Behavior:

*   **`ujust` Update Logic:** The `--keep` flag has been dropped from `ujust update` calls.

## Tag Policy
Operationally supported tag: **`:stable`**  
Always rebase to `:stable`. (or better: don't use this!)

## Build & Publishing

*   **GitHub Actions:** Primary build pipeline for GHCR publication.
*   **Forgejo Actions:** Backup build pipeline, publishing to `forgejo.mailstation.de`.


---

*Note: This README is partially auto-generated and may be updated based on repository analysis.*
