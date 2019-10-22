# This is the entry point for my NixOS configuration.
{ layers ? [] }:
{ lib, config, pkgs, ... }:

let
  layerImports = map (l: ./layers + "/${l}.nix") layers;
in
{
  imports = [
    ./modules
  ] ++ layerImports;

  nixpkgs.config = {
    packageOverrides = ( import ./pkgs ) { inherit lib config; } ;
  };
}
