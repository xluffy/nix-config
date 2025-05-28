# macOS System Preferences Setup Guide (Manual Steps)

This guide outlines the manual System Preferences settings that must be configured through the GUI (not automatable via terminal or CLI).

Appearance
  - Auto
  - Sidebar icon size -> "Medium"
  - Show Scroll Bars -> "When scrolling"

Dock
- Remove most applications from Dock
- Automatic Hide
- Smaller Dock
- "Show recent applications in Dock" -> off
- "Show indicators for open applications" -> on
- Battery -> "Show Percentage"

Security: Touch ID

Notifications: Off, except for Calendar, Slack, Telegram

Siri: Disabled

Trackpad
  - Tap to Click
  - Point & Click -> Look up & data detectors off
  - More Gestures -> Notification Centre off

Keyboard
  - Key repeat rate -> Fast
  - Delay until repeat -> Short
  - Text Input
    - disable "Capitalise word automatically"
    - disable "Add full stop with double-space"
    - disable "Use smart quotes and dashes"
    - use " for double quotes
    - use ' for single quotes
  - Keyboard -> Mission Control -> disable all, except:
    - Mission Control
    - Application windows
    - Move left a space -> disable (prepare for moving in Terminal)
    - Move right a space -> disable (prepare for moving in Terminal)
  - Press FN to -> "Do Nothing"
  - Keyboard Shortcuts -> Spotlight -> CMD + Space disable
  - We will be using Raycast instead
  - Input Sources (Disable all)

Mission Control: Hot Corners: disable all

Finder
  - General
    - New Finder windows show: [Downloads]
    - Show these items on the desktop: disable all
  - Sidebar:
    - activate all Favorites (except Recents, Movies, Music)
    - disable all Location (except iCloud Driver)
    - move Library to Favorites
  - Show only:
    - Desktop
    - Downloads
    - Documents
    - [User]
    - Library
  - Tags
    - disable all
  - Advanced
    - Show all Filename Extensions
    - Remove Items from Bin after 30 Days
    - View -> Show Preview (e.g. image files)

Security and Privacy
  - Turn on FileVault
  - Add Browser to "Screen Recording"

Storage
  - Remove Garage Band & Sound Library
  - Remove iMovie
