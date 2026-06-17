# Overlays applied to nixpkgs imports.
#
# addions           — makes all packages from ../pkgs available as pkgs.<name>
#                      using only stable nixpkgs.
# additionsUnstable — same, but passes pkgs-unstable so packages that need a
#                      newer Go (e.g. kage) get it without resorting to workarounds.
{
  additions = final: _prev: import ../pkgs {pkgs = final;};

  additionsUnstable = pkgsUnstable: final: _prev:
    import ../pkgs {
      pkgs = final;
      inherit pkgsUnstable;
    };
}
