{ lib, config, ... }: pkgs:

with pkgs;

let
  newpkgs = rec {
    # Import packages defined here
    # e.g.:
    #mypkg = haskell.packages.ghc865.callPackage ./mypkg { };
  };

in newpkgs
