# Basic desktop functionality (window manager, terminal emulator, browser and a few utilities)
{ pkgs, ... }:

let
  swaylockWithIdle = pkgs.writeScriptBin "swaylock-with-idle" ''
#!/usr/bin/env zsh

trap 'swaymsg "output * dpms on"' EXIT INT HUP TERM

swayidle -w \
        timeout 10 'swaymsg "output * dpms off"' \
        resume 'swaymsg "output * dpms on"' \
        &

swaylock $@

kill %1
  '';

  blockPath = ../../desktop/blocks;

in
{
  imports = [
    ./base.nix
  ];

  environment.systemPackages = with pkgs; [
    # desktop environment programs
    kitty
    rxvt_unicode
    glxinfo
    gnome3.gnome-disk-utility
    networkmanagerapplet
    wayvnc
    pulsemixer
    dfeet
    #vimiv
    mpv
    wdisplays

    # screenshot utilities
    grim
    slurp

    # cursor theme (installed via `home-profiles/desktop/.local/share/icons/default/index.theme`)
    simpleandsoft

    # icon theme (required for e.g. `lutris`)
    gnome3.adwaita-icon-theme

    # soft desktop dependencies
    swaylockWithIdle
    zsh
    mako
    rofi
    qt5.qtwayland
    acpilight
    redshift-wlr
    kanshi
    libnotify
    wl-clipboard
    ddcutil

    # theme
    adwaita-qt

    # qbar block dependencies
    qbar
    python3
    acpi
    perl
    sysstat
    zsh
    bash
    wirelesstools
    lm_sensors
    jq
  ];

  fonts.fonts = with pkgs; [ fira-code ];

  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    systemWide = true;
  };

  users = {
    users.jens = {
      packages = with pkgs; [
        q
        chromium
        qutebrowser
        pavucontrol
        playerctl
        xdg_utils
      ];
      extraGroups = [
        "video"
      ];
      dotfiles.profiles = [ "kitty" "vscode" "desktop" ];
    };
  };


  programs.sway.enable = true;
  programs.sway.extraPackages = with pkgs; [ swaylock swayidle xwayland kitty cool-retro-term xorg.xrdb ];
  # QT_QPA_PLATFORM=wayland requires qt5.qtwayland in systemPackages
  programs.sway.extraSessionCommands = ''
    export SDL_VIDEODRIVER=wayland
    # Creates problems with OBS
    #export QT_QPA_PLATFORM=wayland
    export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
  '';
  environment.loginShellInit = ''
    # start sway when logging in on tty1
    if [ "$USER" = jens ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] && [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    exec sway &> /run/user/$UID/sway_log
    fi
  '';

  environment.etc."xdg/Trolltech.conf".text = ''
    [Qt]
    style=adwaita-dark
  '';
  environment.shellInit = "export QT_STYLE_OVERRIDE=adwaita-dark";
}
