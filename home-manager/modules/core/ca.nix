{
  lib,
  pkgs,
  ...
}: let
  # eMudhra intermediate CA key compromise (https://emudhra.we-have-a-problem.com/).
  # NSS 3.131.1 removes emSign ECC Root CA - G3. It keeps Comodo AAA Services
  # root as email-only, but Apple LibreSSL (/usr/bin/curl, /usr/bin/git)
  # ignores that restriction, so the blacklist rejects it for all uses.
  # Drop the version override when the nixpkgs input ships cacert >= 3.131.1.
  # Local override, not an overlay: changing pkgs.cacert rebuilds every
  # package that depends on it.
  cacert =
    (pkgs.cacert.override {
      blacklist = ["Comodo AAA Services root"];
    }).overrideAttrs {
      version = "3.131.1";
      src = pkgs.fetchurl {
        urls = [
          "https://hg-edge.mozilla.org/projects/nss/raw-file/NSS_3_131_1_RTM/lib/ckfw/builtins/certdata.txt"
          "https://raw.githubusercontent.com/nss-dev/nss/refs/tags/NSS_3_131_1_RTM/lib/ckfw/builtins/certdata.txt"
        ];
        hash = "sha256-PsK00kDcEsdH6vRQBh24SvdXxIO72jAvninOtdcL5RA=";
      };
    };
  caBundle = "${cacert}/etc/ssl/certs/ca-bundle.crt";
in {
  # Shell tools only. macOS GUI apps use the Keychain, which Apple already patched.
  home.sessionVariables = lib.mkIf pkgs.stdenv.isDarwin {
    SSL_CERT_FILE = caBundle; # OpenSSL/LibreSSL: openssl, python3 ssl
    NIX_SSL_CERT_FILE = caBundle; # nix-built curl, git, certifi; nix client
    CURL_CA_BUNDLE = caBundle; # /usr/bin/curl and nix curl
    GIT_SSL_CAINFO = caBundle; # /usr/bin/git and nix git
    REQUESTS_CA_BUNDLE = caBundle; # python requests
    PIP_CERT = caBundle; # /usr/bin/pip3 (Python 3.9, cannot run fixed pip 26.2.2)
  };
}
