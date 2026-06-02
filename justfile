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
  home-manager switch --flake ".#${HM_FLAKE_ATTR}"

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

# Run bats tests for scripts in home-manager/config/pi/
test:
  bats tests/

fix:
  alejandra .
  deadnix --edit .
  statix fix .

# fix for: error: attribute 'git-xet' missing
update:
  nix flake update nixpkgs-unstable
