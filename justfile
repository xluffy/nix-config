default: switch

alias b := bootstrap
alias s := switch
alias l := list
alias ls := list
alias f := fix
alias c := check

bootstrap:
  nix develop

# Set HM_FLAKE_ATTR to your flake output name (user@hostname). Use .envrc.local (gitignored) or shell rc so each machine can differ without editing this file.
switch:
  #!/usr/bin/env bash
  set -euo pipefail
  profile="$HOME/.local/state/nix/profiles/home-manager"
  old_gen=$(readlink -f "$profile" 2>/dev/null || true)
  home-manager switch --flake ".#${HM_FLAKE_ATTR}"
  new_gen=$(readlink -f "$profile")
  if [ -n "$old_gen" ] && [ "$old_gen" != "$new_gen" ]; then
    echo ""
    echo "📦 Package changes:"
    nvd diff "$old_gen" "$new_gen"
  fi

list:
  home-manager packages

gc-dry-run:
  nix-collect-garbage --delete-older-than 2d --dry-run

gc:
  nix-collect-garbage --delete-older-than 2d

check:
  just check-eval
  just test

check-eval:
  bash bin/check-eval.sh

test:
  bats tests/

fix:
  alejandra .
  deadnix --edit .
  statix fix .

update:
  nix flake update nixpkgs-unstable
  nix flake update nixpkgs
  nix flake update llm-agents
