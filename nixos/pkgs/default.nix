{ lib, config, ... }: pkgs:

with pkgs;

let
  newpkgs = rec {
    # Import packages defined here
    # e.g.:
    #mypkg = haskell.packages.ghc865.callPackage ./mypkg { };
    qbar = haskellPackages.callPackage ./qbar { };
    dotnet-sdk = self.callPackage ./dotnet-sdk { };
  };

in newpkgs
