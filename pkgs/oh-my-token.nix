{
  lib,
  swift,
  swiftpm,
  apple-sdk_14,
  darwinMinVersionHook,
}: let
  appSource = ../apps/oh-my-token;

  # Swift sources only. Documentation, Info.plist, and AppIcon.icns are
  # excluded, so a change to them does not recompile the Swift target.
  swiftSource = lib.cleanSourceWith {
    src = appSource;
    filter = path: type:
      lib.cleanSourceFilter path type
      && (
        baseNameOf path
        == "Package.swift"
        || baseNameOf path == "Sources"
        || lib.hasInfix "/Sources/" (toString path)
      );
  };

  # Bundle metadata only. This keeps the app-assembly step very fast.
  appMetadata = lib.cleanSourceWith {
    src = appSource;
    filter = path: type:
      type
      == "regular"
      && lib.elem (baseNameOf path) [
        "Info.plist"
        "AppIcon.icns"
      ];
  };

  binary = swift.stdenv.mkDerivation {
    pname = "oh-my-token-bin";
    version = "0.1.0";

    src = swiftSource;

    nativeBuildInputs = [
      swift
      swiftpm
    ];
    buildInputs = [
      apple-sdk_14
      (darwinMinVersionHook "14.0")
    ];

    strictDeps = true;
    dontConfigure = true;

    # The installed app uses an optimized build. `just app-run` keeps a fast debug build.
    swiftpmBuildConfig = "release";
    swiftpmFlags = [
      "--disable-sandbox"
      "--disable-automatic-resolution"
      "--disable-get-task-allow-entitlement"
      "--product"
      "oh-my-token"
      "--cache-path"
      ".build/shared-cache"
      "--config-path"
      ".build/config"
      "--security-path"
      ".build/security"
    ];

    preBuild = ''
      export HOME="$TMPDIR/home"
      mkdir -p "$HOME"
      mkdir -p .build/shared-cache .build/config .build/security
      export CLANG_MODULE_CACHE_PATH="$TMPDIR/clang-module-cache"
      export SWIFTPM_MODULECACHE_OVERRIDE="$TMPDIR/swift-module-cache"
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/bin"
      install -m 755 "$(swiftpmBinPath)/oh-my-token" "$out/bin/oh-my-token"

      runHook postInstall
    '';

    meta = {
      description = "Menu-bar monitor for Claude and ChatGPT subscription usage";
      platforms = lib.platforms.darwin;
    };
  };
in
  swift.stdenv.mkDerivation {
    pname = "oh-my-token";
    version = "0.1.0";

    src = appMetadata;

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      app="$out/Applications/oh-my-token.app"
      mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
      install -m 644 Info.plist "$app/Contents/Info.plist"
      install -m 644 AppIcon.icns "$app/Contents/Resources/AppIcon.icns"
      install -m 755 ${binary}/bin/oh-my-token "$app/Contents/MacOS/oh-my-token"

      runHook postInstall
    '';

    meta = binary.meta;
  }
