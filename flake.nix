{
  description = "Home manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, nix-index-database, ... }:
    let
      system = "aarch64-darwin";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.permittedInsecurePackages = [
          "openssl-1.1.1w"
        ];
      };
      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
        config.permittedInsecurePackages = [
          "openssl-1.1.1w"
        ];
      };

      generateHomeConfig = username: home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        modules = [
          ./home-manager/home.nix
          nix-index-database.hmModules.nix-index
        ];
        extraSpecialArgs = {
          pkgs-unstable = pkgsUnstable;
        };
      };
    in
    {
      homeConfigurations = {
        "quanggg@xluffys-MacBook-Air.local" = generateHomeConfig "quanggg";
        "quanggg@xluffys-mini.local" = generateHomeConfig "quanggg";
      };

      devShells = {
        aarch64-darwin.default = import ./shell.nix {
          pkgs = pkgs;
        };
      };
    };
}
