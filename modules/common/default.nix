inputs@{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.queezle.common;
in
{
  options = {
    queezle.common = {
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
    home-manager.users."${cfg.user}" = {
    };
  };
}
