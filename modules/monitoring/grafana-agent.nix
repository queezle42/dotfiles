{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.queezle.monitoring.grafana-agent;
  settingsFormat = pkgs.formats.yaml { };
  configFile = settingsFormat.generate "grafana-agent.yaml" cfg.settings;
in {
  options.queezle.monitoring.grafana-agent = {
    enable = lib.mkEnableOption "prometheus agent config";

    remoteWriteUrl = mkOption {
      type = types.str;
      default = "http://prometheus:99/api/v1/write";
    };

    settings = mkOption {
      description = lib.mdDoc ''
        Configuration for `grafana-agent`.
        See https://grafana.com/docs/agent/latest/configuration/
      '';

      type = types.submodule {
        freeformType = settingsFormat.type;
      };
    };
  };

  config = mkIf cfg.enable {

    queezle.monitoring.grafana-agent.settings = {
      metrics = {
        wal_directory = "\${STATE_DIRECTORY}";

        global.remote_write = [{
          url = cfg.remoteWriteUrl;
        }];

        #configs = [{
        #  scrape_configs = ...
        #}];
      };
      integrations = {
        # Scrape metrics about the agent itself
        agent = {
          enabled = true;
          scrape_integration = true;
          instance = config.networking.hostName;
        };

        # Set up integrated node exporter
        node_exporter = {
          enabled = true;
          scrape_integration = true;
          instance = config.networking.hostName;
          enable_collectors = [
            "systemd"
          ];
        };
      };
    };

    systemd.services.grafana-agent = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.grafana-agent}/bin/grafana-agent -disable-reporting -config.expand-env -config.file ${configFile}";
        RestartSec = 10;
        Restart = "always";
        User = "grafana-agent";
        Group = "grafana-agent";
        SupplementaryGroups = [
          # Allow to read the systemd journal for loki log forwarding
          "systemd-journal"
        ];
        StateDirectory = "grafana-agent";
        Type = "exec";

        # NOTE: No DynamicUser since that prevents the node_exporter systemd
        # integration from connecting to the socket.
        ProtectSystem = "strict";
        ProtectHome = "tmpfs";
        RemoveIPC = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
        RestrictSUIDSGID = true;
      };
    };

    users.users.grafana-agent = {
      isSystemUser = true;
      group = "grafana-agent";
    };
    users.groups.grafana-agent = {};
  };
}

