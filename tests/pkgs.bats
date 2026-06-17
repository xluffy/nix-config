# pkgs.bats — Test suite for custom packages (pkgs/, overlays/)
#
# Verifies package resolution, Go version selection, and overlay wiring.
# These are evaluation-only tests — no builds, no network.

setup() {
  FLAKE="${BATS_TEST_DIRNAME}/.."
}

# ---------------------------------------------------------------------------
# Flake package output
# ---------------------------------------------------------------------------

@test "packages.kage resolves on aarch64-darwin" {
  run nix eval --json "path:${FLAKE}#packages.aarch64-darwin.kage.name"
  [ "$status" -eq 0 ]
  [ "$output" = '"kage-0.3.4"' ]
}

@test "packages.kage resolves on x86_64-linux" {
  run nix eval --json "path:${FLAKE}#packages.x86_64-linux.kage.name"
  [ "$status" -eq 0 ]
  [ "$output" = '"kage-0.3.4"' ]
}

@test "packages.kage uses go_1_26 from unstable" {
  run nix eval --json "path:${FLAKE}#packages.aarch64-darwin.kage.go.version"
  [ "$status" -eq 0 ]
  # Should be 1.26.x from nixpkgs-unstable
  [[ "$output" =~ 1\.26\. ]]
}

@test "packages.kage is a buildGoModule derivation" {
  # Verify it's a proper Go package by checking the builder
  run nix eval --json "path:${FLAKE}#packages.aarch64-darwin.kage.pname"
  [ "$status" -eq 0 ]
  [ "$output" = '"kage"' ]
}

# ---------------------------------------------------------------------------
# Overlay wiring
# ---------------------------------------------------------------------------

@test "overlays output exposes additions" {
  run nix eval --json "path:${FLAKE}#overlays.additions" --apply 'x: builtins.typeOf x'
  [ "$status" -eq 0 ]
  [ "$output" = '"lambda"' ]
}

@test "overlays output exposes additionsUnstable" {
  run nix eval --json "path:${FLAKE}#overlays.additionsUnstable" --apply 'x: builtins.typeOf x'
  [ "$status" -eq 0 ]
  [ "$output" = '"lambda"' ]
}

@test "overlay additionsUnstable makes kage available in pkgs" {
  run nix eval --impure --expr '
    let
      flake = builtins.getFlake "'"${FLAKE}"'";
      pkgs = flake.inputs.nixpkgs.legacyPackages.aarch64-darwin;
      pkgsUnstable = flake.inputs.nixpkgs-unstable.legacyPackages.aarch64-darwin;
      pkgsWithKage = pkgs.extend (flake.outputs.overlays.additionsUnstable pkgsUnstable);
    in
      pkgsWithKage.kage.name
  '
  [ "$status" -eq 0 ]
  [ "$output" = '"kage-0.3.4"' ]
}

@test "overlay additionsUnstable passes unstable Go to kage" {
  run nix eval --impure --expr '
    let
      flake = builtins.getFlake "'"${FLAKE}"'";
      pkgs = flake.inputs.nixpkgs.legacyPackages.aarch64-darwin;
      pkgsUnstable = flake.inputs.nixpkgs-unstable.legacyPackages.aarch64-darwin;
      pkgsWithKage = pkgs.extend (flake.outputs.overlays.additionsUnstable pkgsUnstable);
    in
      pkgsWithKage.kage.go.version
  '
  [ "$status" -eq 0 ]
  [[ "$output" =~ 1\.26\. ]]
}

# ---------------------------------------------------------------------------
# Home-manager integration
# ---------------------------------------------------------------------------

@test "homeConfigurations evaluate with kage available" {
  run nix eval --json "path:${FLAKE}#homeConfigurations.\"quang.van.nguyen@Nguyens-MacBook-Pro.local\".pkgs.kage.name"
  [ "$status" -eq 0 ]
  [ "$output" = '"kage-0.3.4"' ]
}

@test "kage meta is well-formed" {
  run nix eval --json "path:${FLAKE}#packages.aarch64-darwin.kage.meta" \
    --apply 'm: { license = m.license.spdxId or "missing"; mainProgram = m.mainProgram or "missing"; }'
  [ "$status" -eq 0 ]
  [[ "$output" =~ "MIT" ]]
  [[ "$output" =~ "kage" ]]
}

# ---------------------------------------------------------------------------
# Future-proofing: detect when workaround is no longer needed
# ---------------------------------------------------------------------------

@test "WORKAROUND: nixpkgs-unstable go is still < 1.26.4" {
  skip "Remove this test once Go >= 1.26.4 lands in nixpkgs-unstable"
  run nix eval --impure --expr '
    let
      flake = builtins.getFlake "'"${FLAKE}"'";
      goVer = flake.inputs.nixpkgs-unstable.legacyPackages.aarch64-darwin.go_1_26.version;
    in
      builtins.compareVersions goVer "1.26.4"
  '
  [ "$output" -lt 0 ]
}
