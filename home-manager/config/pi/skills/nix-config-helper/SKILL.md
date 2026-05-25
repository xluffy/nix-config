---
name: nix-config-helper
description: Maintain and update the xluffy/nix-config repository structure, modules, justfile tasks, and secrets.
---

# Nix Config Helper

This skill is specialized for managing and developing the `xluffy/nix-config` repository.

## Repository Structure

- `home-manager/`: Core Home Manager configurations.
  - `home.nix`: Main home-manager configuration entry point.
  - `modules/`: Feature-specific modules (core, programs, shell).
  - `config/`: Raw config files (git, ssh, tmux, iterm2, pi-agent).
- `hosts/`: Host-specific configurations.
- `secrets/`: Encrypted secrets (using age).
- `flake.nix`: Flake entry point defining inputs and system outputs.
- `justfile`: Contains recipes for common commands.

## Common Operations using the Justfile

Always prefer using the `justfile` for typical tasks:

- **Switch Configuration**: Apply changes using the defined user/host attribute:
  ```bash
  just switch
  ```
- **Check Style/Formatting**: Validate Nix style and formatting before switching:
  ```bash
  just check
  ```
- **Format and Fix**: Format all Nix files, edit dead code, and fix statix warnings:
  ```bash
  just fix
  ```
- **Update Dependencies**: Update unstable nixpkgs channel:
  ```bash
  just update
  ```
- **Garbage Collection (Dry Run)**:
  ```bash
  just gc-dry-run
  ```
- **Garbage Collection (Execution)**: Clean up older profiles (older than 2 days):
  ```bash
  just gc
  ```
