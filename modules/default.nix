{ ... }:

{
  imports = [
    ./desktop
    ./desktop/launcher.nix
    ./distraction-blocker
    ./emacs
    ./sway
    ./project-manager
    ./dotfiles.nix
    ./he-dns.nix
    ./kea.nix
    ./mobile-nixos-bootloader.nix
    ./spotifyd.nix
    ./terminal.nix

    # server
    #./webserver.nix
  ];
}
