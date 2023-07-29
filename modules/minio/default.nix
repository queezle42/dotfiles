{ config, lib, ... }:
with lib;

let
  cfg = config.queezle.minio;
in {
  options.queezle.minio = {
    enable = mkEnableOption "MinIO server";
    region = mkOption {
      description = "MinIO server region";
      type = types.str;
    };
    consoleUrl = mkOption {
      description = "MinIO console url. Should match the reverse proxy configuration.";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    services.minio = {
      enable = true;
      region = cfg.region;
      listenAddress = "127.0.0.1:9000";
      consoleAddress = "127.0.0.1:9001";
      rootCredentialsFile = "/etc/secrets/minio/root-credentials";
    };

    systemd.services.minio.serviceConfig.Environment = "MINIO_BROWSER_REDIRECT_URL=${cfg.consoleUrl}";
  };
}
