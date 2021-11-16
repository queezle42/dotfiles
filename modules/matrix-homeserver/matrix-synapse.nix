{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.queezle.matrix-homeserver;

  pluginsEnv = cfg.package.python.buildEnv.override {
    extraLibs = cfg.plugins;
  };

in {
  config = mkIf cfg.enable {
    queezle.matrix-homeserver.settings = {
      pid_file = "/run/matrix-synapse.pid";
      signing_key_path = "${cfg.dataDir}/${cfg.serverName}.signing.key";
      media_store_path = "${cfg.dataDir}/media";
    };

    # User and group
    users.users.matrix-synapse = {
      group = "matrix-synapse";
      home = cfg.dataDir;
      createHome = true;
      shell = "${pkgs.bash}/bin/bash";
      uid = config.ids.uids.matrix-synapse;
    };

    users.groups.matrix-synapse = {
      gid = config.ids.gids.matrix-synapse;
    };

    # Service unit
    systemd.services.matrix-synapse = {
      description = "Synapse Matrix homeserver";
      after = [ "network.target" "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];
      preStart = "${cfg.package}/bin/homeserver --config-path ${cfg.configFile} --keys-directory ${cfg.dataDir} --generate-keys";
      environment = {
        PYTHONPATH = makeSearchPathOutput "lib" cfg.package.python.sitePackages [ pluginsEnv ];
      } // optionalAttrs (cfg.withJemalloc) {
        LD_PRELOAD = "${pkgs.jemalloc}/lib/libjemalloc.so";
      };

      serviceConfig = {
        Type = "notify";
        ExecStart = ''
          ${cfg.package}/bin/homeserver --config-path ${cfg.configFile} --config-directory ''${CREDENTIALS_DIRECTORY} --keys-directory ${cfg.dataDir}
        '';

        User = "matrix-synapse";
        Group = "matrix-synapse";
        WorkingDirectory = cfg.dataDir;

        LoadCredential = mapAttrsToList (name: path: "${name}:${path}") cfg.extraConfigFiles;

        ExecReload = "${pkgs.util-linux}/bin/kill -HUP $MAINPID";
        Restart = "on-failure";
        UMask = "0077";

        ProtectSystem = "full";
        ProtectHome = true;
        ProtectProc = "invisible";
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        ProtectKernelLogs = true;
        RestrictRealtime = true;
        PrivateDevices = true;
      };
    };
  };
}
