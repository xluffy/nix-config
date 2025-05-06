default: build

alias b := build
alias s := switch

setup:
    mkdir -pv /Users/quanggg/.config/nix
    cp nix.conf /Users/quanggg/.config/nix/

build:
    nix build .#homeConfigurations."quanggg".activationPackage

switch:
    home-manager switch --flake .
