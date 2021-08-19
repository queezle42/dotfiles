inputs@{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.queezle.sway;
in
{
  options = {
    queezle.sway = {
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
    home-manager.users."${cfg.user}" = { pkgs, ... }: {
      xdg.configFile."sway/config" = {
        source = import ./config.nix inputs;
      };
    };
  };
}
