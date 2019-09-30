{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.sway_on_tty1;
  swayConfig = ./../../sway/sway-config;

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

in
{
  options.programs.sway_on_tty1 = {
    enable = mkEnableOption "Start sway with system config when logging in on tty1";
  };
  config = mkIf cfg.enable {
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
  exec sway --config ${swayConfig} &> /run/user/$UID/sway_log
fi
    '';
    environment.systemPackages = with pkgs; [ qbar swaylockWithIdle zsh mako rofi qt5.qtwayland ];
  };
}
