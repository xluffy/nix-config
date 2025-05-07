# Setup with Nix on macOS

To install Nix on macOs as a multi-user installtion, run this command:

```bash
bash <(curl -L https://nixos.org/nix/install) --daemon
```

If you want to configure the OS via Nix, you can install Nix Darwin. For me, I just want to use Nix for managing package and user environment config in home directory

To manage them, I will use Home Manager. Home Manager can be configured as a user in ~/.config/nixpkgs/home.nix or as a module inside configuration.


```
home-manager -f "~/code/me/nix-config/home.nix"
```

https://mynixos.com/home-manager/options/programs.bash
