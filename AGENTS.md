# nix-config Architecture

Home Manager configuration for macOS (MacBook Pro, aarch64-darwin) and Ubuntu/NixOS (x86_64-linux) machines.

## Directory Structure

```
.
├── flake.nix                 # Entry point: inputs, mkHomeConfig, homeConfigurations, devShells
├── flake.lock
├── shell.nix                 # Dev shell (direnv-managed)
├── justfile                  # Task runner: switch, check, fix, update, gc
├── nix.conf                  # Nix daemon config
├── home-manager/
│   ├── home.nix              # Main HM config: programs, nix-index, llm-agents, pi-agent
│   ├── modules/
│   │   ├── core/             # dev.nix, cli.nix, gui.nix, font.nix, nix.nix, dev-php.nix, dev-llm.nix, dev-db.nix, dev-ops.nix, dev-terraform.nix
│   │   ├── programs/         # git.nix, tmux.nix, fzf.nix, ssh.nix, 1password.nix, common.nix, pi.nix
│   │   └── shell/            # bash.nix, function.sh, inputrc, prompt configs
│   └── config/               # Raw configs: .npmrc, iterm2.json, kube_config.age, pi/
├── hosts/                    # Host-specific notes (README.md)
├── secrets/
│   ├── secrets.nix           # Agenix decryption mapping
│   ├── deepseek.age
│   └── README.md
├── bin/                      # bootstrap.sh, check-eval.sh
└── docs/                     # macOS.md, ubuntu.md, edge.md, dev-env.md, NixOS.md, pi-deepseek.md, bookmarks.md
```

## Key Dependencies (flake inputs)

- `nixpkgs` → `nixos-25.05` (stable)
- `nixpkgs-unstable` → `nixos-unstable` (for bleeding-edge packages)
- `home-manager` → `release-25.05`
- `agenix` — secret encryption/decryption
- `nix-index-database` — command-not-found lookup
- `llm-agents` (numtide/llm-agents.nix) — LLM agent packages

## Hosts

| Host output name | System | User | GUI |
|---|---|---|---|
| `quang.van.nguyen@Nguyens-MacBook-Pro.local` | aarch64-darwin | quang.van.nguyen | yes |
| `xluffy-zzbot@elbaf-sky-n100` | x86_64-linux | xluffy-zzbot | no |

Each host has custom `extraSpecialArgs`: `pkgs-unstable`, `llm-agents`, `agenix-cli`, `hasGUI`.

## Common Commands

```bash
just switch   # Apply HM config (reads $HM_FLAKE_ATTR from .envrc.local)
just check    # Validate eval
just fix      # alejandra format + deadnix + statix
just update   # Update nixpkgs-unstable flake input
just gc       # Garbage collect profiles older than 2 days
```

## Pi-Agent Configuration

Managed via `home-manager/modules/programs/pi.nix` and `home-manager/config/pi/`:
- `settings.json` — pi settings
- `models.json` — custom model definitions
- `cached-op.sh` — cached operation helper

Prompt templates live in `.pi/agent/prompts/` (managed by HM as symlinks to nix store).

## Secrets

Encrypted with `agenix`. Host SSH keys are used for decryption. `secrets.nix` maps secret files to host public keys.

## Coding Conventions

- Nix formatting: alejandra
- Dead code removal: deadnix
- Static analysis: statix
- All changes go through `just check` before `just switch`
- Host-specific overrides use `extraModules` in `flake.nix`, not inline conditionals
