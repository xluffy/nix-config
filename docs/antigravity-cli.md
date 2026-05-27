# Custom Package: antigravity-cli

This document explains how `antigravity-cli` (a package not available on the official Nixpkgs repository) is packaged, managed, and installed in this Nix / Home Manager configuration.

We use **Option 1 (Custom Binary Derivation)** to wrap the precompiled upstream binaries for both macOS (`aarch64-darwin`) and Linux (`x86_64-linux`).

---

## 1. Structure

1. **Derivation Blueprint**: [`pkgs/antigravity-cli.nix`](file:///Users/quang.van.nguyen/code/me/nix-config/pkgs/antigravity-cli.nix)
   * Fetches the architecture-appropriate release archive directly from GitHub / the release provider.
   * Unpacks the archive and installs the `antigravity-cli` binary to the Nix store under `$out/bin`.
2. **Flake Registration**: [`flake.nix`](file:///Users/quang.van.nguyen/code/me/nix-config/flake.nix)
   * Registers a custom package overlay to make it part of standard `pkgs` (via `final.callPackage`).
3. **User Profile Installation**: [`home-manager/modules/core/cli.nix`](file:///Users/quang.van.nguyen/code/me/nix-config/home-manager/modules/core/cli.nix)
   * Lists `antigravity-cli` inside `home.packages` to ensure it is installed automatically on all hosts managed by Home Manager.

---

## 2. Configuration & Customization

Before using the package, you will need to update the placeholder URLs and compute/replace the SHA256 hashes inside [`pkgs/antigravity-cli.nix`](file:///Users/quang.van.nguyen/code/me/nix-config/pkgs/antigravity-cli.nix).

### Step A: Compute the SHA256 hashes
Run the following commands to fetch the correct archive checksums for your systems:

```bash
# Get the hash for macOS (aarch64-darwin)
nix-prefetch-url --type sha256 "https://github.com/example/antigravity-cli/releases/download/v1.0.0/antigravity-cli-darwin-arm64.tar.gz"

# Get the hash for Linux (x86_64-linux)
nix-prefetch-url --type sha256 "https://github.com/example/antigravity-cli/releases/download/v1.0.0/antigravity-cli-linux-amd64.tar.gz"
```

### Step B: Update `pkgs/antigravity-cli.nix`
Open [`pkgs/antigravity-cli.nix`](file:///Users/quang.van.nguyen/code/me/nix-config/pkgs/antigravity-cli.nix) and update:
1. `version`: Change to your target version (e.g. `1.0.0`).
2. `url`: Set the URL pattern to the actual release asset hosting URL.
3. `hash`: Replace the `hash = if system == "aarch64-darwin" then ...` statements with the output hashes from Step A.

---

## 3. Rebuilding the Environment

Once the hashes and URLs are updated, rebuild your configuration to install the package:

### For macOS
```bash
just build-darwin # Or your custom rebuild script/command (e.g., home-manager switch --flake .#...)
```

### For Linux
```bash
just build-linux  # Or home-manager switch --flake .#...
```

To verify the installation:
```bash
which antigravity-cli
antigravity-cli --version
```
