{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.queezle.services.jellyfin;
in {
  options.queezle.services.jellyfin.enable = mkEnableOption "jellyfin server";

  config = mkIf cfg.enable {
    services.jellyfin.enable = true;

    systemd.services.jellyfin = {
      serviceConfig = {
        SupplementaryGroups = [
          "media"
          "music"
        ];
        Environment = [
          "JELLYFIN_kestrel__socket=true"
          "JELLYFIN_kestrel__socketPath=/run/jellyfin/jellyfin.sock"
          # Directory should be accessible by jellyfin and nginx only
          "JELLYFIN_kestrel__socketPermissions=0666"
        ];
      };
    };
    systemd.tmpfiles.rules = [ "d /run/jellyfin 0750 jellyfin nginx" ];
  };
}
