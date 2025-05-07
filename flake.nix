{
  description = "Home manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
      };

      generateHomeConfig = username: home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        modules = [ ./home-manager/home.nix ];
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
