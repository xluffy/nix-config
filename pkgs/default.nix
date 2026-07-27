# Custom packages: kage, kcctl, yomi, flux-markdown
# Built via 'nix build .#<name>' or accessed as pkgs.<name> in home-manager
# via the overlay in ../overlays
{
  pkgs,
  pkgsUnstable ? pkgs,
}: {
  kage = pkgs.callPackage ./kage.nix {
    go = pkgsUnstable.go_1_26;
  };

  kcctl = pkgs.callPackage ./kcctl.nix {};

  yomi = pkgs.callPackage ./yomi.nix {
    go = pkgsUnstable.go_1_26;
  };

  flux-markdown = pkgs.callPackage ./flux-markdown.nix {};
}
