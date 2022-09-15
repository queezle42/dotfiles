{ ... }:

{
  imports = [
    ./desktop
    ./desktop/launcher.nix
    ./distraction-blocker
    ./emacs
    ./git
    ./sway
    ./project-manager
    ./he-dns.nix
    ./kea.nix
    ./mobile-nixos-bootloader.nix
    ./spotifyd.nix
    ./terminal.nix
    ./tts

    # server
    #./webserver.nix
  ];
}
