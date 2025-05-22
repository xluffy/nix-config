# Setup with Nix on macOS

To install Nix on macOS as a multi-user installtion, run this command:

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon --yes
```

If you want to configure the OS via Nix, you can install Nix Darwin. For me, I just want to use Nix for managing package and user environment config in home directory

When using `nix`, we still need some tools before using home-manager, so take a look at `shell.nix` — it's a bootstrap script to set up those tools.

👆 This adds tools to your shell environment.

- `nix`: gives you the nix CLI.
- `home-manager`: useful if you want to run `home-manager` commands.
- `git`: version control.

They'll be available whenever you run `nix develop` or `nix-shell`.

- You can run `nix develop` (flake)
- Or `nix-shell` (legacy)

https://mynixos.com/home-manager/options/programs.bash
https://github.com/Misterio77/nix-starter-configs/blob/main/README.md
https://home-manager-options.extranix.com/?query=git.&release=release-24.11
https://unmovedcentre.com/posts/secrets-management/#inputting-nix-secrets-to-nix-config
https://home-manager-options.extranix.com/

## OpenSSL

```bash
> openssl version -a
```

## devenv

```bash
> devenv init

> cat devenv.nix
{ pkgs, ... }:

{
  packages = [
    # pkgs.openssl_1_1
  ];

  languages.python.enable = true;
  languages.python.version = "3.9.21";
  languages.python.venv.enable = true;
  languages.python.poetry.enable = true;
  languages.python.poetry.install.enable = true;
}
```

## Specific package version

https://mplanchard.com/posts/installing-a-specific-version-of-a-package-with-nix.html

```nix
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Some particular revision for installing fd
    nixpkgs-fd.url = "github:nixos/nixpkgs/bf972dc380f36a3bf83db052380e55f0eaa7dcb6";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

```

```nix
  outputs = { nixpkgs, nixpkgs-unstable, home-manager, nixpkgs-fd, ... }:
  {
    #...
  };
```

## NixOS vs home-manager

```nix
# configuration.nix
{config, pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    rsync
  ];

  services.nginx = {
    enable = true;
  };
}
```

```nix
# home.nix
{config, pkgs, ...}: {
  home.file.foo.text = "bar";

  programs.fish = {
    enable = true;
  };
}
```

##  How to locate nix packages with specific files

[nix-index](https://github.com/nix-community/nix-index) is a tool to quickly locate the package providing a certain file in nixpkgs. But you need to generate a database locally and run this command to search

```bash
# create locally database
> nix run github:nix-community/nix-index#nix-index

# query
> nix run github:nix-community/nix-index#nix-locate -- bin/ip
```

In another side, [nix-index-database](https://github.com/nix-community/nix-index-database) provides pre-generated databases if you don't want to generate a database locally.


```bash
> nix run github:nix-community/nix-index-database bin/ip
```
