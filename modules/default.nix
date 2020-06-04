{ ... }:

{
  imports = [
    #./loginctl-linger.nix
    ./dotfiles.nix
    ./heDns.nix
    ./kea.nix
    #./webserver.nix
  ];
}
