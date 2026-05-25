{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "antigravity-cli";
  version = "1.0.0"; # Replace with the target version

  src = let
    inherit (pkgs.stdenv.hostPlatform) system;
    
    # Map Nix system strings to target platform names
    # Update these values to match the actual naming convention of the release assets
    platform = if system == "aarch64-darwin" then "darwin-arm64"
               else if system == "x86_64-linux" then "linux-amd64"
               else throw "Unsupported system architecture: ${system}";

    # Replace with the actual hashes of the binary archives.
    # You can get the hash using:
    #   nix-prefetch-url --type sha256 <url>
    # and then formatting it as a SRI hash or base32.
    hash = if system == "aarch64-darwin" then "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
           else "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";
  in pkgs.fetchurl {
    url = "https://github.com/example/antigravity-cli/releases/download/v${version}/antigravity-cli-${platform}.tar.gz";
    inherit hash;
  };

  # Source root is current directory as we unpack the archive
  sourceRoot = ".";

  # Install phase maps the unpacked binary to $out/bin
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    # Adjust this copy command if the binary name inside the archive is different
    if [ -f "antigravity-cli" ]; then
      cp antigravity-cli $out/bin/
    else
      # Fallback if the archive unpacks to a different structure
      find . -type f -name "antigravity-cli" -exec cp {} $out/bin/ \;
    fi
    chmod +x $out/bin/antigravity-cli

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Command-line tool for Antigravity AI coding assistant";
    homepage = "https://github.com/example/antigravity-cli";
    license = licenses.mit; # Adjust to the correct license
    platforms = [ "aarch64-darwin" "x86_64-linux" ];
    mainProgram = "antigravity-cli";
  };
}
