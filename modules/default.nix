{ ... }:

{
  imports = [
    #./loginctl-linger.nix
    ./sway
    ./dotfiles.nix
    ./he-dns.nix
    ./kea.nix
    ./mobile-nixos-bootloader.nix
    ./spotifyd.nix
    ./terminal.nix
    #./webserver.nix
  ];
}
