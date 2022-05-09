inputs@{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.queezle.desktop;
  squeekboardConfig = import ./config/squeekboard.nix inputs;
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
    queezle.terminal.enable = true;

    queezle.project-manager.enable = true;

    home-manager.users."${cfg.user}" = {
      home = {
        file.".zprofile".source = ./files/home/zprofile;
        file.".Xresources".source = ./files/home/Xresources;
      };

      xdg = {
        configFile."foot/foot.ini".source = import ./config/foot.nix inputs;
        #configFile."xdg-desktop-portal-wlr/config".source = import ./config/xdg-desktop-portal-wlr.nix inputs;
        configFile."dunst".source = ./files/config/dunst;
        configFile."gammastep".source = ./files/config/gammastep;
        configFile."gtk-3.0".source = ./files/config/gtk-3.0;
        configFile."qbar".source = ./files/config/qbar;
        configFile."swaylock".source = ./files/config/swaylock;

        dataFile."squeekboard/keyboards/terminal/us.yaml".source = squeekboardConfig;
        dataFile."squeekboard/keyboards/terminal/us_wide.yaml".source = squeekboardConfig;
        dataFile."squeekboard/keyboards/us.yaml".source = squeekboardConfig;
        dataFile."squeekboard/keyboards/us_wide.yaml".source = squeekboardConfig;

        dataFile."icons/default/index.theme".source = ./files/data/icons/default/index.theme;

        # TODO: remove after next nixpkgs-pinephone update
        dataFile."squeekboard/keyboards/terminal.yaml".source = squeekboardConfig;
        dataFile."squeekboard/keyboards/terminal_wide.yaml".source = squeekboardConfig;
      };
    };
  };
}
