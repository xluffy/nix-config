# Custom packages, built via 'nix build .#kage'
# Also accessible as pkgs.kage in home-manager via the overlay in ../overlays
{
  pkgs,
  pkgsUnstable ? pkgs,
}: let
  # Go 1.26.4 built from source because nixpkgs-unstable only ships 1.26.3.
  # Needed by kage and yomi which require go >= 1.26.4 in their go.mod / deps.
  # TODO: remove when nixpkgs-unstable ships go >= 1.26.4.
  go_1_26_4 =
    if (pkgsUnstable.go_1_26 or null) != null
    then
      pkgsUnstable.go_1_26.overrideAttrs (_old: {
        version = "1.26.4";
        src = pkgs.fetchurl {
          url = "https://go.dev/dl/go1.26.4.src.tar.gz";
          hash = "sha256-T2aKMvv8ETLmqIH7lowvHa2mMUkqM5IRc1+7JVpCYC0=";
        };
      })
    else pkgs.go_1_25;
in {
  kage = pkgs.callPackage ./kage.nix {
    go = go_1_26_4;
  };

  kcctl = pkgs.callPackage ./kcctl.nix {};

  yomi = pkgs.callPackage ./yomi.nix {
    go = go_1_26_4;
  };
}
