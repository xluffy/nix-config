{
  description = "Home manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    llm-agents.url = "github:numtide/llm-agents.nix";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    llm-agents,
    home-manager,
    nix-index-database,
    ...
  }: let
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

    homeConfiguration = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./home-manager/home.nix
        nix-index-database.homeModules.nix-index
      ];
      extraSpecialArgs = {
        pkgs-unstable = pkgsUnstable;
        llm-agents = llm-agents.packages.${system};
      };
    };
  in {
    homeConfigurations = {
      "quang.van.nguyen@Nguyens-MacBook-Pro.local" = homeConfiguration;
    };

    devShells = {
      aarch64-darwin.default = import ./shell.nix {
        inherit pkgs;
      };
    };
  };
}
