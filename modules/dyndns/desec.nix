{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.dyndns.desec;
  cfgs = attrValues cfg;

  perDomainConfig = {name, ...}: {
    options = {
      enable = mkEnableOption "dyndns update timer";
      domain = mkOption {
        type = types.str;
        default = "";
        description = ''
          The Domain to configure dyndns for.
        '';
      };
      keyfile = mkOption {
        type = types.str;
        description = ''
          Path to a file containing the desec token.
        '';
      };
      onUnitActiveSec = mkOption {
        type = with types; nullOr str;
        default = "2min";
        example = "5min";
        description = ''
          OnUnitActiveSec value for the systemd-timer. See SYSTEMD.TIME(7).
        '';
      };
      onBootSec = mkOption {
        type = with types; nullOr str;
        default = "30sec";
        example = "1min";
        description = ''
          OnBootSec value for the systemd-timer. See SYSTEMD.TIME(7).
        '';
      };
    };
    config = {
      domain = mkDefault name;
    };
  };

  flattenList = l: builtins.foldl' (x: y: x//y) {} l;

  dyndnsScript = domainCfg: ''
    #!${pkgs.zsh}/bin/zsh
    set -euo pipefail

    # take the first global (should be routable) primary (to filter out privacy extension addresses) ipv6 address
    myip="$(${pkgs.iproute2}/bin/ip -json -6 address show scope global primary | ${pkgs.jq}/bin/jq --raw-output '.[0].addr_info | map(.local | strings | select(startswith("fc") or startswith("fd") | not)) | .[0]')"
    # ensure we have a valid v6 address
    if ${pkgs.iproute2}/bin/ip route get "$myip" &>/dev/null
    then
    else
      echo "No global primary ipv6 address available"
      exit 1
    fi

    set +e
    lastip=$((< $STATE_DIRECTORY/last_ip) 2>/dev/null)
    set -e

    if [[ $myip == $lastip ]] {
      echo "Unchanged IPv6 address $myip"
      exit 0
    }

    echo "Using IPv6 address $myip"

    config="--user ${domainCfg.domain}:$(<${domainCfg.keyfile})"
    response=$(${pkgs.curl}/bin/curl --silent -X GET "https://update6.dedyn.io/?ipv6=$myip" --config - <<<$config)
    echo $response

    if [[ $response == good ]] {
      echo $myip > $STATE_DIRECTORY/last_ip
    }
  '';

  dyndnsService = domainCfg: mkIf domainCfg.enable {
    "dyndns-${domainCfg.domain}" = {
      description = "dyndns update service";
      requires = [ "network-online.target" ];
      after = [ "network-online.target" ];
      script = "${pkgs.writeScript "dyndns-${domainCfg.domain}" (dyndnsScript domainCfg)}";
      serviceConfig = {
        #LoadCredential = mapAttrsToList (name: path: "${name}.yaml:${path}") cfg.synapse.extraConfigFiles;
        StateDirectory = "dyndns/${domainCfg.domain}";
      };
    };
  };

  dyndnsTimer = domainCfg: mkIf domainCfg.enable {
    "dyndns-${domainCfg.domain}" = {
      description = "dyndns update update timer";
      wantedBy = [ "multi-user.target" ];
      requires = [ "network-online.target" ];
      after = [ "network-online.target" ];
      timerConfig = { Unit = "dyndns-${domainCfg.domain}.service"; }
        // (optionalAttrs (!isNull domainCfg.onBootSec) { OnBootSec = domainCfg.onBootSec; })
        // (optionalAttrs (!isNull domainCfg.onUnitActiveSec) { OnUnitActiveSec = domainCfg.onUnitActiveSec; });
    };
  };

in {

  options.services.dyndns.desec = mkOption {
    type = with types; loaOf (submodule perDomainConfig);
    default = {};
    description = ''
      Timer for updating dyndns records.
    '';
  };

  config = {
    systemd.services = flattenList (map dyndnsService cfgs);
    systemd.timers = flattenList (map dyndnsTimer cfgs);
  };

}
