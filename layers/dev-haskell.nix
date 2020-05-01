{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    stack
    haskell-ide-engine
    ormolu
    haskellPackages.hoogle
    ghcid
  ];
}
