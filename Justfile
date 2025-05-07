default: switch

alias b := build
alias s := switch

setup:
    mkdir -pv /Users/quanggg/.config/nix
    cp nix.conf /Users/quanggg/.config/nix/
    nix shell nixpkgs#home-manager

build:
    nix build .#homeConfigurations."quanggg".activationPackage

switch:
    home-manager switch --flake .#quanggg@xluffys-MacBook-Air.local
