{ pkgs ? import <nixpkgs> {}, ... }:

let
jdk = pkgs.jdk21;
gradle= pkgs.gradle.override { java = jdk; };
in
pkgs.mkShell
{
  packages = with pkgs; [python310Full python310Packages.setuptools jdk gradle];
}

