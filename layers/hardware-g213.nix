{ pkgs, lib, ... }:

{
  services.udev.packages = lib.singleton (pkgs.writeTextFile {
    name = "g213-udev-rules";
    destination = "/etc/udev/rules.d/91-g213.rules";
    text = ''
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c336", TAG+="systemd", ENV{SYSTEMD_WANTS}="g213.service"
    '';
  });

  systemd.services.g213= {
    script = "sleep 1s; ${pkgs.g810-led}/bin/g213-led -dp c336 -a ff0000";
    unitConfig = {
      Description = "g213 led preset";
    };
  };
}
