# NixOS setup

Install NixOS for **Dell Wyse 5070 (x86_64)**

- First, Just install NixOS via USB same with another distribution
- After that, we will config via `/etc/nixos`
  - `configuration.nix` for packages/services
  - `hardware-configuration.nix` for hardware

We will not try to manage booting or disk partition ([disko](https://github.com/nix-community/disko)), just install NixOS same Ubuntu.
Ref: https://tech.aufomm.com/my-nixos-journey-intro-and-installation/

## Prepare step

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

Boot Settings (F10 or Del)

- Ensure Safe Boot is Disabled.
- Ensure Fast Boot is Disabled.
- Ensure UEFI Mode is Enabled.
- Ensure Boot from USB is Enabled.

Boot security:

- Admin Password
- System Password
- Internal HDD-0 Password

## Install step (NixOS minial 25.05)

- Prepare wifi
- Partition GPT (ESP - boot (512MB), / (64GB), /home (remaining space))
  - M$ recommends 100 MB for its operating systems
  - The author of `gdisk` suggests 550 MiB.
  - As per the Arch Linux wiki, to avoid potential problems with some EFIs, ESP size should be at least 512 MiB. 550 MiB is recommended to avoid MiB/MB confusion and accidentally creating FAT16.
- Format partitions, luks and mount

```bash
sudo systemctl start wpa_supplicant.service
sudo systemctl status wpa_supplicant.service
```

Generate Wifi access config

```bash
wpa_passphrase <SSID> > | sudo tee /etc/wpa_supplicant.conf
sudo systemctl restart wpa_supplicant.service
```

Partition disk (create GPT partitioning schema and labling partition) (encrypt full disk)

```bash
sudo parted /dev/sda
```

GNU Parted:

Create a new GPT partition table (setup disk to use GPT partitioning scheme, which is necessary for UEFI systems.)

```bash
(parted) mklabel gpt
# create the EFI system partition (ESP) (1MiB to 1Gib) formatted as FAT32 for the EFI system. It’s required for UEFI booting
(parted) mkpart ESP fat32 1MiB 512MiB
(parted) set 1 esp on
```

Create boot, / and home for remaining space

```bash
# mkpart PART-TYPE [FS-TYPE] START END
# part-type is one of 'primary', 'extended' or 'logical'
(parted) mkpart / ext4 1GiB 64GiB
(parted) mkpart home ext4 100GiB -1MiB
(parted) print
(parted) quit
```

Format and LUKS

```bash
# root/home
sudo cryptsetup luksFormat /dev/sda2
sudo cryptsetup luksFormat /dev/sda3
# YES not yes not Yes

# decrypt before mount
sudo cryptsetup open /dev/sda2 cryptroot
sudo cryptsetup open /dev/sda3 crypthome
```

```bash
sudo mkfs.ext4 /dev/mapper/cryptroot -L /
sudo mkfs.ext4 /dev/mapper/crypthome -L home
sudo mkfs.fat -F 32 /dev/sda1 -n boot

# Mount
sudo mount /dev/mapper/cryptroot /mnt
sudo mkdir /mnt/home /mnt/boot
sudo mount /dev/mapper/crypthome /mnt/home
sudo mount /dev/sda2 /mnt/boot
```

## Create NixOS config

```bash
sudo nixos-generate-config --root /mnt
```

Then, edit the config using `sudo vim /mnt/etc/nixos/configuration.nix`

```bash
cd /mnt
sudo nixos-install
```

After installation: Run passwd to change user password. If internet broke/breaks, set `wpa_supplicant` config flags to connect to wifi.

## chroot for disk with luks

Decrypt / and home first

```bash
sudo cryptsetup open /dev/sda2 cryptroot
sudo cryptsetup open /dev/sda3 crypthome

sudo mount /dev/mapper/cryptroot /mnt
sudo mkdir /mnt/home /mnt/boot
sudo mount /dev/mapper/crypthome /mnt/home
sudo mount /dev/sda2 /mnt/boot
```

chroot

```bash
sudo nixos-enter
passwd ...
```

## Login and update

I want to use Tailscale, so I need to enable tailscale service and install `tailscale` cli to login

```bash
# /etc/nixos/configuration.nix
services.tailscale.enable = true;
environment.systemPackages = with pkgs; [ tailscale ];
```

Run `sudo nixos-rebuild switch` to apply new config and check tailscale service `systemctl status tailscaled.service`

## Tailscale

Create a link to login Tailscale from CLI

```bash
sudo tailscale login
```

Using another device (PC or Phone) to open the URL output and login
