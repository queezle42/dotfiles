{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    stack
    haskell-language-server
    haskellPackages.hoogle
    ghcid
    haskellPackages.threadscope
  ];
}
