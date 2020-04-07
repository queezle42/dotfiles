{ pkgs ? import <nixpkgs> {} }:

{
  neatvnc = pkgs.callPackage ./neatvnc.nix {};
}