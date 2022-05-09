{ pkgs, ... }:

{
  documentation.dev.enable = true;

  environment.systemPackages = with pkgs; [
    man-pages
    posix_man_pages

    # Dictionary (command `trans`)
    translate-shell

    gdb
  ];

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  home-manager.users.jens.xdg.configFile."direnv/direnvrc" = {
    source = "${pkgs.nix-direnv}/share/nix-direnv";
  };

  users.users = {
    jens = {
      packages = with pkgs; [ direnv ];
    };

    dev = {
      uid = 1300;
      isNormalUser = true;
      packages = with pkgs; [
      ];
    };
  };
}
