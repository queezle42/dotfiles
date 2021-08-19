{ pkgs, ... }:

{
  imports = [
    ./desktop.nix
    #./vscode.nix
  ];

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

