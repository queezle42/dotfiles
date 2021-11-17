{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.queezle.matrix-homeserver;
in {
  # TODO dedicated enable
  config = mkIf cfg.enable {
    # postgresql database service
    services.postgresql = {
      enable = true;
      # NOTE: Create user and database yourself if an existing database is used
      initialScript = pkgs.writeText "synapse-init.sql" ''
        CREATE USER "matrix-synapse";
        CREATE DATABASE "matrix-synapse" WITH
          OWNER "matrix-synapse"
          TEMPLATE template0
          ENCODING 'UTF8'
          LC_COLLATE = 'C'
          LC_CTYPE = 'C';
      '';
    };

    # matrix-synapse database configuration
    queezle.matrix-homeserver.settings.database = {
      name = "psycopg2";
      args = {
        user = "matrix-synapse";
        database = "matrix-synapse";
      };
    };
  };
}
