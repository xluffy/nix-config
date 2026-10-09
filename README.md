# nix-config

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

Home Manager configuration for macOS (aarch64-darwin) and Ubuntu/NixOS (x86_64-linux) machines.

## Quick Start

```bash
# First-time setup
just bootstrap

# Apply config (reads $HM_FLAKE_ATTR from .envrc.local)
just switch
```

![diff](./docs/diff.png)

## Structure

```
.
├── flake.nix              # Entry point: inputs, homeConfigurations, devShells
├── justfile               # Task runner: switch, check, fix, update, gc
├── apps/oh-my-token/      # Swift menu-bar app source
├── pkgs/                 # Custom Nix packages
├── home-manager/
│   ├── home.nix           # Main HM config
│   ├── modules/           # core/, programs/, shell/
│   └── config/            # Raw configs (.npmrc, iterm2.json, pi/)
├── secrets/               # agenix-encrypted secrets
├── docs/                  # Detailed docs per topic
└── bin/                   # bootstrap.sh, check-eval.sh
```

See [AGENTS.md](AGENTS.md) for the full architecture.

## Common Commands

| Command | Description |
|---|---|
| `just switch` | Apply Home Manager config |
| `just check` | Validate evaluation + run tests |
| `just fix` | Format (alejandra) + lint (deadnix, statix) |
| `just update` | Update `nixpkgs-unstable` flake input |
| `just gc` | Garbage collect profiles older than 2 days |

## FluxMarkdown maintenance fork

Source stays in [xluffy-fork/flux-markdown](https://github.com/xluffy-fork/flux-markdown), not in `apps/`.
This unofficial fork credits [xykong](https://github.com/xykong/flux-markdown) and all upstream contributors.
The original GPL-3.0 license and copyright notices remain unchanged.

`pkgs/flux-markdown.nix` installs a pinned ARM64 DMG from the fork.
Home Manager manages updates. The app has no in-app updater.
These builds use ad-hoc signatures, without Developer ID signing or notarization.

To ship a change:

1. Change and test the separate fork. Keep upstream credit and license notices.
2. Run `make release patch` in the fork. GitHub Actions tests and publishes the tagged artifacts.
3. Prefetch the new DMG with `nix store prefetch-file --json`, using its release download URL.
4. Update `version` and `src.hash` in `pkgs/flux-markdown.nix`.
5. Run `just check`, then `just switch`.

See the [fork release guide](https://github.com/xluffy-fork/flux-markdown/blob/master/docs/release/RELEASE_PROCESS.md) for build requirements and source archives.

## Docs

| Doc | Topic |
|---|---|
| [AGENTS.md](AGENTS.md) | Full architecture, directory layout, conventions |
| [docs/macOS.md](docs/macOS.md) | macOS-specific setup |
| [docs/ubuntu.md](docs/ubuntu.md) | Ubuntu/NixOS setup |
| [docs/atuin.md](docs/atuin.md) | Atuin shell history (setup, sync, troubleshooting) |
| [docs/dev-env.md](docs/dev-env.md) | Development environment details |
| [docs/pi-deepseek.md](docs/pi-deepseek.md) | Pi coding agent with DeepSeek |
| [docs/edge.md](docs/edge.md) | Nixpkgs edge/unstable usage |
| [docs/bookmarks.md](docs/bookmarks.md) | Browser bookmarks |
| [docs/NixOS.md](docs/NixOS.md) | NixOS-specific notes |
| [docs/coding-agents.md](docs/coding-agents.md) | Personal experience with coding agents (Claude Code, Pi, OpenCode, etc.) |
