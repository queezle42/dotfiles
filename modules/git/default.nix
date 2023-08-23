inputs@{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.queezle.git;
in
{
  options = {
    queezle.git = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      user = mkOption {
        type = types.str;
        default = "jens";
      };
    };

  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.git
      pkgs.gitAndTools.tig
      pkgs.git-revise
      pkgs.lazygit
    ];
    home-manager.users."${cfg.user}" = {
      home = {
        file.".tigrc".source = ./files/tigrc;
      };
      xdg.configFile = {
        "git/config".source = import ./config.nix inputs;

        # .git/ is added to global gitignore so `rg` and similar programs ignore it when working in gitignore mode while showing hidden files.
        "git/ignore".source = pkgs.writeText "git-config" ''
          .git/
        '';

        "git/commit-template".source = pkgs.writeText "git-commit-template" ''


          #Co-authored-by: Jan Beinke <git@janbeinke.com>
          #Co-authored-by: J. Konrad Tegtmeier-Rottach <jktr@0x16.de>
        '';
      };
    };
  };
}
