{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  packages = [
    pkgs.swift
    pkgs.swiftpm
    pkgs.apple-sdk_14
  ];

  SDKROOT = "${pkgs.apple-sdk_14}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk";
}
