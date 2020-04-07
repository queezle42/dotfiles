{ pkgs, ... }:

{
  imports = [
    ./desktop.nix
    ./vscode.nix
  ];

  environment.systemPackages = with pkgs; [
    virtmanager
    keepassxc

    tdesktop
    spotify
    gimp
  ];

  users.users.jens = {
    packages = with pkgs; [ direnv ];
  };

}

