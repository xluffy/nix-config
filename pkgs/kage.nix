{
  lib,
  buildGoModule,
  fetchFromGitHub,
  go,
}:
(buildGoModule.override {inherit go;})
rec {
  pname = "kage";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "tamnd";
    repo = "kage";
    rev = "v${version}";
    hash = "sha256-s7bi4JIxLUAaMVdhRoQiYANJLBLg8bWiZMbRbd23POs=";
  };

  vendorHash = "sha256-Jr9rR7qX8KLuzumz4jUfvuUftW+GO1gq/Dj/oT5+Uto=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/tamnd/kage/cli.Version=${version}"
  ];

  subPackages = ["cmd/kage"];

  env.CGO_ENABLED = "0";

  meta = with lib; {
    description = "Shadow any website for offline viewing, with the JavaScript stripped out";
    homepage = "https://github.com/tamnd/kage";
    license = licenses.mit;
    mainProgram = "kage";
    platforms = platforms.unix;
  };
}
