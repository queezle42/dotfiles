inputs@{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.queezle.desktop;
in
{
  options = {
    queezle.desktop = {
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
    home-manager.users."${cfg.user}".xdg.configFile."foot/foot.ini" = {
      source = import ./config/foot.nix inputs;
    };
  };
}
