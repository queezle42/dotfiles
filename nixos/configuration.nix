# This is the entry point for my NixOS configuration.
{ name, path, channel }:
{ lib, config, pkgs, ... }:

let
  installResult = builtins.fromJSON (builtins.readFile (path + "/install-result.json"));
  dotfilesConfig = import (path + "/dotfiles.nix");
  layerImports = map (l: ./layers + "/${l}.nix") dotfilesConfig.layers;
in
{
  imports = [
    ./modules
    (path + "/configuration.nix")
    (path + "/hardware-configuration.nix")
  ] ++ layerImports;

  nixpkgs.config = {
    packageOverrides = ( import ./pkgs ) { inherit lib config; } ;
  };

  # Pin channel in nix path
  nix.nixPath = [ "nixpkgs=${channel}" ];

  # Bootloader
  boot.loader.systemd-boot.enable = (installResult.bootloader == "efi");
  boot.loader.efi.canTouchEfiVariables = (installResult.bootloader == "efi");
  boot.loader.grub.enable = (installResult.bootloader == "grub");
  boot.loader.grub.device = installResult.installedBlockDevice;

  # Default hostname ist machine directory name
  networking.hostName = lib.mkDefault name;

  boot.initrd.luks.devices = if installResult.luks then {
    cryptvol = {
      device = "/dev/disk/by-uuid/" + installResult.luksPartitionUuid;
      allowDiscards = true;
    };
  } else {};
}
