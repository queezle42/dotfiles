{ pkgs, ... }:

{
  imports = [
    ./desktop.nix
    ./dev.nix
    #./vscode.nix
  ];

  queezle.emacs.enable = true;

  environment.systemPackages = with pkgs; [
    # password manager
    keepassxc

    # calculator
    qalculate-gtk

    # spaced repetition software
    anki-bin

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

    ### CLI
    # Search unicode glyphs
    unipicker
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

