# entry point for machine configurations:
# (import <repo-path> { machinesDir=./machines }).<netname>.configurations.<hostname>

{ machinesDir }:

with builtins;
let
  defaultChannel = (import channels/nixos-unstable);

  # helpers :: { *: ? }
  helpers = import ./helpers.nix;

  # channelsDir :: path
  channelsDir = ./channels;
  # allChannels :: { *: path }
  allChannels = with helpers; keysToAttrs (channelname: import (channelsDir + "/${channelname}")) (readFilterDir (filterAnd [(not filterDirHidden) filterDirDirs]) channelsDir);
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
  mkMachineConfig = { name, path }: (
    import ./configuration.nix {
      inherit name path;
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
in
{
  configurations = withMachines mkMachineConfig;
  nixosSystemDerivations = withMachines mkNixosSystemDerivation;
  machineTemplates = withMachines ({name, path}: import (path + /template.nix));
  channels = machineChannels;
}