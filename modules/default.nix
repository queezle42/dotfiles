{ ... }:

{
  imports = [
    #./loginctl-linger.nix
    ./dotfiles.nix
    ./he-dns.nix
    ./kea.nix
    #./webserver.nix
  ];
}
