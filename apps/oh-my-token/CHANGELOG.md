---
title: "oh-my-token Changelog"
date: 2026-10-09
tags:
  - oh-my-token
  - changelog
  - swift
  - swiftui
  - macos
  - usage-monitor
---

# oh-my-token Changelog

This file records the changes to the `oh-my-token` app.
It starts with the initial version and ends with the current state.
Read this file to understand the app and to build your own version.

## How to build

- The app needs macOS 14 or later.
- Nix supplies Swift 5.10 and the macOS SDK. Xcode is not required.
- `nix build .#oh-my-token` builds the app.
- `just switch` installs the app through Home Manager.
- `just app-run` builds and runs the app from source with a fast cache.
- The Swift package has no external dependencies.
- The Swift source lives in `apps/oh-my-token/Sources/OhMyToken/`.
- The Nix package lives in `pkgs/oh-my-token.nix`.

## Initial version

### Multi-account menu bar monitor

- The menu bar shows the usage of three accounts: Claude Personal, Claude Work, and ChatGPT Plus Personal.
- Each account uses a separate persistent WebKit data store.
- One account cannot overwrite the reading of another account.

### Separate website readers

- The Claude reader reads `/api/account`, `/api/organizations`, and the organization usage endpoint.
- The reader shows session, weekly, and model-specific percentages and reset times.
- The ChatGPT reader reads the session, the account check, and the dashboard usage endpoint.

### Sign-in and account checks

- The Accounts window has a Sign in action for each account.
- The Check account action reads the usage after sign-in.
- A failed request keeps the last reading with its original time and a stale marker.
- An authentication rejection clears the reading.

### Session import

- The Import session action accepts a website Cookie request header.
- The app stores the imported cookies in the local macOS Keychain.
- The import helps when Google sign-in or company SSO cannot run in the app browser.

### Nix packaging

- The app builds from source with Nix.
- Home Manager installs the app on GUI-enabled macOS hosts.
- Linux configurations do not include the package.

## Changes

### Work and Codex dashboard

- The ChatGPT reader now reads only the Work and Codex dashboard allowance.
- The dashboard shows a 5-hour window and a weekly window.
- An account with extra allowances shows one row for each allowance.

### Read-only guarantee

- The app never sends a prompt and never uses account tokens.
- The shared request helper sends GET requests only and accepts no request body.
- This rule applies to Claude and ChatGPT.
- The app removed the conversation initialization request.

### Nix overlay fix

- The overlay no longer forces stdenv during evaluation.
- The platform comes from the pre-overlay package set.
- The infinite recursion is gone and `just check` passes.

### Custom app icon

- The app has a gradient icon in `AppIcon.icns`.
- The icon contains all 10 standard sizes.
- Finder and the app window show the icon.

### Prominent controls

- The popover buttons have a visible resting surface.
- The Accounts window uses bordered buttons.
- Check account is prominent and Disconnect is red.

### Custom menu bar icon

- The menu bar shows a custom 18x18 template icon.
- The icon size matches the menu bar height of BetterDisplay and Clocker.
- The icon is monochrome and adapts to light and dark mode.

### Compact popover layout

- Each usage window is one line plus a thin progress bar.
- The reset countdown and the update time are inline.
- All accounts fit without scrolling.

### Faster builds

- The Nix derivation is split into a Swift binary step and a small app-bundle step.
- An icon or plist change rebuilds in about 3 seconds.
- A `.#swift` dev shell and `just app-run` give a fast incremental build.

### Focused Accounts window

- The Accounts window manages accounts only.
- It shows the connection status, the workspace picker, and the account actions.
- Usage stays in the menu bar and is not repeated in the window.

### Usage color thresholds

- Below 80 percent the progress bar uses the accent color.
- From 80 percent the bar turns orange. From 90 percent the bar turns red.
- The rule is the same for every provider.

### Account order

- The main screen sorts accounts by name.
- The name uses the form `Provider · Profile`.
- ChatGPT Plus · Personal comes first, then Claude · Personal, then Claude · Work.

### Workspace picker

- The picker now shows only when the account has more than one workspace.
- The Claude usage endpoint is per organization. The app must know the organization.
- One workspace is selected automatically, so no picker is needed.

### Security document

- `SECURITY.md` describes where the app stores cookies and sessions.
- It describes the Keychain service, the WebKit data folder, and the UserDefaults keys.
- It repeats the read-only rule and the Disconnect behavior.

### Audit fixes

- OMT-01: Disconnect is available when the account check failed or did not run.
- OMT-02: The sign-in window and the popups show the actual page origin and an external-site warning.
- OMT-02: The main window and the popups use one navigation rule. A clicked external link opens in the system browser.
- OMT-03: The Claude reader clears a saved workspace that is no longer available.
- OMT-03: One remaining workspace is selected again. More than one workspace shows the picker.
- OMT-04: An invalid reset time becomes unavailable. The other usage values stay.
- `SECURITY.md` now states that the ChatGPT reader uses the session token for authentication.

### Performance review fixes

- Finding 1: A usage read does not keep the full website loaded.
- Finding 1: Each read loads the provider `/robots.txt` file in a hidden page. The reader script runs on this page. The app closes the page after the read.
- Finding 1: The sign-in website exists only while the sign-in window is open. When the window closes, the app closes the website and its popups. The cookies stay.
- Finding 2: Refresh reads all connected accounts at the same time. A slow account does not delay the other accounts.
- Finding 3: Automatic refresh runs every 5 minutes. In Low Power Mode or at a serious thermal state, it runs every 15 minutes.
- Finding 3: The refresh timer has a tolerance of one fifth of the interval. macOS can group the wake-up with other timers.
- Finding 3: Manual refresh runs at once.
- Finding 4: The Nix package builds a release binary. `just app-run` keeps the fast debug build.

## Notes for your own build

- Change the account list in `Sources/OhMyToken/Account.swift`.
- Change the reader scripts in `ClaudeUsageReader.swift` and `ChatGPTUsageReader.swift`.
- Keep the read-only rule. Do not add a request body or a prompt request.
- Use `just app-run` for fast iteration and `just switch` for the final install.
