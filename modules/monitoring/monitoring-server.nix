{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.queezle.monitoring.server;
in {
  options.queezle.monitoring.server.enable = lib.mkEnableOption "prometheus and grafana server";

  config = mkIf cfg.enable {

    # Local agent simplifies and unifies node scraping
    queezle.monitoring.grafana-agent.enable = true;

    services.grafana = {
      enable = true;
      settings = {
        analytics = {
          reporting_enabled = false;
          check_for_updates = false;
        };
        server = {
          #protocol = "http";
          #http_addr = "127.0.0.1";
          #http_port = 3000;
          protocol = "socket";
          socket = "/run/nginx-grafana/grafana.sock";
          socket_mode = "0777";
        };
      };
      # Currently using sqlite database
      #database = {
      #  type = "postgres";
      #  user = "grafana";
      #  host = "/var/run/postgresql/";
      #};
      provision.enable = true;
      provision.datasources.settings.datasources = [
        {
          name = "prometheus";
          type = "prometheus";
          url = "http://localhost:9090";
        }
      ];
      #provision.dashboards = [
      #  {
      #    name = "yaner dashboards";
      #    options.path = ./dashboards;
      #    options.foldersFromFilesStructure = true;
      #    updateIntervalSeconds = 999999999;
      #  }
      #];
    };
    systemd.tmpfiles.rules = [ "d /run/nginx-grafana 0750 grafana nginx" ];

    services.prometheus = {
      enable = true;
      stateDir = "prometheus";
      # TODO default is 0.0.0.0, is this required?
      #listenAddress = "127.0.0.1"; # port 9090
      extraFlags = [
        "--storage.tsdb.retention.size=32GB"
        "--web.enable-remote-write-receiver"
      ];
      scrapeConfigs = [
        {
          job_name = "prometheus";
          static_configs = [
            {
              targets = [ "127.0.0.1:9090" ];
              labels.instance = config.networking.hostName;
            }
          ];
        }
        {
          job_name = "grafana";
          static_configs = [
            {
              targets = [ "127.0.0.1:3000" ];
              labels.instance = config.networking.hostName;
            }
          ];
        }
      ];
    };

    # Reverse proxy for remote write endpoint.
    # (Prometheus has no authentication for api requests, so _only_ the remote
    # write endpoint should be proxied).

    # Encrypted/authenticated by using wireguard and firewall rules
    # (i.e. no HTTPS to isolate metrics from potential letsencrypt problems)
    services.nginx = {
      virtualHosts = {
        "prometheus" = {
          listen = [
            {
              # TODO limit to vpn-only ip?
              addr = "[::]";
              port = 99;
            }
          ];
          forceSSL = false;
          locations = {
            "/" = {
              return = "404";
            };
            "= /api/v1/write" = {
              proxyPass = "http://127.0.0.1:9090";
              proxyWebsockets = true;
            };
          };
        };
      };
    };
  };
}
