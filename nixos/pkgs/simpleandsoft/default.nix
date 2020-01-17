{ pkgs ? import <nixpkgs> {} }:
{
  simpleandsoft = pkgs.callPackage ./simpleandsoft.nix {};
}