{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:
stdenvNoCC.mkDerivation rec {
  pname = "flux-markdown";
  version = "1.34.485-xluffy.1";

  src = fetchurl {
    url = "https://github.com/xluffy-fork/flux-markdown/releases/download/v${version}/FluxMarkdown.dmg";
    hash = "sha256-ioLv9NA68wCFguqYwkoeTOdKISZt3iGXLvNa6kKx2OU=";
  };

  nativeBuildInputs = [undmg];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r FluxMarkdown.app $out/Applications/
  '';

  meta = with lib; {
    description = "Unofficial personal FluxMarkdown fork with Markdown QuickLook previews";
    homepage = "https://github.com/xluffy-fork/flux-markdown";
    license = licenses.gpl3Only;
    mainProgram = "FluxMarkdown";
    platforms = ["aarch64-darwin"];
    maintainers = with maintainers; [];
  };
}
