# This is the entry point for my NixOS configuration.
{ name, path, channel, isIso, extraLayersDir }:
{ lib, config, pkgs, ... }:

let
  installResult = builtins.fromJSON (builtins.readFile (path + "/install-result.json"));
  dotfilesConfig = import (path + "/dotfiles.nix");
  layerPath = layerName: let
    filePath = ./layers + "/${layerName}.nix";
    dirPath = ./layers + "/${layerName}";
    extraDirFilePath = extraLayersDir + "/${layerName}.nix";
    extraDirDirPath = extraLayersDir + "/${layerName}";
  in
  if builtins.pathExists filePath
    then filePath
    else if builtins.pathExists dirPath
      then dirPath
      else if builtins.pathExists extraDirFilePath
        then extraDirFilePath
        else if builtins.pathExists extraDirDirPath
          then extraDirDirPath
          else builtins.throw "Cannot find layer `${layerName}`";

  layerImports = map layerPath dotfilesConfig.layers;
in
({
  imports = [
    ./modules
    (path + "/configuration.nix")
  ] ++ layerImports ++ (lib.lists.optional (!isIso) (path + "/hardware-configuration.nix"));

  nixpkgs.config = {
    packageOverrides = import ./pkgs;
  };

  # Pin channel in nix path
  nix.nixPath = [ "nixpkgs=${channel}" ];
  # Make nixpkgs path available inside of the configuration
  _module.args.nixpkgsPath = channel;

  environment.shellAliases = {
    # nixos-option won't run without a configuration. With an empty config it does not show configured values, but can at least be used to search options and show default values.
    nixos-option = "nixos-option -I nixos-config=${pkgs.writeText "empty-configuration.nix" "{...}:{}"}";
  };

  # Default hostname ist machine directory name
  networking.hostName = lib.mkDefault name;

} // (lib.attrsets.optionalAttrs (!isIso) {
  # Bootloader
  boot.loader.systemd-boot.enable = (installResult.bootloader == "efi");
  boot.loader.efi.canTouchEfiVariables = (installResult.bootloader == "efi");
  boot.loader.grub.enable = (installResult.bootloader == "bios");
  boot.loader.grub.device = installResult.installedBlockDevice;

  boot.initrd.luks.devices = if installResult.luks then {
    cryptvol = {
      device = "/dev/disk/by-uuid/" + installResult.luksPartitionUuid;
      allowDiscards = true;
    };
  } else {};
}))
