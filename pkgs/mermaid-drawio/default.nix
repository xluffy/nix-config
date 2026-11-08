# Render Mermaid diagrams to PNG files with the draw.io web look.
# The diagrams use the Recursive font. Home Manager installs it in
# home-manager/modules/core/font.nix. Without it, draw.io uses a fallback font.
{
  lib,
  stdenvNoCC,
  makeWrapper,
  python3,
  drawio,
}:
stdenvNoCC.mkDerivation {
  pname = "mermaid-drawio";
  version = "1.1.0";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./mermaid-drawio.py
      ./restyle_web.py
    ];
  };

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    runHook preInstall
    install -Dm644 mermaid-drawio.py restyle_web.py -t $out/libexec/mermaid-drawio
    makeWrapper ${python3.interpreter} $out/bin/mermaid-drawio \
      --add-flags $out/libexec/mermaid-drawio/mermaid-drawio.py \
      --set DRAWIO ${lib.getExe drawio}
    runHook postInstall
  '';

  meta = {
    description = "Render Mermaid diagrams to PNG files with the draw.io web theme";
    mainProgram = "mermaid-drawio";
    inherit (drawio.meta) platforms;
  };
}
