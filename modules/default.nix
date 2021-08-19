{ ... }:

{
  imports = [
    #./loginctl-linger.nix
    ./sway
    ./dotfiles.nix
    ./he-dns.nix
    ./kea.nix
    ./terminal.nix
    #./webserver.nix
  ];
}
