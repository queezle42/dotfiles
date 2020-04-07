{ lib, config, ... }: pkgs:

with pkgs;

let
  newpkgs = rec {
    # Import packages defined here
    # e.g.:
    #mypkg = haskell.packages.ghc865.callPackage ./mypkg { };
    dotnet-sdk = callPackage ./dotnet-sdk { };
    haskell-ide-engine = (import ./haskell-ide-engine { inherit pkgs; });
    neovim = import ./neovim { inherit pkgs; };
    nginx-sso = callPackage ./nginx-sso {};
    simpleandsoft = (import ./simpleandsoft { inherit pkgs; }).simpleandsoft;
    neatvnc = callPackage ./neatvnc/neatvnc.nix {};
    wayvnc = callPackage ./wayvnc/wayvnc.nix {};

    haskell = pkgs.haskell // {
      packageOverrides = self: super: {
        qbar = self.callPackage ./qbar {};
      };
    };
    mumble-git = (mumble.overrideAttrs (attrs: {
      src = pkgs.fetchFromGitHub {
        owner = "mumble-voip";
        repo = "mumble";
        rev = "f8ee53688353c8f5e1650504a961ee582ac16668";
        sha256 = "1ifax91w5d0311sx8nkflfih61ccn0vcghyl1j6r8qn96zvz5dzq";
        fetchSubmodules = true;
      };
    }));

    qbar = haskellPackages.qbar;
  };

in newpkgs
