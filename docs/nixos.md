# NixOS setup

Install NixOS for Dell Wyse 5070 (x86_64)

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

## Install step (nixos-minimal-25)

- Prepare wifi
- Partition GPT (ESP(512MB), boot (512MB), /, /home)
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
wpa_passphrase <SSID> > | sudo tee >/etc/wpa_supplicant.conf
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
(parted) mkpart boot ext4 512MiB 1GiB
(parted) mkpart / ext4 1GiB 100GiB
(parted) mkpart home ext4 100GiB -1MiB
(parted) print
(parted) quit
```

Format and LUKS

```bash
# Root
sudo cryptsetup luksFormat /dev/sda3
# YES not yes not Yes
sudo ryptsetup open /dev/sda3 cryptroot

# Home
sudo cryptsetup luksFormat /dev/sda4
sudo cryptsetup open /dev/sda4 crypthome
```

```bash
sudo mkfs.ext4 /dev/mapper/cryptroot -L /
sudo mkfs.ext4 /dev/mapper/crypthome -L home
sudo mkfs.ext4 /dev/sda2 -L boot  # plese not encrypt boot

# Mount
sudo mount /dev/mapper/cryptroot /mnt
sudo mkdir /mnt/home /mnt/boot
sudo mount /dev/mapper/crypthome /mnt/home
sudo mount /dev/sda2 /mnt/boot
```

/etc/crypttab and /etc/fstab

## Create NixOS config

```bash
sudo nixos-generate-config --root /mnt
```

Then, edit the config using `sudo -e /mnt/etc/nixos/configuration.nix`

```bash
cd /mnt
sudo nixos-install
```

after installation: Run passwd to change user password.
If internet broke/breaks, set wpa_supplicant config flags to connect to wifi.
