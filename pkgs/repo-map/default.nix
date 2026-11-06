# Print the Aider repository map without Aider's chat or LLM client.
# repo-map.py imports aider.repomap from the nixpkgs aider-chat package.
{
  lib,
  stdenvNoCC,
  makeWrapper,
  python3,
  aider-chat,
  git,
}: let
  python = python3.withPackages (ps: [(ps.toPythonModule aider-chat)]);
in
  stdenvNoCC.mkDerivation {
    pname = "repo-map";
    version = "1.0.0";

    src = lib.fileset.toSource {
      root = ./.;
      fileset = ./repo-map.py;
    };

    nativeBuildInputs = [makeWrapper];

    installPhase = ''
      runHook preInstall
      install -Dm644 repo-map.py -t $out/libexec/repo-map
      makeWrapper ${python.interpreter} $out/bin/repo-map \
        --add-flags $out/libexec/repo-map/repo-map.py \
        --prefix PATH : ${lib.makeBinPath [git]}
      runHook postInstall
    '';

    meta = {
      description = "Print the Aider repository map: ranked files with their key definitions";
      mainProgram = "repo-map";
      inherit (aider-chat.meta) license platforms;
    };
  }
