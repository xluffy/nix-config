{
  description = "home manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: {
    homeConfigurations = {
      "quanggg@xluffys-MacBook-Air.local" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
        };
        modules = [ ./home-manager/home.nix ];
      };

      "quanggg@xluffys-mini.local" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "aarch64-darwin"; };

        modules = [ ./home-manager/home.nix ];
      };
    };

    devShells = {
      aarch64-darwin.default = import ./shell.nix {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
        };
      };
    };
  };
}
