{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.queezle.firewall;
  toPortList = ports: assert length ports > 0; "{ ${concatStringsSep ", " (map toString ports)} }";
  sshPorts = toPortList config.services.openssh.ports;
in {
  options.queezle.firewall.enable = mkEnableOption "nftables zone-based firewall";

  config = mkIf cfg.enable {
    # nixpkgs firewall is replaced with nftables firewall
    networking.firewall.enable = false;

    # Firewall debug output:
    #networking.nftables.stopRuleset = traceSeqN 10 config.networking.nftables.ruleset ''

    networking.nftables.stopRuleset = traceSeqN 10 config.networking.nftables.ruleset ''
      table inet firewall {
        chain input {
          type filter hook input priority 0; policy drop
          iifname lo accept
          ct state {established, related} accept
          ip6 nexthdr icmpv6 icmpv6 type { echo-request, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert } accept
          ip protocol icmp icmp type { echo-request, router-advertisement } accept
          tcp dport ${sshPorts} accept
          counter drop
        }
        chain forward {
          type filter hook forward priority 0; policy drop
          ct state {established, related} accept
          counter drop
        }
      }
    '';

    networking.nftables.firewall = {
      enable = true;
      zones = {
        net.interfaces = [ "eth" ];
        docker.interfaces = [ "docker0" "cni-podman0" ];
        libvirt.interfaces = [ "virbr0" ];
      };
      rules = {
        # Drop all messages from the internet, so they are not logged by the
        # other "reject"-policies. Make sure all externally reachable interfaces
        # are subject to this rules.
        drop-net = {
          from = [ "net" ];
          to = "all";
          ruleType = "policy";
          extraLines = [
            ''counter drop''
          ];
        };

        # Reject and log to help with debugging.
        reject-input = {
          from = "all";
          to = [ "fw" ];
          ruleType = "policy";
          extraLines = [
            # Only log unicast directed to this host
            ''meta pkttype != host counter drop''
            ''counter log prefix "Rejected connection: " reject''
          ];
        };

        # Reject and log to help with debugging.
        reject-forward = {
          from = "all";
          to = "all";
          ruleType = "policy";
          extraLines = [
            ''counter log prefix "Rejected forward connection: " reject''
          ];
        };

        icmp.extraLines = mkForce [
          "ip6 nexthdr icmpv6 icmpv6 type { echo-request, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert } accept"
          "ip protocol icmp icmp type { echo-request, router-advertisement } accept"
        ];

        dhcpv6 = {
          from = "all";
          to = [ "fw" ];
          early = true;
          after = [ "icmp" ];
          extraLines = [
            "ip6 saddr fe80::/10 ip6 daddr fe80::/10 udp dport 546 accept"
          ];
        };

        docker-forward = {
          from = [ "docker" ];
          to = [ "net" "docker" ];
          verdict = "accept";
        };

        docker-masquerade = {
          from = [ "docker" ];
          to = [ "net" ];
          masquerade = true;
        };

        libvirt-forward = {
          from = [ "libvirt" ];
          to = [ "fw" "net" ];
          verdict = "accept";
        };

        libvirt-masquerade = {
          from = [ "libvirt" ];
          to = [ "net" ];
          masquerade = true;
        };
      };
    };
  };
}
