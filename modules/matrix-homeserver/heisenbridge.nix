{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.queezle.matrix-homeserver;
  configFilePath = "/var/lib/matrix-synapse/heisenbridge.yaml";

in {
  config = mkIf (cfg.enable && cfg.heisenbridge.enable) {
    queezle.matrix-homeserver.settings.app_service_config_files = [
      configFilePath
    ];

    systemd.services.heisenbridge-generate = {
      description = "generate heisenbridge config";
      # Appconfig-file needs to exist before synapse is started
      wantedBy = [ "matrix-synapse.service" ];
      before = [ "matrix-synapse.service" ];

      unitConfig = {
        # Only run once
        ConditionPathExists = "!${configFilePath}";
      };

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${cfg.heisenbridge.package}/bin/heisenbridge --config /run/heisenbridge-generate/config.yaml --generate";
        ExecStartPost = "+${pkgs.coreutils}/bin/install -o matrix-synapse -g matrix-synapse -m u=r /run/heisenbridge-generate/config.yaml ${configFilePath}";

        RuntimeDirectory = "heisenbridge-generate";

        DynamicUser = true;
        User = "heisenbridge";
        Group = "heisenbridge";

        PrivateNetwork = true;
        ProtectHome = true;
        PrivateDevices = true;
        ProtectProc = "invisible";
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        ProtectKernelLogs = true;
      };
    };

    systemd.services.heisenbridge = {
      description = "heisenbridge";
      after = [ "network.target" "heisenbridge-generate.service" ];
      requires = [ "heisenbridge-generate.service" ];
      wantedBy = [ "multi-user.target" ];

      unitConfig = {
        StartLimitBurst = 2;
        StartLimitIntervalSec = "42s";
      };

      serviceConfig = {
        Type = "exec";
        ExecStart =
            # is a script to load environment variable
          let startScript = pkgs.writeShellScriptBin "heisenbridge" ''
            exec ${cfg.heisenbridge.package}/bin/heisenbridge --config $CREDENTIALS_DIRECTORY/config
          '';
          in "${startScript}/bin/heisenbridge";

        LoadCredential = [
          "config:${configFilePath}"
        ];

        Restart = "on-failure";

        DynamicUser = true;
        User = "heisenbridge";
        Group = "heisenbridge";

        ProtectHome = true;
        PrivateDevices = true;
        ProtectProc = "invisible";
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        ProtectKernelLogs = true;
        RestrictRealtime = true;
      };
    };
  };
}
