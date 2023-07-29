inputs@{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.queezle.sway;
  swaylockWithIdle = pkgs.writeScriptBin "swaylock-with-idle" ''
    #!/usr/bin/env zsh

    trap 'qctl set /g815/idle false; swaymsg "output * dpms on"' EXIT INT HUP TERM

    swayidle -w \
      timeout 10 'q system idle; swaymsg "output * dpms off"' \
      resume 'q system not-idle; swaymsg "output * dpms on"' \
      &

    swaylock $@

    kill %1
  '';
  lock = pkgs.writeScriptBin "lock" ''
  '';

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
        default = config.queezle.common.user;
      };
      autoLockBeforeSuspend = mkOption {
        type = types.bool;
        default = true;
      };
      wallpaper = mkOption {
        type = types.path;
        default = pkgs.requireFile rec {
          name = "background.png";
          url = "<no-url-available>";
          sha256 = "9df437c4ba4dc845e10f57e1bbbbee6a4139329f36dbdd92c98a8fb0b45b1c22";
        };
      };
      lockscreen = mkOption {
        type = types.path;
        #default = pkgs.requireFile rec {
        #  name = "retrowave.png";
        #  url = "'undefined'";
        #  sha256 = "b41a116c40cc294b6367fa4828110321156addb1d41e072fbd80cdf8748b35c3";
        #};
        #default = pkgs.requireFile rec {
        #  name = "the-great-retro-wave-halfsize.jpg";
        #  url = "<no-url-available>";
        #  sha256 = "6e6a699b6ca2c207b3df1b97d97487cee9c7fa4d8f8f09f8403991c758ec192c";
        #};
        default = pkgs.requireFile rec {
          name = "the-great-vapor-wave.jpg";
          url = "<no-url-available>";
          sha256 = "4dad9ecf80dc8c5a4d3ef253e111338be35d762cbf6a432d0db47402831e6b9b";
        };
      };
    };

  };
  config = mkIf cfg.enable {
    queezle.terminal.enable = true;
    queezle.desktop.launcher.enable = true;
    queezle.desktop.launcher.dmenu = true;

    home-manager.users."${cfg.user}".xdg.configFile."sway/config" = {
      source = import ./config.nix inputs;
    };

    environment.systemPackages = with pkgs; [
      swaylockWithIdle

      # screenshot utilities
      grim
      slurp

      # debug/development utilities
      wev # similar to xev, but for wayland

      # soft dependencies
      zsh
      mako
      rofi
      qt5.qtwayland
      acpilight
      gammastep
      kanshi
      libnotify
      wl-clipboard
      ddcutil
      pamixer

      # qbar block dependencies
      qbar
      python3
      acpi
      perl
      sysstat
      zsh
      bash
      lm_sensors
      jq
    ];

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-gtk
      ];
    };

    programs.sway = {
      enable = true;
      extraPackages = with pkgs; [ swaylock swayidle xwayland kitty cool-retro-term xorg.xrdb slurp ];

      # gsettings schemas
      wrapperFeatures.gtk = true;

      # QT_QPA_PLATFORM=wayland requires qt5.qtwayland in systemPackages
      extraSessionCommands = ''
        # BEGIN programs.sway.extraSessionCommands

        # Nesting detection, used to make primary session on tty1 available to ssh sessions
        if [[ -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" ]]
        then
          export NESTED_SWAY=1
        fi

        export XDG_SESSION_TYPE=wayland
        export XDG_CURRENT_DESKTOP=sway

        export SDL_VIDEODRIVER=wayland

        export MOZ_ENABLE_WAYLAND=1

        # gsettings is missing documentation, can't get it to integrate with NixOS+sway
        # I hope this method stays functional
        export GTK_THEME=Adwaita:dark

        # Creates problems with OBS
        #export QT_QPA_PLATFORM=wayland

        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"

        export QT_STYLE_OVERRIDE=adwaita-dark

        # END programs.sway.extraSessionCommands
      '';
    };
  };
}
