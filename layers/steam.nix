{ lib, pkgs, ... }:

with lib;

let
  customSteam = pkgs.steam.override {
    withPrimus = true;
    extraPkgs = pkgs: with pkgs; [ glxinfo ];
  };

in
{
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  users.users.steam = {
    isNormalUser = true;
    uid = 1100;
    passwordFile = "/etc/secrets/passwords/steam";
    extraGroups = [
      "audio"
      "pulse-access"
    ];
    packages = [
      customSteam
      pkgs.steam-run-native
      pkgs.gamescope
    ];
  };
}
