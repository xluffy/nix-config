{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    conftest
    devenv
    gcc
    gnumake
    go
    (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
    openssl_1_1
    pkgs-unstable.ansible-lint
    pkgs-unstable.bun
    pkgs-unstable.libpq
    pkgs-unstable.llm
    pkgs-unstable.nodejs_20
    pkgs-unstable.terraform
    postgresql
    python39
    # (python39.withPackages (ppkgs: [
    #   ppkgs.llm
    # ]))
    poetry
    regal
    rustc
    rustup
    scc
    sops
    terragrunt
    terraform-ls
    tflint
    tfsec
  ];
}
