{ pkgs, ... }:

{
  documentation.dev.enable = true;

  environment.systemPackages = with pkgs; [
    man-pages
    man-pages-posix

    nil
    alejandra

    # Dictionary (command `trans`)
    translate-shell

    gdb

    github-cli
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
