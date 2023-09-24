{ pkgs, lib, ... }:
with lib;

{
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "tv-serial-udev-rules";
      destination = "/etc/udev/rules.d/90-tv-serial.rules";
      text = ''
        SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", SYMLINK+="tty-tv"
      '';
    })
    (pkgs.writeTextFile {
      name = "hdmi-matrix-serial-udev-rules";
      destination = "/etc/udev/rules.d/90-hdmi-matrix-serial.rules";
      text = ''
        SUBSYSTEM=="tty", ATTRS{idVendor}=="067b", ATTRS{idProduct}=="2303", SYMLINK+="tty-hdmi-matrix"
      '';
    })
  ];
}
