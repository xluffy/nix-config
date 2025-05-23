default: switch

alias b := bootstrap
alias s := switch
alias l := list
alias ls := list

bootstrap:
  nix develop

switch:
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

fix:
  alejandra .
  deadnix --edit .
  statix fix .
