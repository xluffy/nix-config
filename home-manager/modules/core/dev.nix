{ pkgs, pkgs-unstable, ... }:

{
  home.packages = with pkgs; [
    pkgs-unstable.ansible-lint
    gcc
    gnumake
    go
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    openssl_1_1
    pkgs-unstable.bun
    pkgs-unstable.libpq
    pkgs-unstable.nodejs_20
    postgresql
    python39
    poetry
    regal
    rustc
    rustup
    scc
    pkgs-unstable.terraform
    terragrunt
    terraform-ls
    tflint
    tfsec
  ];
}
