default: switch

alias b := bootstrap
alias s := switch

bootstrap:
    nix develop

switch:
    home-manager switch --flake .#quanggg@xluffys-MacBook-Air.local
