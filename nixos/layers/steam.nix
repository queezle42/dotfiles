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
    passwordFile = "/secrets/passwords/steam";
    extraGroups = [ "audio" "input" ];
    packages = [
      customSteam
      pkgs.steam-run-native
    ];
  };
}