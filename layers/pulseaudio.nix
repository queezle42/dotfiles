{ pkgs, ... }:
{
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    systemWide = true;
    daemon.config = {
      "remixing-produce-lfe" = "yes";
      "remixing-consume-lfe" = "yes";
    };
  };
  users.groups.pulse-access = {};

  environment.systemPackages = with pkgs; [
    pulsemixer
  ];

  # workaround for https://github.com/NixOS/nixpkgs/issues/114399
  system.activationScripts.fix-pulse-permissions = ''
    chmod 755 /run/pulse
  '';


  # Focusrite Scarlett 2i4
  # Sample rate switching (e.g. when starting mumble) results in weird glitches; stereo profile can't be applied.
  # It has to be manually configured instead.
  services.udev.extraRules = ''
    ENV{ID_VENDOR_ID}=="1235", ENV{ID_MODEL_ID}=="8200", ENV{PULSE_IGNORE}="1"
  '';
}
