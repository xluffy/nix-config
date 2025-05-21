{ pkgs, pkgs-unstable, ... }:

{
  home.packages = with pkgs; [
    # ansible-lint
    gcc
    gnumake
    go
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    pkgs-unstable.bun
    pkgs-unstable.libpq
    postgresql
    python313
    regal
    rustc
    rustup
    scc
    terraform-ls
    tflint
    tfsec
  ];
}
