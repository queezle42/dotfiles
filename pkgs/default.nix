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
    simpleandsoft = import ./simpleandsoft { inherit pkgs; };
    netevent = callPackage ./netevent {};
    g810-led = callPackage ./g810-led {};

    haskell = pkgs.haskell // {
      packageOverrides = self: super: {
        q = self.callPackage ./q {};
        qd = self.callPackage ./qd {};
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

    q = haskellPackages.q;
    qd = haskellPackages.qd;
    qbar = haskellPackages.qbar;
  };

in newpkgs
