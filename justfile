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
  home-manager switch --flake .#xluffyg@xluffys-MacBook-Air.local
  home-manager switch --flake .#xluffy@Nguyens-MacBook-Pro.local
  home-manager switch --flake .#xluffy@nixos-dell-wyse-5070

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
