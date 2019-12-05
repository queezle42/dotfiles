{ pkgs, ... }:

{
  imports = [
    ./desktop.nix
  ];

  environment.systemPackages = with pkgs; [
    virtmanager

    tdesktop
    spotify
    gimp
  ];

  users.users.jens = {
    packages = with pkgs; [ direnv ];
  };

}

