{ pkgs ? import <nixpkgs> {}, ... }:

pkgs.mkShell {
  packages = with pkgs; [python310Full python310Packages.setuptools ];
}
