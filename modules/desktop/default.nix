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
      font.monospace.size = mkOption {
        type = types.float;
        default = 10.5;
      };
      user = mkOption {
        type = types.str;
        default = "jens";
      };
    };
  };
  config = mkIf cfg.enable {
    queezle.sway.enable = true;
    queezle.audio.enable = true;

    queezle.terminal.enable = true;

    queezle.project-manager.enable = true;

    fonts = {
      packages = with pkgs; [
        pragmatapro

        #fira-code
        (nerdfonts.override { fonts = [ "FiraCode" ]; })
      ];
      fontconfig.defaultFonts.monospace = [ "PragmataPro Liga" ];
    };

    services.udisks2.enable = true;
    programs.gnome-disks.enable = true;

    environment.systemPackages = with pkgs; [
      # desktop environment programs
      kitty
      foot
      glxinfo
      wayvnc
      tigervnc
      dfeet
      mpv-queezle
      wdisplays
      squeekboard
      feh
      networkmanagerapplet # Also contains connection editor ui

      # icon theme (required for e.g. `lutris`)
      gnome.adwaita-icon-theme

      # theme (see further down)
      adwaita-qt

      # cursor theme (installed below as `dataFile."icons/default/index.theme"`)
      simpleandsoft
    ];

    programs.dconf.enable = true;

    users = {
      users."${cfg.user}" = {
        packages = with pkgs; [
          q
          chromium
          pavucontrol
          playerctl
          xdg-utils
        ];
        extraGroups = [
          "video"
          "pulse-access"
          "pipewire"
        ];
      };
    };

    home-manager.users."${cfg.user}" = {
      home = {
        file.".zprofile".source = ./files/home/zprofile;
        file.".Xresources".source = ./files/home/Xresources;
      };

      xdg = {
        configFile."foot/foot.ini".source = import ./config/foot.nix inputs;
        configFile."foot/foot-floating.ini".source = import ./config/foot.nix (inputs // { floating = true; });
        configFile."kitty/kitty.conf".source = import ./config/kitty.nix inputs;
        #configFile."xdg-desktop-portal-wlr/config".source = import ./config/xdg-desktop-portal-wlr.nix inputs;
        configFile."dunst".source = ./files/config/dunst;
        configFile."gammastep".source = ./files/config/gammastep;
        configFile."gtk-3.0".source = ./files/config/gtk-3.0;
        configFile."gtk-4.0".source = ./files/config/gtk-3.0;
        configFile."qbar".source = ./files/config/qbar;
        configFile."swaylock".source = ./files/config/swaylock;

        dataFile."squeekboard/keyboards/terminal/us.yaml".source = squeekboardConfig;
        dataFile."squeekboard/keyboards/terminal/us_wide.yaml".source = squeekboardConfig;
        dataFile."squeekboard/keyboards/us.yaml".source = squeekboardConfig;
        dataFile."squeekboard/keyboards/us_wide.yaml".source = squeekboardConfig;

        # Cursor theme
        dataFile."icons/default/index.theme".source = ./files/data/icons/default/index.theme;

        # TODO: remove after next nixpkgs-pinephone update
        dataFile."squeekboard/keyboards/terminal.yaml".source = squeekboardConfig;
        dataFile."squeekboard/keyboards/terminal_wide.yaml".source = squeekboardConfig;
      };

      dconf.settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };

    # QT dark theme (installed to environment.systemPackages)
    environment.etc."xdg/Trolltech.conf".text = ''
      [Qt]
      style=adwaita-dark
    '';

    # Start on tty login is disabled because I'm using a display manager (but I'm keeping the code for future reference)
    #environment.loginShellInit = ''
    #  # start sway when logging in on tty1
    #  if [ "$USER" = jens ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] && [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    #    exec sway &> /run/user/$UID/sway_log
    #  fi
    #'';
  };
}
