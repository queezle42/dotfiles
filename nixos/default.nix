{ lib, config, pkgs, ... }:

{
  imports = [
    ./modules
  ];

  nixpkgs.config = {
    packageOverrides = ( import ./pkgs ) { inherit lib config; } ;
  };
}
