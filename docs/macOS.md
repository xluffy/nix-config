# macOS Bootstrapping & Setup Guide (A-to-Z)

This document is divided into two parts:
1. **Bootstrapping Guide (CLI)**: Install Nix, Home Manager, and apply the flake configuration.
2. **System Preferences Setup (GUI)**: Manual settings that cannot be automated via CLI.

---

## Part 1: Bootstrapping Guide (CLI)

### 1. Install Nix (Recommended Multi-User)
Run the Determinate Systems Nix installer, which is sandbox-safe and comes with experimental flakes enabled by default:
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```
Follow the installer prompts and open a new terminal window after it finishes to activate the Nix environment.

### 2. Clone the Nix Configuration Repository
Clone this repository to your preferred local workspace directory (e.g., `~/code/me/nix-config`):
```bash
mkdir -p ~/code/me
git clone git@github.com:xluffy/nix-config.git ~/code/me/nix-config
cd ~/code/me/nix-config
```

### 3. Initialize Local Environment Variables
Configure your machine-specific flake configuration selector using `.envrc.local` (this file is gitignored):
```bash
cp .envrc.local.example .envrc.local
```
Ensure `.envrc.local` has the correct identifier:
```bash
# Verify or edit this line:
export HM_FLAKE_ATTR=quang.van.nguyen@Nguyens-MacBook-Pro.local
```

### 4. Bootstrap Home Manager
Launch the Nix dev shell (which temporarily pulls in `just` and `home-manager`), then run the bootstrap task:
```bash
nix develop
just bootstrap
```
This builds and installs all CLI tools, development environments, and GUI tools (including macOS-specific utilities like `betterdisplay` and `karabiner-elements`).

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
