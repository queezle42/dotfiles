{ lib, config, ... }: pkgs:

with pkgs;

let
  newpkgs = rec {
    # Import packages defined here
    # e.g.:
    #mypkg = haskell.packages.ghc865.callPackage ./mypkg { };
    dotnet-sdk = callPackage ./dotnet-sdk { };
    haskell-ide-engine = (import ./haskell-ide-engine { inherit pkgs; }).haskell-ide-engine;
    neovim = (import ./neovim {inherit pkgs; }).neovim;
  };

in newpkgs
