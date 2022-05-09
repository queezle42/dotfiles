{ lib, config, pkgs, ... }:
with lib;

let
  cfg = config.queezle.distractionBlocker;
in {
  options.queezle.distractionBlocker = {
    enable = mkEnableOption "distraction blocker";
  };

  config = mkIf cfg.enable {
    services.kresd = {
      enable = true;
      package = pkgs.knot-resolver.override { extraFeatures = true; };

      listenPlain = [ "127.0.0.42:53" ];

      extraConfig = ''
        cache.size = 100*MB

        -- Log DNSSEC validation failures
        modules.load('bogus_log')

        -- Refresh records that are about to expire and enable prediction prototype
        modules.load('predict')

        policy.add(policy.rpz(policy.REFUSE, '/run/blocklist.rpz', true))

        policy.add(policy.all(policy.TLS_FORWARD({
          { '2606:4700:4700::1111', hostname='cloudflare-dns.com' },
          { '1.1.1.1', hostname='cloudflare-dns.com' },
        })))

        trust_anchors.set_insecure({
          'gnome.org'
        })
      '';
    };

    systemd.services.distraction-blocker = {
      wantedBy = [ "multi-user.target" ];
      unitConfig = {
        Description = "Install distraction blocklist";
      };
      serviceConfig = {
        ExecStart = "${pkgs.coreutils}/bin/ln -f -s ${./blocklist.rpz} /run/blocklist.rpz";
        ExecStop = "${pkgs.coreutils}/bin/ln -f -s ${pkgs.emptyFile} /run/blocklist.rpz";
        RemainAfterExit = true;
      };
    };
  };
}
