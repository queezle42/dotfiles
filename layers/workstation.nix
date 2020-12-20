{ pkgs, ... }:

{
  imports = [
    ./desktop.nix
    ./vscode.nix
  ];

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  documentation.dev.enable = true;

  environment.systemPackages = with pkgs; [
    virtmanager
    keepassxc

    tdesktop
    spotify
    gimp
    mumble

    # Dictionary (command `trans`)
    translate-shell

    posix_man_pages
  ];

  users.users.jens = {
    packages = with pkgs; [ direnv ];
  };

}

