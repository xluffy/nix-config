---
title: "pi-usage-widget vendored copy"
date: 2026-08-19
tags:
  - pi
  - extension
  - vendored
  - usage-dashboard
  - attribution
---

# pi-usage-widget

## Origin and attribution

- Project: pi-usage-widget
- Author: Cullen Botha (cullendotdev)
- Upstream repo: <https://github.com/cullendotdev/pi-usage-widget>
- Vendored version: 0.2.1
- License: MIT. The full license text is in the `LICENSE` file in this folder.

The upstream project credits [@tmustier](https://github.com/tmustier) for the original work on `pi-usage-extension`, which the project builds on.

This repo manages pi extensions with home-manager. All extension files must live in this repo. This folder is a vendored copy of the upstream project.

## What we changed

- Removed the widget that shows above the editor.
- Removed the keyboard shortcuts `ctrl+alt+u` and `alt+u`.
- Removed the `/usage-settings` command and the settings menu.
- Removed seven files that only the widget and the settings menu needed:
  `usage-widget.ts`, `widget-render.ts`, `settings-menu.ts`, `color-engine.ts`,
  `color-picker.ts`, `terminal-palette.ts`, `config-persistence.ts`.
- Rewrote `index.ts` to keep only the `/usage` command.

## What stays unchanged

These four files are verbatim copies of the upstream files at version 0.2.1:

- `data-collection.ts`
- `usage-modal.ts`
- `formatting.ts`
- `types.ts`

## Usage in this repo

- `/usage` opens the dashboard.
- `Tab` or arrow keys change the period.
- `Enter` expands a provider to show its models.
- `v` toggles the insights view.
- `q` or `Escape` closes the dashboard.

## How to update from upstream

1. Clone the upstream repo.
2. Compare the files with this folder.
3. Copy the changed files into this folder.
4. Reapply the local change to `index.ts`: keep only the `/usage` command.
5. Run `just fix`, `just check`, and `just switch`.
6. Update the version number in this file.

Keep the `LICENSE` file at each sync. The copyright notice stays with the code.
