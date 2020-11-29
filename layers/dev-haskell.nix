{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cabal-install
    stack
    haskell-language-server
    haskellPackages.hoogle
    ghcid
    #haskellPackages.threadscope
  ];
}
