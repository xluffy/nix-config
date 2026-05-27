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

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    llm-agents,
    home-manager,
    nix-index-database,
    agenix,
    ...
  }: let
    mkHomeConfig = {
      system,
      username,
      homeDirectory ? null,
      hasGUI ? true,
      extraModules ? [ ],
    }: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.permittedInsecurePackages = [
          "openssl-1.1.1w"
        ];
        overlays = [
          (final: prev: {
            antigravity-cli = final.callPackage ./pkgs/antigravity-cli.nix {};
          })
        ];
      };
      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
        config.permittedInsecurePackages = [
          "openssl-1.1.1w"
        ];
      };
      resolvedHomeDir =
        if homeDirectory != null
        then homeDirectory
        else
          (
            if pkgs.stdenv.isDarwin
            then "/Users/${username}"
            else "/home/${username}"
          );
    in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home-manager/home.nix
          nix-index-database.homeModules.nix-index
          agenix.homeManagerModules.default
          {
            home = {
              inherit username;
              homeDirectory = resolvedHomeDir;
            };
          }
        ] ++ extraModules;
        extraSpecialArgs = {
          pkgs-unstable = pkgsUnstable;
          llm-agents = llm-agents.packages.${system};
          agenix-cli = agenix.packages.${system}.default;
          inherit hasGUI;
        };
      };
  in {
    homeConfigurations = {
      "quang.van.nguyen@Nguyens-MacBook-Pro.local" = mkHomeConfig {
        system = "aarch64-darwin";
        username = "quang.van.nguyen";
        hasGUI = true;
        extraModules = [
          {
            custom.shell.promptColor = {
              primary = "33";
              host = "34";
              user = "38;5;46";
            };
            custom.ssh.identityFile = "~/.ssh/ssh-ed25519:quang@2meo.com.pub";
          }
        ];
      };
      "xluffy-zzbot@elbaf-sky-n100" = mkHomeConfig {
        system = "x86_64-linux";
        username = "xluffy-zzbot";
        hasGUI = false;
        extraModules = [
          {
            custom.shell.promptColor = {
              primary = "33"; # Yellow
              host = "31";    # Red
              user = "38;5;214"; # Orange username
            };
            custom.ssh.identityFile = "~/.ssh/id_ed25519";
          }
        ];
      };
    };

    devShells = {
      aarch64-darwin.default = import ./shell.nix {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };
      };
      x86_64-linux.default = import ./shell.nix {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
    };
  };
}
