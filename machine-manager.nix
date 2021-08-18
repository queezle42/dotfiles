# applied by this repositories flake
{ flakeInputs, flakeOutputs }:
# applied by outer flake
{ extraFlakeInputs, extraFlakeOutputs, machinesDir, extraLayersDir, extraOverlays ? [] }:

with builtins;
with flakeInputs.nixpkgs.lib;
let
  finalFlakeInputs = flakeInputs // extraFlakeInputs;
  finalFlakeOutputs = flakeOutputs // extraFlakeOutputs;
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
  getMachineChannel = _: finalFlakeInputs.nixpkgs;
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
  mkNixosSystemDerivations = { name, path }:
    let
      installResult = builtins.fromJSON (builtins.readFile (path + "/install-result.json"));
      channel = finalFlakeInputs.nixpkgs;
      system = installResult.system or "x86_64-linux";
      mobileNixosDevice = installResult.mobileNixosDevice or null;
      isMobileNixos = mobileNixosDevice != null;
      mkMachineConfig = { name, path, isIso }: {
        imports = [
          (import ./configuration.nix {
            inherit name path isIso extraLayersDir system extraOverlays;
            flakeInputs = finalFlakeInputs;
            flakeOutputs = finalFlakeOutputs;
            channel = machineChannels.${name};
          })
        ] ++ optional isMobileNixos (import "${flakeInputs.mobile-nixos}/lib/configuration.nix" { device = mobileNixosDevice; });
        _module.args.flakeInputs = finalFlakeInputs;
        _module.args.flakeOutputs = finalFlakeOutputs;
        _module.args.system = system;
        _module.args.isMobileNixos = isMobileNixos;
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
      systemDerivation = channel.lib.nixosSystem {
        inherit system;
        modules = [ configuration ];
      };
    in {
      inherit systemDerivation iso sdImage;
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

  nixosSystemDerivations = withMachines (x: (mkNixosSystemDerivations x).systemDerivation);
  isos = withMachines (x: (mkNixosSystemDerivations x).iso);
  sdImages = withMachines (x: (mkNixosSystemDerivations x).sdImage);
  installers = withMachines (
    {name, path}: import ./bin/lib/installation.nix {
      pkgs=flakeInputs.nixpkgs.legacyPackages.x86_64-linux;
      hostname = name;
      template = import (path + /template.nix);
    }
  );
}
