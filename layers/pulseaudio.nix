{ pkgs, ... }:
{
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    systemWide = true;
  };
  users.groups.pulse-access = {};

  environment.systemPackages = with pkgs; [
    pulsemixer
  ];

  # workaround for https://github.com/NixOS/nixpkgs/issues/114399
  system.activationScripts.fix-pulse-permissions = ''
    chmod 755 /run/pulse
  '';
}
