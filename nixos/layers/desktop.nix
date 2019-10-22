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
    # desktop programs
    glxinfo
    gnome3.gnome-disk-utility
    vscode

    # soft desktop dependencies
    swaylockWithIdle
    zsh
    mako
    rofi
    qt5.qtwayland
    acpilight

    # qbar block dependencies
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

  fonts.fonts = [ pkgs.fira-code ];

  sound.enable = true;
  hardware.pulseaudio.enable = true;


  users = {
    users.jens = {
      packages = with pkgs; [
        chromium
        tdesktop
        spotify
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
  programs.sway.extraPackages = with pkgs; [ swaylock swayidle xwayland kitty cool-retro-term ];
  # QT_QPA_PLATFORM=wayland requires qt5.qtwayland in systemPackages
  programs.sway.extraSessionCommands = ''
export SDL_VIDEODRIVER=wayland
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
  '';
  environment.loginShellInit = ''
# start sway when logging in on tty1
if [ "$USER" = jens ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] && [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
exec sway &> /run/user/$UID/sway_log
fi
  '';
}
