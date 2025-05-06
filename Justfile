default: setup

setup:
    mkdir -pv /Users/quanggg/.config/nix
    cp nix.conf /Users/quanggg/.config/nix/

switch:
    nix build .#homeConfigurations."quanggg".activationPackage
    home-manager -f home.nix switch
