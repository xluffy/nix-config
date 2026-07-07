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
- `models.json` — custom model definitions (deepseek, mimo, claude)
- `APPEND_SYSTEM.md` — system-level policy appended to every pi session (no em dashes, minimize semicolons)
- `cached-op.sh` — cached operation helper

### Prompt Templates

Live in `home-manager/config/pi/prompts/` (symlinked to `~/.pi/agent/prompts/` by HM):
- `spec-workflow.md` — Full spec → plan → phased execution → pair review
- `spec-quick.md` — Lightweight spec for small changes
- `review.md` — Code review against specs and best practices
- `git-ci.md` — Conventional commit messages and PR workflow
- `grill-me.md` — Stress-test a plan/design/document through relentless Q&A
- `audit-me.md` — Audit code/documents against defined criteria
- `handoff.md` — Handoff context between sessions

### Skills

Domain-specific knowledge in `home-manager/config/pi/skills/`:
- `nix-helper` — Nix, NixOS, Home Manager configurations
- `nix-config-helper` — This repo's structure, modules, tasks, and secrets
- `bash-scripting` — Clean, maintainable bash/shell scripts
- `laravel-helper` — Laravel >=10.x coding conventions and patterns
- `laravel-best-practices` — Impact-prioritized Laravel rules by topic (Eloquent, caching, queues, security, etc.)

### Extensions

Minimal custom extensions in `home-manager/config/pi/extensions/`:
- `company-provider.ts` — Custom model provider
- `minimal-footer.ts` — Minimal TUI footer

### Policy

- All prompt templates and skills must follow `APPEND_SYSTEM.md` (no em dashes in prose, minimize semicolons)
- Prompts stay under 200 lines. Skills only for recurring, narrow, well-defined problems
- No third-party extensions — if it's not in this repo, it's not needed

## Secrets

Encrypted with `agenix`. Host SSH keys are used for decryption. `secrets.nix` maps secret files to host public keys.

## Coding Conventions

- Nix formatting: alejandra
- Dead code removal: deadnix
- Static analysis: statix
- All changes go through `just check` before `just switch`
- Host-specific overrides use `extraModules` in `flake.nix`, not inline conditionals
