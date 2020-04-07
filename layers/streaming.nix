{ pkgs, ... }:
{
  imports = [
    ./desktop.nix
  ];

  environment.systemPackages = with pkgs; [
    obs-studio
    obs-wlrobs
  ];
}
