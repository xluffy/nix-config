# Setup with Nix on macOS

To install Nix on macOS as a multi-user installtion, run this command:

```bash
bash <(curl -L https://nixos.org/nix/install) --daemon
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
