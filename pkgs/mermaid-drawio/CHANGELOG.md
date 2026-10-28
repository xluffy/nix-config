---
title: "mermaid-drawio Changelog"
date: 2026-10-28
tags:
  - mermaid
  - drawio
  - diagrams
  - changelog
---

# mermaid-drawio Changelog

This file records each user requirement and the change that answered it.

## 1.0.0 - 2026-10-28

Requirement: manage the tool, the draw.io package, and the font in this repository. Add a diagram rule to the OMP system prompt.

- Moved `restyle_web.py` from a temporary directory to `pkgs/mermaid-drawio/`.
- Added the `mermaid-drawio` command. It runs the three steps: Mermaid to `.drawio`, restyle, and export to PNG.
- Added a markdown mode. `mermaid-drawio DOC.md` renders each Mermaid block in an HTML comment to the PNG file in the next image link.
- The markdown mode stops with an error when a raw `-->` is in the comment. A raw `-->` closes the HTML comment. Write it as `--&gt;`.
- Pinned draw.io to `nixpkgs-unstable` (31.4.5). The tool calls draw.io through the `DRAWIO` variable that the Nix wrapper sets.
- The script now finds sequence diagrams from the lifeline shape. Before, it used the file name.
- The tool starts draw.io with the Chromium `--use-mock-keychain` flag. Before, macOS asked for Keychain access to "draw.io Safe Storage" for each new draw.io build.
- The script now makes room between layers. draw.io 31.4.5 ignores the Mermaid `rankSpacing`. The script moves the lower layers down until each gap holds one lane for each line. A diagram does not need a `rankSpacing` value now.
- Home Manager installs the Recursive font (`font.nix`) and `mermaid-drawio` (`gui.nix`). The manual font file in `~/Library/Fonts` is gone.
- Added `home-manager/config/omp/APPEND_SYSTEM.md`, a copy of the pi file with a new "Diagrams" rule. Home Manager links it into the three OMP agent directories.

## 0.5.0 - 2026-10-28

Requirement: some lines go over text and hide characters. Change the font size from 14 to 11.

- Each group title is now a separate text box on top of all lines. The box uses the group colour as an opaque background. The title moved from the top centre to the top-left corner, where fewer lines go.
- Lines with a label move to the end of the cell list. Their grey label is now on top of other lines.
- Sequence diagrams: message labels and free text cells have a white background. Lifelines do not go through the text now.
- Changed the font size from 14 to 11 in all diagrams.

## 0.4.0 - 2026-10-28

Requirement: in diagrams with many lines, lines to the same destination overlap.

- Each line gets its own exit point and entry point along the box edge, as in the draw.io web layout.
- Each line gets its own horizontal lane between two layers. Two lines do not share a horizontal segment now.
- The script tries two lane orders and keeps the order with fewer crossings. A crossing shows an arc jump.
- Each label sits in the middle of the horizontal lane of its line. Labels do not collide now.
- Dashed lines keep the draw.io router.
- Fixed: waypoints are now relative to the parent container of the line. Before, one line in A1 went off the bottom of the diagram.
- Dense diagrams used `"rankSpacing": 120` to make room for the lanes. Version 1.0.0 removed this need.

## 0.3.0 - 2026-10-28

Requirement: make the PNG files look like the draw.io web Mermaid import.

- Added `restyle_web.py`. It copies the theme that draw.io web applies when it imports Mermaid:
  - Font: Recursive, with a Google Fonts source.
  - Boxes: white fill, dark 2 px border, flat 4 px shadow.
  - Groups: pastel fill and border colours in declaration order (pink, teal, orange, cyan).
  - Lines: black, 2 px, right angles with rounded corners, arc jumps, block arrows.
  - Labels: grey background.
  - Sequence diagrams: the same theme with dark lifelines.
- Invisible Mermaid links (`~~~`) stay invisible.
- Installed the Recursive font. Without it, the draw.io CLI export used a serif font.

## 0.2.0 - 2026-10-28

Requirement: improve the look of the plain draw.io conversion.

- Added a first restyle script with a Helvetica font and a custom palette.

## 0.1.0 - 2026-10-28

Requirement: render the Mermaid diagrams of a runbook to draw.io files and PNG files.

- Used the draw.io desktop CLI to convert each `.mmd` file to a `.drawio` file. Then exported the PNG file with the diagram in it (`-e -b 16 -s 2`).
- A direct Mermaid to PNG export does not work. Convert to `.drawio` first.
- The CLI does not support `--layout libavoid`.
