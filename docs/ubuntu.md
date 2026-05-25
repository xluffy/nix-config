# Ubuntu Server 24.04 Setup & Bootstrapping Guide (A-to-Z)

This guide walks you through bootstrapping a fresh, headless Ubuntu 24.04 Server installation to use this Nix Home Manager configuration.

---

## Phase 1: Prerequisites & Nix Installation

### 1. Update Ubuntu Server

Make sure your package list is up-to-date and apply any upgrades:

```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Install Git, Curl, and Build Tools

Nix and our configurations require git and curl to fetch dependencies:

```bash
sudo apt install curl git build-essential -y
```

### 3. Install Nix (Multi-User mode)

Install Nix using the official recommended multi-user installer. This is completely sandbox-safe and isolates your Nix configuration:

```bash
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

### 4. Enable Experimental Flakes Support

Flakes are required to run this configuration. Enable them in your user/system Nix settings:

```bash
mkdir -p ~/.config/nix
echo "extra-experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

---

## Phase 2: Repository Setup & Environment

### 1. Clone your Nix Configuration

Clone this repository to your home directory (standard setup is in `~/code/me/nix-config`):

```bash
mkdir -p ~/code/me
git clone git@github.com:xluffy/nix-config.git ~/code/me/nix-config
cd ~/code/me/nix-config
```

### 2. Set Up Direnv & Envrc

Initialize your local gitignored environment variables so `just` and `direnv` know which target profile to build:

```bash
cp .envrc.local.example .envrc.local
```
Edit `.envrc.local` and set your HM_FLAKE_ATTR to match your Ubuntu host name in `flake.nix` (e.g., `quang.van.nguyen@ubuntu` or `xluffy@ubuntu`):

```bash
vim .envrc.local
# set export HM_FLAKE_ATTR=xluffy-zzbot@elbaf-sky-n100
```

---

## Phase 3: Bootstrap & Switch

### 1. Run Nix Devshell

Start a temporary devshell equipped with `home-manager`, `just`, and other tools needed to run the first installation:

```bash
nix develop
```

### 2. Bootstrap Home Manager

From inside the nix devshell, build and activate your home-manager configuration for the first time:

```bash
just bootstrap
```

This command compiles the server profile (no GUI packages like 1Password GUI, karabiner, betterdisplay are installed, keeping the server environment lightweight and clean).

### 3. Verify Shell & Activation

Verify that home-manager activated correctly:
```bash
home-manager packages
```

---

## Phase 4: 1Password SSH Agent Setup (Headless)

Since this is a headless Ubuntu server, the SSH signing agent is configured to look for the 1Password system socket at:

`~/.1password/agent.sock`

If you are agent forwarding from your macOS host, or have 1Password CLI configured locally on the server, ensure the socket or a symlink exists:

```bash
mkdir -p ~/.1password
ln -sf $SSH_AUTH_SOCK ~/.1password/agent.sock
```
This ensures seamless SSH agent and Git signing integration!
