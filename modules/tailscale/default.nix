{ lib, config, pkgs, ... }:
with lib;

# Initial setup (login):
# > sudo -u tailscale tailscale up --netfilter-mode=off --accept-dns=false

let
  cfg = config.queezle.tailscale;
in {
  options.queezle.tailscale = {
    enable = mkEnableOption "tailscale";

    port = mkOption {
      type = types.port;
      default = 41641;
      description = lib.mdDoc "The port to listen on for tunnel traffic (0=autoselect).";
    };

    interfaceName = mkOption {
      type = types.str;
      default = "tailscale";
      description = lib.mdDoc ''The interface name for tunnel traffic'';
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedUDPPorts = [ cfg.port ];

    networking.networkmanager.unmanaged = [ cfg.interfaceName ];
    networking.dhcpcd.denyInterfaces = [ cfg.interfaceName ];

    systemd.services.tailscaled = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-pre.target" ];
      after = [ "network-pre.target" "NetworkManager.service" "systemd-resolved.service" ];
      serviceConfig = rec {
        AmbientCapabilities = [
          "CAP_NET_ADMIN"
        ];
        CapabilityBoundingSet = mkForce AmbientCapabilities;

        ExecStartPre = "+${pkgs.kmod}/bin/modprobe tun";
        ExecStart = "${pkgs.tailscale}/bin/tailscaled --port ${toString cfg.port} --tun ${lib.escapeShellArg cfg.interfaceName} --no-logs-no-support";

        User = "tailscale";
        Group = "tailscale";
        ProtectHome = true;
        ProtectProc = "invisible";
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        ProtectKernelLogs = true;

        PrivateTmp = true;
        RemoveIPC = true;
        NoNewPrivileges = true;
        RestrictSUIDSGID = true;
        ProtectSystem = "strict";
        SystemCallArchitecture = "native";
        MemoryDenyWriteExecute = true;
        LockPersonality = true;
        ProtectKernelModules = true;

        DeviceAllow = "/dev/net/tun";

        RuntimeDirectory = "tailscale";
        RuntimeDirectoryMode = "0755";
        StateDirectory = "tailscale";
        StateDirectoryMode = "0700";
        CacheDirectory = "tailscale";
        CacheDirectoryMode = "0750";
        Type = "notify";
      };
    };

    networking.nftables.firewall = {
      zones.tailscale-range = {
        ipv6Addresses = [ "fd7a:115c:a1e0:ab12::/64" ];
      };
      zones.tailscale = {
        parent = "tailscale-range";
        interfaces = [ cfg.interfaceName ];
      };
      rules.tailscale-spoofing = {
        from = [ "tailscale-range" ];
        to = "all";
        extraLines = [
          "iifname \"${cfg.interfaceName}\" return"
          "counter drop"
        ];
      };
    };

    environment.systemPackages = [
      pkgs.tailscale
    ];

    users.users.tailscale = {
      isSystemUser = true;
      group = "tailscale";
    };
    users.groups.tailscale = {};
  };
}
