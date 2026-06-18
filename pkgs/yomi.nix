{
  lib,
  buildGoModule,
  fetchFromGitHub,
  go,
}:
(buildGoModule.override {inherit go;})
rec {
  pname = "yomi";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "tamnd";
    repo = "yomi";
    rev = "v${version}";
    hash = "sha256-sbFWfrhxYdh7cG6/WDSc7vpUaK5stym8nrj2rcE77aQ=";
  };

  vendorHash = "sha256-f+l1D0kGn1fHaOzZHafv08Nr+iAsndY7j7qCh0UVK+8=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/tamnd/yomi/cli.Version=${version}"
  ];

  subPackages = ["cmd/yomi"];

  env.CGO_ENABLED = "0";

  meta = with lib; {
    description = "Read any web page, or a whole website, into clean Markdown";
    homepage = "https://github.com/tamnd/yomi";
    license = licenses.mit;
    mainProgram = "yomi";
    platforms = platforms.unix;
  };
}
