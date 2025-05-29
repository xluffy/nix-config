# NixOS setup

Install NixOS for Dell Wyse 5070 (x86_64)

- First, Just install NixOS via USB same with another distribution
- After that, we will config via `/etc/nixos`
  - `configuration.nix` for packages/services
  - `hardware-configuration.nix` for hardware

We will not try to manage booting or disk partition ([disko](https://github.com/nix-community/disko)), just install NixOS same Ubuntu.

Ref: https://tech.aufomm.com/my-nixos-journey-intro-and-installation/
