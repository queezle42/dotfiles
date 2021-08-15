{ pkgs, flakeInputs, system, ... }:

{
  imports = [ ./nginx.nix ];

  services.nginx = {
    virtualHosts."home.queezle.net" = {
      listen = [
        {
          addr = "10.0.0.1";
        }
        {
          addr = "10.0.0.1";
          port = 443;
          ssl = true;
        }
      ];
      forceSSL = true;
      useACMEHost = "home.queezle.net";
      # for qauth
      extraConfig = ''
        error_page 401 = @error401;
      '';
      locations = {
        "= /" = {
          extraConfig = "default_type text/plain;";
          return  = ''307 /qapp/'';
        };
        "/ip" = {
          extraConfig = "default_type text/plain;";
          return = ''200 $remote_addr'';
        };
        "/ip.json" = {
          extraConfig = "default_type application/json;";
          return = ''200 "{\"ip\":\"$remote_addr\"}"'';
        };
        "/qapp" = {
          return  = ''301 /qapp/'';
        };
        "/qapp/" = {
          alias = "/srv/qapp/";
          index = "index.html";
          #extraConfig = "auth_request /auth;";
        };
        "/tmp/" = {
          alias = "/srv/tmp/";
        };
        "/mqtt" = {
          proxyPass = "http://localhost:1884";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_read_timeout 5m;
          '';
          #extraConfig = ''
          #  auth_request /auth;
          #'';
        };

        "@error401" = {
          # "303 See Other" instructs the client to do a temporary redirect but change
          # the request method to GET
          #return = "303 /login?go=$scheme://$http_host$request_uri";
          return = "303 /login";
        };
        "= /auth" = {
          proxyPass = "http://unix:/run/qauth/http:/auth";
          extraConfig = ''
            internal;
            proxy_pass_request_body off;
            proxy_set_header Content-Length "";
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Original-URI $request_uri;
            proxy_set_header X-Host $http_host;
            auth_request_set $qauth_user $upstream_http_x_user;
          '';
        };
        "/login" = {
          proxyPass = "http://unix:/run/qauth/http:";
          extraConfig = ''
            proxy_http_version 1.1;
            proxy_set_header X-Original-URI $request_uri;
            proxy_set_header X-Real-IP $remote_addr;
          '';
        };
        "/logout" = {
          proxyPass = "http://unix:/run/qauth/http:/logout?go=/login";
          extraConfig = ''
            proxy_set_header X-Original-URI $request_uri;
            proxy_set_header X-Real-IP $remote_addr;
          '';
        };
        "/qauth" = {
          proxyPass = "http://unix:/run/qauth/http:";
          # this also sets "proxy_http_version 1.1;", so chunked transfer (used for noscript) works
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header X-Original-URI $request_uri;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_read_timeout 5m;
          '';
        };
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    email = "jens@nightmarestudio.de";
    certs."home.queezle.net" = {
      dnsProvider = "hetzner";
      # HACK acme-lego doesn't follow ns records correctly
      dnsPropagationCheck = false;
      credentialsFile = "/etc/secrets/dns/dns.hetzner.com_queezle.net";
      group = "nginx";
    };
  };



  systemd.services.qauth = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${flakeInputs.qauth.packages.${system}.qauth}/bin/qauth daemon";
      Sockets = "qauth-http.socket qauth-control.socket";
      DynamicUser = true;
      User = "qauth";
      Group = "qauth";
      ProtectSystem = "full";
      ProtectHome = true;
      PrivateDevices = true;
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      ProtectKernelLogs = true;
    };
  };
  systemd.sockets.qauth-http = {
    socketConfig = {
      ListenStream = "/run/qauth/http";
      FileDescriptorName = "http";
      Service = "qauth.service";
      SocketUser = "nginx";
      SocketGroup = "wheel";
      SocketMode = "0660";
    };
  };
  systemd.sockets.qauth-control = {
    socketConfig = {
      ListenStream = "/run/qauth/control";
      FileDescriptorName = "control";
      Service = "qauth.service";
      SocketGroup = "wheel";
      SocketMode = "0660";
    };
  };

  environment.systemPackages = [ flakeInputs.qauth.defaultPackage.${system} ];
}
