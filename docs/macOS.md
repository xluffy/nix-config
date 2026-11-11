---
title: "macOS Setup Guide"
date: 2026-11-11
tags:
  - macos
  - bootstrap
  - home-manager
  - nix
---

# macOS Setup Guide

This document has two parts:

1. **CLI setup**: Install Nix and apply the Home Manager configuration.
2. **GUI setup**: Set the macOS settings that the CLI cannot set.

---

## Part 1: CLI Setup

Do the steps in sequence. Use the default macOS Terminal app.

### 1. Make sure that the user name is correct

Each host in `flake.nix` has a fixed user name. The macOS account short name must be the same.

|Machine|`HM_FLAKE_ATTR`|macOS user name|
|---|---|---|
|MacBook Pro|`quang.van.nguyen@Nguyens-MacBook-Pro.local`|`quang.van.nguyen`|
|Mac mini|`quangne@Quangs-Mac-mini`|`quangne`|

Run this command and compare the result with the table:

```bash
whoami
```

For a new machine, add a new entry to `homeConfigurations` in `flake.nix`. Then run `git add flake.nix`.

### 2. Install the Xcode Command Line Tools

The tools supply `git`.

```bash
xcode-select --install
```

Wait until the installer finishes.

### 3. Install Nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Close the terminal. Open a new terminal.

### 4. Clone the repository

Use HTTPS. SSH does not work before step 10.

```bash
mkdir -p ~/code/me
git clone https://github.com/xluffy/nix-config.git ~/code/me/nix-config
cd ~/code/me/nix-config
```

### 5. Enable flakes

Some Nix installers do not enable flakes. This step enables flakes for all installers.

```bash
mkdir -p ~/.config/nix
cp nix.conf ~/.config/nix/nix.conf
nix config show experimental-features
```

The last command must show `flakes` and `nix-command`.

### 6. Set the host

Write the value from the table in step 1 to `.envrc.local`. Git ignores this file.

MacBook Pro:

```bash
echo 'export HM_FLAKE_ATTR=quang.van.nguyen@Nguyens-MacBook-Pro.local' > .envrc.local
```

Mac mini:

```bash
echo 'export HM_FLAKE_ATTR=quangne@Quangs-Mac-mini' > .envrc.local
```

### 7. Apply the Home Manager configuration

1. Start the dev shell. The dev shell supplies `home-manager` and `just`.

   ```bash
   nix develop
   ```

2. Load the host value. The dev shell does not load `.envrc.local`.

   ```bash
   source .envrc.local
   echo "$HM_FLAKE_ATTR"
   ```

   The output must not be empty.

3. Apply the configuration. The `-b backup` option renames each existing file to `<name>.backup`. Without it, the first run stops when a file such as `~/.bashrc` exists.

   ```bash
   home-manager switch -b backup --flake ".#${HM_FLAKE_ATTR}"
   ```

4. Exit the dev shell.

   ```bash
   exit
   ```

### 8. Set Bash from Nix as the login shell

The configuration uses Bash. The default macOS shell is zsh.

```bash
echo "$HOME/.nix-profile/bin/bash" | sudo tee -a /etc/shells
chsh -s "$HOME/.nix-profile/bin/bash"
```

Close the terminal. Open a new terminal.

### 9. Allow direnv in the repository

```bash
cd ~/code/me/nix-config
direnv allow
```

direnv now loads the dev shell and `.envrc.local` each time that you open the directory.

### 10. Set up SSH and Git signing with 1Password

On macOS, SSH and Git use the 1Password SSH agent. Home Manager installs 1Password.

1. Open 1Password and sign in.
2. Go to **Settings > Developer**. Turn on **Use the SSH agent**.
3. Write the public key to the path that `ssh.nix` uses:

   ```bash
   echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII6gzw6c40c8zowzZ6nR8iRwsYy0qg2sNvro09nFtTzF quang@2meo.com" > ~/.ssh/ssh-ed25519:quang@2meo.com.pub
   ```

4. Test the connection to GitHub:

   ```bash
   ssh -T git@github.com
   ```

5. Change the remote of the repository to SSH:

   ```bash
   git -C ~/code/me/nix-config remote set-url origin git@github.com:xluffy/nix-config.git
   ```

### 11. Apply the macOS defaults

```bash
bash ~/code/me/nix-config/bin/bootstrap.sh
```

The script sets the Finder, screenshot, and key repeat settings.

### 12. Apply changes later

```bash
cd ~/code/me/nix-config
git pull
just switch
```

---

## Part 2: macOS System Preferences Setup (Manual GUI Steps)

The following manual System Preferences settings must be configured through the GUI as they are not automatable:

### Appearance
- Auto mode
- Sidebar icon size -> "Medium"
- Show Scroll Bars -> "When scrolling"

### Dock
- Remove most applications from Dock
- Automatic Hide -> Enabled
- Smaller Dock size
- "Show recent applications in Dock" -> Off
- "Show indicators for open applications" -> On
- Battery -> "Show Percentage"

### Security & Hardware
- Touch ID -> Configured
- Trackpad -> Tap to Click -> Enabled
- Trackpad -> Point & Click -> Look up & data detectors -> Off
- Trackpad -> More Gestures -> Notification Centre -> Off

### Keyboard & Input
- Key repeat rate -> Fast
- Delay until repeat -> Short
- Text Input:
  - Disable "Capitalise word automatically"
  - Disable "Add full stop with double-space"
  - Disable "Use smart quotes and dashes"
  - Use `"` for double quotes
  - Use `'` for single quotes
- Keyboard -> Mission Control -> Disable all, except:
  - Mission Control
  - Application windows
  - Move left a space -> Disable
  - Move right a space -> Disable
- Press FN to -> "Do Nothing"
- Keyboard Shortcuts -> Spotlight -> Disable `CMD + Space` (we will use Raycast instead)
- Input Sources -> Disable all except English layout

### Mission Control
- Hot Corners -> Disable all

### Finder
- General:
  - New Finder windows show -> `[Downloads]`
  - Show these items on the desktop -> Disable all
- Sidebar:
  - Activate all Favorites (except Recents, Movies, Music)
  - Disable all Locations (except iCloud Drive)
  - Move Library to Favorites
- Tags -> Disable all
- Advanced:
  - Show all Filename Extensions -> Enabled
  - Remove Items from Bin after 30 Days -> Enabled
  - View -> Show Preview (e.g. image files) -> Enabled

### Security and Privacy
- Turn on FileVault
- Add your browser to "Screen Recording" permissions

### Storage
- Remove Garage Band & Sound Library
- Remove iMovie
