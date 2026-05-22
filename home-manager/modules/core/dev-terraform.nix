{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    pkgs-unstable.terraform
    terraform-ls
    terragrunt
    tflint
    tfsec
  ];
}
