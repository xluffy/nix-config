# NixOS setup

Install NixOS for Dell Wyse 5070 (x86_64)

- First, Just install NixOS via USB same with another distribution
- After that, we will config via `/etc/nixos`
  - `configuration.nix` for packages/services
  - `hardware-configuration.nix` for hardware

We will not try to manage booting or disk partition ([disko](https://github.com/nix-community/disko)), just install NixOS same Ubuntu.

Ref: https://tech.aufomm.com/my-nixos-journey-intro-and-installation/

## Step

Download

```bash
> wget https://releases.nixos.org/nixos/25.05/nixos-25.05.802674.7848cd8c982f/nixos-minimal-25.05.802674.7848cd8c982f-x86_64-linux.iso
> wget https://releases.nixos.org/nixos/25.05/nixos-25.05.802674.7848cd8c982f/nixos-minimal-25.05.802674.7848cd8c982f-x86_64-linux.iso.sha256

> sha256sum -c nixos-minimal-25.05.802674.7848cd8c982f-x86_64-linux.iso.sha256
nixos-minimal-25.05.802674.7848cd8c982f-x86_64-linux.iso: OK
```

Create a Bootable USB

```bash
> lsblk
> sudo dd if=nixos-minimal-25.05.802674.7848cd8c982f-x86_64-linux.iso of=/dev/sdb bs=1M status=progress
```
