# Basic desktop functionality (window manager, terminal emulator, browser and a few utilities)
{ pkgs, lib, ... }:

{
  imports = [
    ./base.nix
  ];

  queezle.desktop.enable = true;
}
