{ ... }:

{
  imports = [
    ./audio/pipewire.nix
    ./audio/pulseaudio.nix
    ./common
    ./desktop
    ./desktop/greeter.nix
    ./desktop/launcher.nix
    ./distraction-blocker
    ./dyndns/desec.nix
    ./dyndns/he-dns.nix
    ./firewall
    ./git
    ./jellyfin/server.nix
    ./kea.nix
    ./minio
    ./mobile-nixos-bootloader.nix
    ./monitoring/grafana-agent.nix
    ./monitoring/monitoring-server.nix
    ./project-manager
    ./rhasspy
    ./spotifyd.nix
    ./sway
    ./sync
    ./terminal.nix
    ./usbuirt.nix
    ./tailscale

    # server
    #./webserver.nix

    #./emacs
  ];
}
