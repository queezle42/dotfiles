{ pkgs, ... }:

{
  imports = [
    ./desktop.nix
    ./vscode.nix
  ];

  documentation.dev.enable = true;

  environment.systemPackages = with pkgs; [
    virtmanager
    keepassxc

    tdesktop
    spotify
    gimp

    posix_man_pages
  ];

  users.users.jens = {
    packages = with pkgs; [ direnv ];
  };

}

