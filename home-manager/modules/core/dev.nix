{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    caddy
    gcc
    gnumake
    golangci-lint
    hugo
    k6
    libjpeg
    libpng
    librsvg
    maple-mono.NF-unhinted
    maple-mono.truetype
    mkcert
    pkg-config
    pkgs-unstable.ansible-lint
    pkgs-unstable.bun
    pkgs-unstable.cursor-cli
    pkgs-unstable.git-xet
    pkgs-unstable.go
    pkgs-unstable.node-gyp
    pkgs-unstable.nodejs_24
    prometheus.cli
    # pip 26.2.2 distrusts the compromised eMudhra CAs. Drop the override when
    # nixpkgs ships pip >= 26.2.2.
    (python313.withPackages (ps: [
      (ps.pip.overridePythonAttrs rec {
        version = "26.2.2";
        src = fetchFromGitHub {
          owner = "pypa";
          repo = "pip";
          tag = version;
          hash = "sha256-iH5O1kneYzoHpzbfgrJc/8gVr57CNX3/xpwel4ueNqE=";
        };
      })
    ]))
    regal
    rustc
    rustup
    scc
    uv
    yarn
    zlib
  ];
}
