{ pkgs, pkgs-unstable, ... }:

{
  home.packages = with pkgs; [
    # ansible-lint
    gcc
    gnumake
    go
    google-cloud-sdk
    pkgs-unstable.bun
    pkgs-unstable.libpq
    postgresql
    python313
    nodejs_20
    regal
    rustc
    rustup
    scc
    terraform-ls
    tflint
    tfsec
  ];
}
