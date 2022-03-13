{ pkgs, lib, ... }:

let
  script = pkgs.writeScriptBin "depthai-vm-hotplug" ''
    #!${pkgs.bash}/bin/bash
    set -e

    DOMAIN=depthai-gui

    if [ "''${ACTION}" == 'bind' ]; then
      COMMAND='attach-device'
    elif [ "''${ACTION}" == 'remove' ]; then
      COMMAND='detach-device'
      if [ "''${PRODUCT}" == '3e7/2485/1' ]; then
        ID_VENDOR_ID=03e7
        ID_MODEL_ID=2485
      fi
      if [ "''${PRODUCT}" == '3e7/f63b/100' ]; then
        ID_VENDOR_ID=03e7
        ID_MODEL_ID=f63b
      fi
    else
      echo "Invalid udev ACTION: ''${ACTION}" >&2
      exit 1
    fi
    echo "Running virsh ''${COMMAND} ''${DOMAIN} for ''${ID_VENDOR}." >&2
    ${pkgs.libvirt}/bin/virsh --connect 'qemu:///system' "''${COMMAND}" "''${DOMAIN}" /dev/stdin <<END
    <hostdev mode='subsystem' type='usb'>
      <source>
        <vendor id='0x''${ID_VENDOR_ID}'/>
        <product id='0x''${ID_MODEL_ID}'/>
      </source>
    </hostdev>
    END
    exit 0
  '';
  scriptBin = "${pkgs.systemd}/bin/systemd-cat ${script}/bin/depthai-vm-hotplug";
in {
  services.udev.packages = lib.singleton (pkgs.writeTextFile {
    name = "depthai-udev-rules";
    destination = "/etc/udev/rules.d/90-depthai.rules";
    text = ''
      SUBSYSTEM=="usb", ACTION=="bind", ENV{ID_VENDOR_ID}=="03e7", MODE="0666", RUN+="${scriptBin}"
      SUBSYSTEM=="usb", ACTION=="remove", ENV{PRODUCT}=="3e7/2485/1", ENV{DEVTYPE}=="usb_device", MODE="0666", RUN+="${scriptBin}"
      SUBSYSTEM=="usb", ACTION=="remove", ENV{PRODUCT}=="3e7/f63b/100", ENV{DEVTYPE}=="usb_device", MODE="0666", RUN+="${scriptBin}"
    '';
    #text = ''
    #  SUBSYSTEM=="usb", ATTRS{idVendor}=="03e7", MODE="0666"
    #'';
  });

  #systemd.services.depthai = {
  #  script = "echo Camera connected";
  #  unitConfig = {
  #    Description = "depthai camera service";
  #  };
  #};
}
