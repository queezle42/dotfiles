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

    # Dictionary (command `trans`)
    translate-shell

    posix_man_pages
  ];

  users.users.jens = {
    packages = with pkgs; [ direnv ];
  };

}

