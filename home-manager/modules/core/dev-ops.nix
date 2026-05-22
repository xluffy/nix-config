{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    aws-vault
    awscli2
    conftest
    docker-client
    eksctl
    k9s
    kubectl
    kubectx
    kubernetes-helm
    (wrapHelm kubernetes-helm {
      plugins = with kubernetes-helmPlugins; [
        helm-diff
        helm-secrets
      ];
    })
    (pkgs-unstable.google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
    pkgs-unstable.sops
  ];
}
