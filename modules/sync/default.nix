{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.queezle.sync;
in {
  options.queezle.sync = {
    enable = mkEnableOption "sync";
    user = mkOption {
      type = types.str;
      default = config.queezle.common.user;
    };
    group = mkOption {
      type = types.str;
      default = config.queezle.common.user;
    };
    dataDir = mkOption {
      type = types.str;
      default = "/srv/sync";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      # syncthing
      22000
    ];

    networking.firewall.allowedUDPPorts = [
      # syncthing quic
      22000
      # syncthing announce
      21027
    ];

    systemd.tmpfiles.rules = [ "d ${cfg.dataDir} 0700 ${cfg.user} ${cfg.group}" ];

    services.syncthing = {
      enable = true;
      inherit (cfg) user group dataDir;
      overrideDevices = false;
      overrideFolders = false;
      extraOptions = {
        options = {
          urAccepted = -1;
          crashReportingEnabled = false;
        };
      };
    };

    systemd.services.syncthing.serviceConfig = rec {
      # Extend capabilities to allow user id rewriting
      AmbientCapabilities = [
        "CAP_CHOWN"
        "CAP_FOWNER"
      ];
      CapabilityBoundingSet = mkForce AmbientCapabilities;

      ProtectHome = true;
      ProtectSystem = "strict";
      PrivateUsers = mkForce false;
      ReadWritePaths = [ config.services.syncthing.dataDir ];
    };


    systemd.services.syncthing-credentials = {
      description = "Syncthing credentials updater";
      before = [ "syncthing.service" ];
      wantedBy = [ "syncthing.service" ];

      serviceConfig = {
        User = config.services.syncthing.user;
        RemainAfterExit = true;
        Type = "oneshot";
        ExecStart = pkgs.writeScript "syncthing-credentials" ''
          #!${pkgs.zsh}/bin/zsh
          ${config.services.syncthing.package}/bin/syncthing \
            generate \
            --home=${config.services.syncthing.configDir} \
            --gui-user=jens \
            --gui-password=- \
            --skip-port-probing \
            --no-default-folder \
            < $CREDENTIALS_DIRECTORY/gui-password
        '';
        LoadCredential = "gui-password:/etc/secrets/syncthing/gui-password";
      };
    };

    environment.systemPackages = [
      config.services.syncthing.package
    ];
  };
}
