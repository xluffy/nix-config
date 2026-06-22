{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  zlib,
}: let
  version = "1.0.0.CR4";

  # Platform-specific asset selection
  asset =
    if stdenvNoCC.hostPlatform.isDarwin && stdenvNoCC.hostPlatform.isAarch64
    then {
      name = "kcctl-${version}-osx-aarch_64.tar.gz";
      hash = "sha256-W2FV6g7BQenU9+qEId0EJl/PuZ0a0rXacdN51e9/Y3M=";
    }
    else if stdenvNoCC.hostPlatform.isLinux && stdenvNoCC.hostPlatform.isx86_64
    then {
      name = "kcctl-${version}-linux-x86_64.tar.gz";
      hash = "sha256-+MElEZTkOr5zo6iFHaHt+gwTpRyXUAPFGQs3k87z4hQ=";
    }
    else throw "Unsupported platform: ${stdenvNoCC.hostPlatform.system}";

  src = fetchurl {
    url = "https://github.com/kcctl/kcctl/releases/download/v${version}/${asset.name}";
    inherit (asset) hash;
  };
in
  stdenvNoCC.mkDerivation {
    pname = "kcctl";
    inherit version src;

    nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [
      autoPatchelfHook
    ];

    buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [
      zlib
      stdenvNoCC.cc.cc.lib
    ];

    sourceRoot = ".";

    installPhase = ''
      mkdir -p $out/bin
      cp kcctl-${version}-*/bin/kcctl $out/bin/kcctl
      chmod +x $out/bin/kcctl
    '';

    meta = with lib; {
      description = "A modern and intuitive command line client for Kafka Connect";
      homepage = "https://github.com/kcctl/kcctl";
      license = licenses.asl20;
      mainProgram = "kcctl";
      platforms = ["aarch64-darwin" "x86_64-linux"];
    };
  }
