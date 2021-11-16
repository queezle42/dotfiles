{ config, lib, ... }:
with lib;

let
  cfg = config.queezle.matrix-homeserver;

in {
  # Allow to get more events during get and sync operation if requested by client
  filter_timeline_limit = 1000;

  # Should be at least 1.1 to prevent TLS downgrade attacks
  # But 1.2 should be supported by all homeservers, as well as the usual reverse proxies
  federation_client_minimum_tls_version = 1.2;

  caches = {
    global_factor = 4.0;
  };

  # Set to default value because it needs to be configured on nginx
  max_upload_size = "50M";

  dynamic_thumbnails = true;

  url_preview_enabled = true;
  url_preview_ip_range_blacklist = [
    "127.0.0.0/8"
    "10.0.0.0/8"
    "172.16.0.0/12"
    "192.168.0.0/16"
    "100.64.0.0/10"
    "192.0.0.0/24"
    "169.254.0.0/16"
    "192.88.99.0/24"
    "198.18.0.0/15"
    "192.0.2.0/24"
    "198.51.100.0/24"
    "203.0.113.0/24"
    "224.0.0.0/4"
    "::1/128"
    "fe80::/10"
    "fc00::/7"
    "2001:db8::/32"
    "ff00::/8"
    "fec0::/10"
  ];

  # TODO TURN

  enable_registration = true;
  registration_requires_token = true;
  bcrypt_rounds = 14; # Benchmarked to take >0.5s on an AMD Ryzen 9 5900X

  # TODO Metrics

  report_stats = false;

  trusted_key_servers = [
    { server_name = "matrix.org"; }
  ];
  suppress_key_server_warning = true;

  password_config = {
    policy = {
      minimum_length = 16;
    };
  };

  # TODO Push
}
