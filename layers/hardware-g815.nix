{ pkgs, ... }:

{
  systemd.sockets.g810-led = {
    wantedBy = [ "multi-user.target" ];
    partOf = [ "g810-led.service" ];
    unitConfig = {
      Description = "Logitech keyboard led socket";
    };
    socketConfig = {
      ListenStream = "/run/g810-led.socket";
      SocketUser = "jens";
      Accept = "yes";
      MaxConnections = 1;
    };
  };
  systemd.services."g810-led@" = {
    after = [ "g810-led.socket" ];
    requires = [ "g810-led.socket" ];
    bindsTo = [ "g810-led.socket" ];
    unitConfig = {
      Description = "Logitech keyboard led backend";
    };
    serviceConfig = {
      ExecStart = "${pkgs.g810-led}/bin/g810-led -pp";
      StandardInput = "socket";
    };
  };
}
