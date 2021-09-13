{ ... }:

{
  imports = [
    #./loginctl-linger.nix
    ./sway
    ./dotfiles.nix
    ./he-dns.nix
    ./kea.nix
    ./spotifyd.nix
    ./terminal.nix
    #./webserver.nix
  ];
}
