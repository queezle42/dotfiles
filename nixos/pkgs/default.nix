{ lib, config, ... }: pkgs:

with pkgs;

let
  newpkgs = rec {
    # Import packages defined here
    # e.g.:
    #mypkg = haskell.packages.ghc865.callPackage ./mypkg { };
    dotnet-sdk = callPackage ./dotnet-sdk { };
    neovim = (import ./neovim { inherit pkgs; }).neovim;
    haskell-ide-engine = (import ./haskell-ide-engine { inherit pkgs; });
    nginx-sso = callPackage ./nginx-sso {};
    simpleandsoft = (import ./simpleandsoft { inherit pkgs; }).simpleandsoft;
    neatvnc = callPackage ./neatvnc/neatvnc.nix {};
    wayvnc = callPackage ./wayvnc/wayvnc.nix {};
  };

in newpkgs
