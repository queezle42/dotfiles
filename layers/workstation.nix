{ pkgs, ... }:

{
  imports = [
    ./desktop.nix
    ./dev.nix
    #./vscode.nix
  ];

  environment.systemPackages = with pkgs; [
    # password manager
    keepassxc

    # messaging
    tdesktop
    mumble

    # music
    spotify
    sublime-music

    # books
    cozy
    calibre

    # content creation
    gimp
    godot

    # admin stuff
    virtmanager
  ];


  users.users.adobe = {
    isNormalUser = true;
    uid = 1202;
    passwordFile = "/etc/secrets/passwords/jens";
    extraGroups = [
    ];
    packages = [
      #pkgs.adobe-reader
    ];
  };

}

