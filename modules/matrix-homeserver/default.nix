inputs@{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.queezle.matrix-homeserver;
  settingsFormat = pkgs.formats.json {};
in {
  imports = [
    ./matrix-synapse.nix
    ./postgresql.nix
    ./reverse-proxy.nix
    ./element.nix
    ./well-known.nix
    ./heisenbridge.nix
  ];

  options.queezle.matrix-homeserver = {
    enable = mkEnableOption "queezles matrix homeserver (including reverse proxy and element)";

    package = mkOption {
      type = types.package;
      default = pkgs.matrix-synapse;
      defaultText = literalExpression "pkgs.matrix-synapse";
      description = ''
        Overridable attribute of the matrix synapse server package to use.
      '';
    };

    serverName = mkOption {
      type = types.str;
      example = "example.com";
    };

    matrixDomain = mkOption {
      type = types.str;
      default = "matrix.${cfg.serverName}";
    };

    elementDomain = mkOption {
      type = types.str;
      default = "element.${cfg.serverName}";
    };

    useACMEHost = mkOption {
      type = types.str;
      default = null;
    };

    settings = mkOption {
      type = settingsFormat.type;
      apply = recursiveUpdate cfg.defaultSettings;
      default = {};
      description = ''
        https://matrix-org.github.io/synapse/latest/usage/configuration/homeserver_sample_config.html
      '';
    };

    defaultSettings = mkOption {
      type = settingsFormat.type;
      default = import ./settings.nix inputs;
      description = ''
        Default settings (i.e. *my* settings). Can be overwritten by setting them to '{}'.
      '';
    };

    configFile = mkOption {
      type = types.path;
      default = settingsFormat.generate "synapse-homeserver.yaml" cfg.settings;
      defaultText = ''settingsFormat.generate "synapse-homeserver.yaml" config.queezle.matrix-homeserver.configuration'';
      description = ''
        Path to the config file. By default generated from queezle.matrix-homeserver.settings.
      '';
    };

    extraConfigFiles = mkOption {
      type = types.attrsOf types.path;
      default = {};
      example = { secrets = "/path/to/matrix-synapse/secrets.yaml"; };
      description = ''
        Extra config files to include, e.g. as a way to include secrets without
        publishing them to the nix store.
        This is the recommended way to include the 'registration_shared_secret'
        and other secrets.
        Files will be read as root.
      '';
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/matrix-synapse";
      description = ''
        The directory where matrix-synapse stores its stateful data such as
        certificates, media and uploads.
      '';
    };

    plugins = mkOption {
      type = types.listOf types.package;
      default = [ ];
      example = literalExpression ''
        with config.services.matrix-synapse.package.plugins; [
          matrix-synapse-ldap3
          matrix-synapse-pam
        ];
      '';
      description = ''
        List of additional Matrix plugins to make available.
      '';
    };

    withJemalloc = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to preload jemalloc to reduce memory fragmentation and overall usage.
      '';
    };

    # .well-known configuration. Can be enabled on the same or on another another host.
    well-known = {
      enable = mkEnableOption ".well-known for queezles matrix homeserver";

      nginxVirtualHost = mkOption {
        type = types.str;
        default = cfg.serverName;
      };
    };

    # Heisenbridge IRC bouncer. Has to run un the same host as synapse.
    heisenbridge = {
      enable = mkEnableOption "heisenbridge";

      owner = mkOption {
        type = types.str;
        example = "@someone:example.com";
        description = ''
          MXID of the owner.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.heisenbridge;
        defaultText = literalExpression "pkgs.heisenbridge";
        description = ''
          Overridable attribute of the heisenbridge package to use.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.services.matrix-synapse.enable;
        message = "Cannot use services.matrix-synapse and queezle.matrix-homeserver at the same time.";
      }
      {
        assertion = config.queezle.matrix-homeserver.settings ? max_upload_size;
        message = "queezle.matrix-homeserver.settings.max_upload_size not set";
      }
    ];

    queezle.matrix-homeserver.settings = {
      server_name = cfg.serverName;
    };
  };
}
