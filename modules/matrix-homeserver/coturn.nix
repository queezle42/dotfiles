{ config, pkgs, lib, ... }:
with lib;

let
  cfg = config.queezle.matrix-homeserver;
  staticAuthSecretPath = cfg.coturn.authSecretPath;
  synapseConfigPath = "/var/lib/matrix-synapse/coturn-secret.yaml";
  configFile = pkgs.writeText "coturn.config" ''
    # static-auth-secret is appended to config when service is started
    use-auth-secret
    realm=${cfg.turnRealm}

    # Log to syslog
    no-stdout-log
    syslog
    verbose

    pidfile /run/coturn/turnserver.pid

    # Hide version
    no-software-attribute

    # Only allow encrypted client connections
    no-udp
    no-tcp

    no-cli
    no-tcp-relay

    # Modern crypto / prevent TLS downgrade to 1.0
    no-tlsv1
    no-tlsv1_1

    secure-stun

    no-multicast-peers
    denied-peer-ip=0.0.0.0-0.255.255.255
    denied-peer-ip=10.0.0.0-10.255.255.255
    denied-peer-ip=100.64.0.0-100.127.255.255
    denied-peer-ip=169.254.0.0-169.254.255.255
    denied-peer-ip=172.16.0.0-172.31.255.255
    denied-peer-ip=192.0.0.0-192.0.0.255
    denied-peer-ip=192.0.2.0-192.0.2.255
    denied-peer-ip=192.88.99.0-192.88.99.255
    denied-peer-ip=192.168.0.0-192.168.255.255
    denied-peer-ip=198.18.0.0-198.19.255.255
    denied-peer-ip=198.51.100.0-198.51.100.255
    denied-peer-ip=203.0.113.0-203.0.113.255
    denied-peer-ip=240.0.0.0-255.255.255.255
    denied-peer-ip=64:ff9b::-64:ff9b::ffff:ffff
    denied-peer-ip=::ffff:0.0.0.0-::ffff:255.255.255.255
    denied-peer-ip=100::-100::ffff:ffff:ffff:ffff
    denied-peer-ip=2001::-2001:1ff:ffff:ffff:ffff:ffff:ffff:ffff
    denied-peer-ip=2002::-2002:ffff:ffff:ffff:ffff:ffff:ffff:ffff
    denied-peer-ip=fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
    denied-peer-ip=fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff
  '';
in {
  config = mkIf (cfg.enable && cfg.coturn.enable) {
    assertions = [
      {
        assertion = !config.services.coturn.enable;
        message = "Cannot use services.coturn.enable and queezle.matrix-homeserver.coturn.enable at the same time.";
      }
    ];

    queezle.matrix-homeserver = {
      extraConfigFiles."turn-secret" = "/var/lib/matrix-homeserver/turn-secret.yaml";
      settings = {
        turn_uris = [
          "turns:${cfg.turnRealm}?transport=udp"
          "turns:${cfg.turnRealm}?transport=tcp"
        ];
        # One day token lifetime
        turn_user_lifetime = 86400000;
      };
    };

    networking.firewall = {
      # Default TLS TURN listener
      allowedTCPPorts = [ 5349 5350 ];
      # Default DTLS TURN listener
      allowedUDPPorts = [ 5349 5350 ];
      # Default UDP TURN relay port range
      allowedUDPPortRanges = [
        {
          from = 49152;
          to = 65535;
        }
      ];
    };


    systemd.services.coturn-generate = {
      description = "generate shared secret for coturn and synapse";
      before = [ "matrix-synapse.service" ];
      wantedBy = [ "matrix-synapse.service" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeScript "coturn-generate" ''
          #!${pkgs.zsh}/bin/zsh
          set -eu

          umask u=rwx,go=

          if [[ ! -e ${staticAuthSecretPath} ]] {
            ${pkgs.pwgen}/bin/pwgen -s 64 > '${staticAuthSecretPath}'
          }

          > /var/lib/matrix-homeserver/turn-secret.yaml <<- EOF
            turn_shared_secret: "$(< ${staticAuthSecretPath})"
          EOF
        '';

        StateDirectory = "matrix-homeserver";
      };
    };

    systemd.services.coturn = {
      description = "coturn STUN/TURN server for matrix homeserver";

      after = [ "network-online.target" ];
      requires = [ "coturn-generate.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "exec";
        ExecStart =
          let command = pkgs.writeScriptBin "turnserver" ''
            #!${pkgs.zsh}/bin/zsh
            set -eu

            readonly config_file=$RUNTIME_DIRECTORY/turnserver.conf

            < "${configFile}" > $config_file
            echo "static-auth-secret $(< $CREDENTIALS_DIRECTORY/staticAuthSecret)" >> $config_file

            exec ${cfg.coturn.package}/bin/turnserver \
              -c $config_file \
              --cert $CREDENTIALS_DIRECTORY/cert \
              --pkey $CREDENTIALS_DIRECTORY/pkey
          '';
          in "${command}/bin/turnserver";
        RuntimeDirectory = "coturn";

        LoadCredential = [
          "staticAuthSecret:${staticAuthSecretPath}"
          "cert:${config.security.acme.certs.${cfg.coturn.useACMEHost}.directory}/cert.pem"
          "pkey:${config.security.acme.certs.${cfg.coturn.useACMEHost}.directory}/key.pem"
        ];

        # TODO
        #Restart = "on-failure";

        DynamicUser = true;
        User = "coturn";
        Group = "coturn";

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
