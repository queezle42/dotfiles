# entry point for machine configurations:
# (import <repo-path> { machinesDir=./machines }).<netname>.configurations.<hostname>

{ machinesDir, extraLayersDir }:

with builtins;
let
  # defaultChannel :: path (channel)
  defaultChannel = loadChannel "nixos-unstable";

  # helpers :: { *: ? }
  helpers = import ./helpers.nix;

  # channelsDir :: path
  channelsDir = ./channels;
  # loadChannel :: string -> path (channel)
  loadChannel = name: import (channelsDir + "/${name}") name;
  # allChannels :: { *: path (channel) }
  allChannels = with helpers; keysToAttrs loadChannel (readFilterDir (filterAnd [(not filterDirHidden) filterDirDirs]) channelsDir);
  # getMachineChannel :: string -> path
  getMachineChannel = { name, path }:
    let
      channelFile = path + "/channel.nix";
    in
      if (pathExists channelFile)
        then (import channelFile) allChannels
        else defaultChannel;
  # machineChannels :: { *: path }
  machineChannels = withMachines getMachineChannel;

  machinesDirContents = readDir machinesDir;
  machineNames = filter (p: machinesDirContents.${p} == "directory") (attrNames machinesDirContents);
  withMachines = lambda: listToAttrs (map (m: {name = m; value = lambda { name = m; path = (machinesDir + "/${m}"); }; }) machineNames);
  mkMachineConfig = { name, path, isIso ? false }: (
    import ./configuration.nix {
      inherit name path isIso extraLayersDir;
      channel = machineChannels.${name};
    }
  );
  mkNixosSystemDerivation = { name, path }:
    let
      channel = machineChannels.${name};
      configuration = mkMachineConfig { inherit name path; };
      # Importing <nixpkgs/nixos> results in a nixos system closure
      nixos = import "${channel}/nixos" {
        system = "x86_64-linux";
        inherit configuration;
      };
    in
      nixos.system;
  mkNixosIsoDerivation = { name, path }:
    let
      channel = machineChannels.${name};
      configuration = { config, ... }:
      {
        imports = [
          (mkMachineConfig { inherit name path; isIso = true; })
          <nixpkgs/nixos/modules/installer/cd-dvd/iso-image.nix>
          <nixpkgs/nixos/modules/profiles/all-hardware.nix>
          <nixpkgs/nixos/modules/profiles/base.nix>
        ];
        isoImage.isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-isohost-${name}.iso";
        isoImage.volumeID = substring 0 11 "NIXOS_ISO";

        isoImage.makeEfiBootable = true;
        isoImage.makeUsbBootable = true;
        boot.loader.grub.memtest86.enable = true;

      };
      # Importing <nixpkgs/nixos> results in a nixos system closure
      nixos = import "${channel}/nixos" {
        system = "x86_64-linux";
        inherit configuration;
      };
    in
      nixos.config.system.build.isoImage;

in
{
  configurations = withMachines mkMachineConfig;
  nixosSystemDerivations = withMachines mkNixosSystemDerivation;
  nixosIsoDerivations = withMachines mkNixosIsoDerivation;
  machineTemplates = withMachines ({name, path}: import (path + /template.nix));
  channels = machineChannels;
}
