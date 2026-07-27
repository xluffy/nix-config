{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:
stdenvNoCC.mkDerivation rec {
  pname = "flux-markdown";
  version = "1.34.464";

  src = fetchurl {
    url = "https://github.com/xykong/flux-markdown/releases/download/v${version}/FluxMarkdown.dmg";
    hash = "sha256-YFyQIhNa9OFW4z2IQqyeaPUHcgK18OBUCQghXTzQH6E=";
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r FluxMarkdown.app $out/Applications/
  '';

  meta = with lib; {
    description = "A modern Markdown editor for macOS";
    homepage = "https://github.com/xykong/flux-markdown";
    license = licenses.unfree;
    mainProgram = "FluxMarkdown";
    platforms = platforms.darwin;
    maintainers = with maintainers; [ ];
  };
}
