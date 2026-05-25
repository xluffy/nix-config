---
name: nix-helper
description: Assist with Nix, NixOS, and Home Manager configurations, formatting, checking syntax, and managing packages.
---

# Nix Helper Skill

This skill enables the agent to effectively manage, format, and check Nix configurations.

## Guidelines

- Follow Nix best practices, using structured modules instead of monolithic files.
- Prefer formatting all Nix source code with standard formatting tools (e.g., `alejandra` or `nixfmt-rfc-style`).
- Check and clean up dead Nix code periodically using `deadnix`.
- Check Nix code quality and common anti-patterns using `statix`.

## Common Commands

- **Formatting**:
  ```bash
  alejandra .
  ```
- **Dead Code Identification**:
  ```bash
  deadnix .
  ```
- **Dead Code Automatic Removal**:
  ```bash
  deadnix --edit .
  ```
- **Linting & Code Quality**:
  ```bash
  statix check .
  ```
- **Linting Auto-Fix**:
  ```bash
  statix fix .
  ```
