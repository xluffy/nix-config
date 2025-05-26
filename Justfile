default: switch

alias b := bootstrap
alias s := switch
alias l := list
alias ls := list
alias f := fix
alias c := check

bootstrap:
  nix develop

switch: fix
  home-manager switch --flake .#quanggg@xluffys-MacBook-Air.local

list:
  home-manager packages

gc-dry-run:
  nix-collect-garbage --delete-older-than 2d --dry-run

gc:
  nix-collect-garbage --delete-older-than 2d

check:
  alejandra --check .
  deadnix .
  statix check .

fix: check
  alejandra .
  deadnix --edit .
  statix fix .
