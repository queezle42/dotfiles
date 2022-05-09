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
    home-manager.users."${cfg.user}".xdg.configFile."git/config".source =
      import ./config.nix inputs;
  };
}
