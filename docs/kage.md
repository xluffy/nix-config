# kage

[kage](https://github.com/tamnd/kage) — shadow any website for offline viewing, with JavaScript stripped out.

## Quick reference

```
# Build standalone
nix build .#kage

# Use in home-manager (already wired in cli.nix)
pkgs.kage

# Run tests
bats tests/pkgs.bats
```

## Files

| File | Purpose |
|---|---|
| `pkgs/kage.nix` | `buildGoModule` derivation (v0.3.3) |
| `pkgs/default.nix` | Package registry — maps `kage` to `callPackage ./kage.nix` |
| `overlays/default.nix` | `additions` / `additionsUnstable` overlays |
| `tests/pkgs.bats` | Evaluation tests (11 cases) |
| `flake.nix` | Wires `additionsUnstable` overlay with `pkgsUnstable` |

## How it works

### Go version selection

kage requires `go >= 1.26.4`, but nixpkgs channels top out at 1.26.3 (unstable) and 1.25.5 (stable). The derivation patches `go.mod` down by one patch version and builds with the closest available Go:

```nix
# pkgs/default.nix
kage = pkgs.callPackage ./kage.nix {
  go =
    if pkgsUnstable ? go_1_26    # 1.26.3 from unstable (preferred)
    then pkgsUnstable.go_1_26
    else pkgs.go_1_25;           # 1.25.5 fallback if no unstable
};
```

The `pkgsUnstable` parameter flows through the overlay:

```nix
# flake.nix — in mkHomeConfig
pkgsUnstable = import nixpkgs-unstable (nixpkgsConfig // { inherit system; });
pkgs = import nixpkgs (nixpkgsConfig // {
  inherit system;
  overlays = [ (overlays.additionsUnstable pkgsUnstable) ];
});
```

```nix
# overlays/default.nix
additionsUnstable = pkgsUnstable: final: _prev:
  import ../pkgs { pkgs = final; inherit pkgsUnstable; };
```

### go.mod patch

The `postPatch` in `pkgs/kage.nix` changes `go 1.26.4` → `go 1.26.3`. This is safe because:

- kage has no 1.26.4-specific language features
- Go module graph pruning rules are identical within 1.26.x
- `go mod tidy` is not needed — go.sum format stays the same

## Adding a new custom package

1. Create `pkgs/new-pkg.nix` with your `callPackage`-compatible derivation
2. Register it in `pkgs/default.nix`:
   ```nix
   new-pkg = pkgs.callPackage ./new-pkg.nix { };
   ```
3. Add a test in `tests/pkgs.bats`:
   ```bash
   @test "packages.new-pkg resolves" {
     run nix eval --json "path:${FLAKE}#packages.aarch64-darwin.new-pkg.name"
     [ "$status" -eq 0 ]
   }
   ```
4. Run `just check` to verify evaluation and tests

## When Go 1.26.4 becomes available

Once nixpkgs-unstable ships `go >= 1.26.4`:

**1. Remove the postPatch from `pkgs/kage.nix`:**

```nix
# Delete this entire block:
  postPatch = ''
    substituteInPlace go.mod --replace-fail "go 1.26.4" "go 1.26.3"
  '';
```

**2. Simplify the go selection in `pkgs/default.nix`:**

```nix
kage = pkgs.callPackage ./kage.nix {
  go = pkgsUnstable.go_1_26;
};
```

**3. Recompute `vendorHash`** (likely unchanged, but verify):

```bash
just switch
# If hash mismatch, copy the reported hash into pkgs/kage.nix
```

**4. Un-skip the guard-rail test in `tests/pkgs.bats`:**

```bash
# Remove the "skip" line from the WORKAROUND test — it will then
# fail, reminding you to apply the steps above.
```

## Tests

```bash
bats tests/pkgs.bats
```

Covers: package resolution on both systems, Go version selection, overlay wiring, home-manager integration, and meta correctness. The `WORKAROUND` test is skipped by default — un-skip it when Go 1.26.4 lands.
