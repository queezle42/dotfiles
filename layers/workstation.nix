{ lib, pkgs, ... }:
with lib;

{
  imports = [
    ./desktop.nix
    ./dev.nix
    #./vscode.nix
  ];

  #queezle.emacs.enable = true;

  # surprisingly slow when used through qemu-binfmt
  documentation.man.generateCaches = mkDefault true;

  programs.adb.enable = true;

  users.users.jens.extraGroups = [ "adbusers" ];

  environment.systemPackages = with pkgs; [
    # web
    firefox

    # office
    libreoffice

    # password manager
    keepassxc
    # `secret-tool` cli
    libsecret

    # notes
    joplin-desktop

    # calculator
    qalculate-gtk

    # spaced repetition software
    anki-bin

    # communication
    tdesktop
    thunderbird
    mumble

    # music
    spotify

    # audio
    sox

    # video
    yt-dlp

    # books
    cozy
    calibre

    # rss reader
    #newsflash

    # content creation
    gimp
    godot

    # admin stuff
    virt-manager

    # QR code scanner
    cobang
    zbar

    ### CLI
    # Search unicode glyphs
    unipicker

    # kerberos
    krb5
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

