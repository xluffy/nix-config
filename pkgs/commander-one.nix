{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:
stdenvNoCC.mkDerivation rec {
  pname = "commander-one";
  version = "3.17.1";

  src = fetchurl {
    url = "https://cdn.electronic.us/products/commander/mac/download/commander.dmg";
    hash = "sha256-kHktV4Fy+hUUlHMteqdir8nBKN18snauTCgV1xe5ltA=";
  };

  nativeBuildInputs = [undmg];

  sourceRoot = ".";
  # Preserve the vendor signature. Nix fixup rewrites bundled shell scripts.
  dontFixup = true;

  installPhase = ''
    mkdir -p $out/Applications
    cp -r "Commander One.app" $out/Applications/
  '';

  meta = with lib; {
    description = "Two-panel file manager for macOS";
    homepage = "https://mac.eltima.com/file-manager.html";
    license = licenses.unfree;
    mainProgram = "Commander One";
    platforms = platforms.darwin;
    maintainers = with maintainers; [];
  };
}
