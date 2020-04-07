{ pkgs ? import <nixpkgs> {} }:

let
  neatvnc = pkgs.callPackage ../neatvnc/neatvnc.nix {};
in
{
  wayvnc = pkgs.callPackage ./wayvnc.nix { inherit neatvnc; };
}