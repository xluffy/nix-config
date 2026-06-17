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
    # Shared config for nixpkgs imports
    nixpkgsConfig = {
      config.allowUnfree = true;
      config.permittedInsecurePackages = [
        "openssl-1.1.1w"
      ];
    };

    overlays = import ./overlays;

    mkHomeConfig = {
      system,
      username,
      homeDirectory ? null,
      hasGUI ? true,
      extraModules ? [],
    }: let
      pkgsUnstable = import nixpkgs-unstable (nixpkgsConfig
        // {
          inherit system;
        });
      pkgs = import nixpkgs (nixpkgsConfig
        // {
          inherit system;
          overlays = [
            (overlays.additionsUnstable pkgsUnstable)
          ];
        });
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
        modules =
          [
            ./home-manager/home.nix
            nix-index-database.homeModules.nix-index
            agenix.homeManagerModules.default
            {
              home = {
                inherit username;
                homeDirectory = resolvedHomeDir;
              };
            }
          ]
          ++ extraModules;
        extraSpecialArgs = {
          pkgs-unstable = pkgsUnstable;
          llm-agents = llm-agents.packages.${system};
          agenix-cli = agenix.packages.${system}.default;
          inherit hasGUI;
        };
      };

    # Helper to apply overlays for standalone nixpkgs access
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-darwin"
      "x86_64-linux"
    ];
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
              host = "31"; # Red
              user = "38;5;214"; # Orange username
            };
            custom.ssh.identityFile = "~/.ssh/id_ed25519";
          }
        ];
      };
    };

    # Custom packages; accessible via 'nix build .#kage', 'nix shell .#kage', etc
    packages = forAllSystems (
      system:
        import ./pkgs {
          pkgs = import nixpkgs (nixpkgsConfig // {inherit system;});
          pkgsUnstable = import nixpkgs-unstable (nixpkgsConfig // {inherit system;});
        }
    );

    # Custom overlays; consumers can import these
    inherit overlays;

    devShells = forAllSystems (
      system: let
        pkgs = import nixpkgs (nixpkgsConfig // {inherit system;});
      in {
        default = import ./shell.nix {inherit pkgs;};
      }
    );
  };
}
