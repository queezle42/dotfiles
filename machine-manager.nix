# entry point for machine configurations:
# (import <repo-path> { machinesDir=./machines }).<netname>.configurations.<hostname>

{ flakeInputs, flakeOutputs, machinesDir, extraLayersDir }:

with builtins;
let
  # defaultChannel :: path (channel)
  #defaultChannel = loadChannel "nixos-unstable";

  # helpers :: { *: ? }
  helpers = import ./helpers.nix;

  # channelsDir :: path
  #channelsDir = ./channels;
  # loadChannel :: string -> path (channel)
  #loadChannel = name: import (channelsDir + "/${name}") name;
  # allChannels :: { *: path (channel) }
  #allChannels = with helpers; keysToAttrs loadChannel (readFilterDir (filterAnd [(not filterDirHidden) filterDirDirs]) channelsDir);
  # getMachineChannel :: string -> path
  getMachineChannel = _: flakeInputs.nixpkgs;
  #getMachineChannel = { name, path }:
  #  let
  #    channelFile = path + "/channel.nix";
  #  in
  #    if (pathExists channelFile)
  #      then (import channelFile) allChannels
  #      else defaultChannel;
  # machineChannels :: { *: path }
  machineChannels = withMachines getMachineChannel;

  machinesDirContents = readDir machinesDir;
  machineNames = filter (p: machinesDirContents.${p} == "directory") (attrNames machinesDirContents);
  withMachines = lambda: listToAttrs (map (m: {name = m; value = lambda { name = m; path = (machinesDir + "/${m}"); }; }) machineNames);
  evaluateConfig = pkgs: args: (import "${pkgs}/nixos/lib/eval-config.nix" args).config;
  mkNixosSystemDerivation = { name, path }:
    let
      channel = flakeInputs.nixpkgs;
      system = "x86_64-linux";
      mkMachineConfig = { name, path, isIso }: {
        imports = [
          (import ./configuration.nix {
            inherit name path isIso extraLayersDir flakeInputs flakeOutputs;
            channel = machineChannels.${name};
          })
        ];
        _module.args.flakeInputs = flakeInputs;
        _module.args.flakeOutputs = flakeOutputs;
        _module.args.system = system;
      };
      configuration = mkMachineConfig { inherit name path; isIso = false; };
      isoConfiguration = mkMachineConfig { inherit name path; isIso = true; };
      iso = (evaluateConfig channel {
        inherit system;
        modules = [
          isoConfiguration
          (mkAdditionalIsoConfig name)
        ];
      }).system.build.isoImage;
      sdImage = (evaluateConfig channel {
        inherit system;
        modules = [
          isoConfiguration
          (mkAdditionalSdCardConfig name)
        ];
      }).system.build.sdImage;
    in
    channel.lib.nixosSystem {
      inherit system;
      modules = [
        configuration
        {
          system.build = {
            inherit iso sdImage;
          };
        }
      ];
    };
  mkAdditionalIsoConfig = name: { config, modulesPath, ... }: {
    imports = [
      "${modulesPath}/installer/cd-dvd/iso-image.nix"
      "${modulesPath}/profiles/all-hardware.nix"
      "${modulesPath}/profiles/base.nix"
    ];
    isoImage.isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-isohost-${name}.iso";
    isoImage.volumeID = substring 0 11 "NIXOS_ISO";
    isoImage.makeEfiBootable = true;
    isoImage.makeUsbBootable = true;
    boot.loader.grub.memtest86.enable = true;
    _module.args.isIso = true;
  };
  mkAdditionalSdCardConfig = name: { config, modulesPath, ... }: {
    imports = [
      "${modulesPath}/installer/cd-dvd/sd-image.nix"
      "${modulesPath}/profiles/all-hardware.nix"
      "${modulesPath}/profiles/base.nix"
    ];
    sdImage.populateRootCommands = "";
    sdImage.populateFirmwareCommands = "";
    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible.enable = true;
    _module.args.isIso = true;
  };

in
{
  # TODO remove
  # configurations = withMachines mkMachineConfig;
  # nixosIsoDerivations = withMachines mkNixosIsoDerivation;
  # channels = machineChannels;

  nixosSystemDerivations = withMachines mkNixosSystemDerivation;
  machineTemplates = withMachines ({name, path}: import (path + /template.nix));
}
