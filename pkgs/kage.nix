{
  lib,
  buildGoModule,
  fetchFromGitHub,
  go,
}:
(buildGoModule.override {inherit go;})
rec {
  pname = "kage";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "tamnd";
    repo = "kage";
    rev = "v${version}";
    hash = "sha256-NZc+/EaVyuJxPzEKi4crwOg55KWMc/Km/QywJ5ywKnc=";
  };

  vendorHash = "sha256-Jr9rR7qX8KLuzumz4jUfvuUftW+GO1gq/Dj/oT5+Uto=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/tamnd/kage/cli.Version=${version}"
  ];

  subPackages = ["cmd/kage"];

  env.CGO_ENABLED = "0";

  # kage requires go >= 1.26.4. nixpkgs-unstable has 1.26.3, so we patch down
  # one patch version. No go mod tidy needed — go.sum format unchanged within 1.26.x.
  # TODO: remove this postPatch when nixpkgs-unstable ships go >= 1.26.4.
  postPatch = ''
    substituteInPlace go.mod --replace-fail "go 1.26.4" "go 1.26.3"
  '';

  meta = with lib; {
    description = "Shadow any website for offline viewing, with the JavaScript stripped out";
    homepage = "https://github.com/tamnd/kage";
    license = licenses.mit;
    mainProgram = "kage";
    platforms = platforms.unix;
  };
}
