{ config, lib, pkgs, ... }:
with lib;

let
  uid = config.ids.uids.gpsd;
  gid = config.ids.gids.gpsd;
  cfg = config.services.gpsd;
in {
  # An attempt at creating a secure hotplug-capable gpsd configuration

  # TODO: for not running as root, chronys SHM segments have to be configured to be writable from chrony
  # (e.g. `refclock SHM 1:perm=0664 refid GPS2`, started with an appropriate group)
  # The same applies to crony .sock files (they are only writeable by root by default)

  # New service unit to use --sockfile feature
  systemd.services.gpsd = {
    serviceConfig = {
      ExecStart = "${pkgs.gpsd}/bin/gpsd --foreground --sockfile /run/gpsd/gpsd.sock --nowait --debug 0";
      Type = "exec";
      #User = "gpsd";
      #Group = "gpsd";
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectControlGroups = true;
      CapabilityBoundingSet = "CAP_SYS_TIME CAP_IPC_LOCK CAP_SETUID CAP_SETGID";
      RuntimeDirectory = "gpsd";
    };
  };

  # Per-device service unit to load devices
  systemd.services."gpsd-add-device@" = {
    requires = [ "gpsd.service" ];
    after = [ "gpsd.service" ];
    serviceConfig = {
      ExecStartPre = "${pkgs.setserial}/bin/setserial /dev/%I low_latency";
      ExecStart = "${pkgs.gpsd}/bin/gpsdctl add /dev/%I";
      ExecStop = ''${pkgs.zsh}/bin/zsh -c "[[ -e /dev/%I ]] && ${pkgs.gpsd}/bin/gpsdctl remove /dev/%I"'';
      RemainAfterExit = true;
      Environment = "GPSD_SOCKET=/run/gpsd/gpsd.sock";
      Type = "oneshot";
      #User = "gpsd";
      #Group = "gpsd";
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      CapabilityBoundingSet = "";
    };
  };

  services.udev.packages = lib.singleton (pkgs.writeTextFile {
    name = "gpsmouse-udev-rules";
    destination = "/etc/udev/rules.d/90-gpsmouse.rules";
    text = ''
      SUBSYSTEM=="tty", ATTRS{idVendor}=="1546", ATTRS{idProduct}=="01a7", GROUP="dialout", TAG+="systemd", ENV{SYSTEMD_WANTS}="gpsd-add-device@$name.service"
    '';
  });

  # User config replicated from nixpkgs gpsd.nix
  users.users.gpsd =
    { inherit uid;
      group = "gpsd";
      description = "gpsd daemon user";
      home = "/var/empty";
    };

  users.groups.gpsd = { inherit gid; };
}
