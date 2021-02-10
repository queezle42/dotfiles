{ ... }:

{
  imports = [
    #./loginctl-linger.nix
    ./dotfiles.nix
    ./greetd.nix
    ./he-dns.nix
    ./kea.nix
    #./webserver.nix
  ];
}
