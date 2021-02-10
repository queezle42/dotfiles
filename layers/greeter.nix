{ pkgs, lib, ... }:

let
  greetd-config = ''
    [terminal]
    vt = 1

    [default_session]
    command = sway --config ${greeter-sway-config-file}
    user = greeter

    [initial_session]
    command = sway
    user = jens
  '';
  greetd-config-file = pkgs.writeText "greetd-config" greetd-config;
  greeter-sway-config = ''
    input * {
      xkb_layout de
      xkb_variant nodeadkeys
      xkb_numlock enable
    }

    exec "${pkgs.gtkgreet}/bin/gtkgreet --layer-shell --command=sway; swaymsg exit"

    bindsym Mod4+shift+e exec swaynag \
      -t warning \
      -m 'What do you want to do?' \
      -b 'Poweroff' 'systemctl poweroff' \
      -b 'Reboot' 'systemctl reboot'

    exec swayidle -w \
      timeout 30 'swaymsg "output * dpms off"' \
      resume 'swaymsg "output * dpms on"'
  '';
  greeter-sway-config-file = pkgs.writeText "greeter-sway-config" greeter-sway-config;

in
{
  environment.systemPackages = with pkgs; [
    # for greeter manpages
    greetd
    gtkgreet
  ];

  programs.sway.enable = true;
  programs.sway.extraPackages = with pkgs; [ swayidle ];

  users.users.greeter = {
    isSystemUser = true;
    home = "/var/run/greeter";
    createHome = true;
    # TODO only apply theming
    dotfiles.profiles = [ "desktop" ];
  };


  security.pam.services.greetd = {
    allowNullPassword = true;
    startSession = true;
  };

  # This prevents nixos-rebuild from killing greetd on every system activation
  systemd.services."autovt@tty1".enable = lib.mkForce false;

  systemd.services.greetd = {
    enable = true;

    unitConfig = {
      Wants = [
        "systemd-user-sessions.service"
      ];
      After = [
        "systemd-user-sessions.service"
        "plymouth-quit-wait.service"
        "getty@tty1.service"
      ];
      Conflicts = [
        "getty@tty1.service"
      ];

      #StartLimitBurst = 10;
      #StartLimitInterval = 60;
    };

    serviceConfig = {
      ExecStart = "${pkgs.greetd}/bin/greetd --config ${greetd-config-file}";

      IgnoreSIGPIPE = false;
      SendSIGHUP = true;
      TimeoutStopSec = "30s";
      KeyringMode = "shared";

      #Restart = "always";
      #RestartSec = 1;
    };

    restartIfChanged = false;
    stopIfChanged = false;
    wantedBy = [ "graphical.target" ];
  };

  systemd.defaultUnit = "graphical.target";
}
