{ pkgs, lib, ... }:

{
  systemd.sockets.g815-led = {
    wantedBy = [ "multi-user.target" ];
    partOf = [ "g815-led.service" ];
    unitConfig = {
      Description = "Logitech keyboard led socket";
    };
    socketConfig = {
      ListenStream = "/run/g815-led.socket";
      SocketUser = "jens";
      Accept = "yes";
      MaxConnections = 1;
    };
  };
  systemd.services."g815-led@" = {
    after = [ "g815-led.socket" ];
    requires = [ "g815-led.socket" ];
    bindsTo = [ "g815-led.socket" ];
    unitConfig = {
      Description = "Logitech keyboard led backend";
    };
    serviceConfig = {
      ExecStart = "${pkgs.g810-led}/bin/g815-led -dp c33f -pp";
      StandardInput = "socket";
    };
  };

  services.udev.packages = lib.singleton (pkgs.writeTextFile {
    name = "q-g815-udev-rules";
    destination = "/etc/udev/rules.d/91-q-g815.rules";
    text = ''
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c33f", TAG+="systemd", ENV{SYSTEMD_WANTS}="q-g815.service"
    '';
  });

  systemd.services.q-g815= {
    after = [ "g815-led.socket" ];
    requires = [ "g815-led.socket" "q-system.socket" ];
    script = "${pkgs.q}/bin/q g815 daemon | ${pkgs.socat}/bin/socat stdin unix-connect:/run/g815-led.socket";
    unitConfig = {
      Description = "g815 led control";
    };
    serviceConfig = {
      Type = "simple";
      User = "jens";
    };
  };


  systemd.sockets.q-system = {
    wantedBy = [ "multi-user.target" ];
    partOf = [ "q-system.service" ];
    unitConfig = {
      Description = "queezles system daemon socket";
    };
    socketConfig = {
      ListenStream = "/run/q/socket";
      SocketUser = "jens";
    };
  };
  systemd.services.q-system= {
    after = [ "q-system.socket" ];
    requires = [ "q-system.socket" ];
    unitConfig = {
      Description = "queezles system daemon";
    };
    serviceConfig = {
      ExecStart = "${pkgs.q}/bin/q system daemon";
      Type = "simple";
      User = "jens";
    };
  };
}
