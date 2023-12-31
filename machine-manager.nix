# applied by this repositories flake
{ flakeInputs, flakeOutputs }:
# applied by outer flake
{ extraFlakeInputs, extraFlakeOutputs, machinesDir, extraModules, extraLayersDir, extraOverlays ? [] }:

with builtins;
with flakeInputs.nixpkgs.lib;
let
  finalFlakeInputs = flakeInputs // extraFlakeInputs;
  finalFlakeOutputs = flakeOutputs // extraFlakeOutputs;

  # helpers :: { *: ? }
  helpers = import ./helpers.nix;

  machinesDirContents = readDir machinesDir;
  machineNames = filter (p: machinesDirContents.${p} == "directory") (attrNames machinesDirContents);
  withMachines = lambda: listToAttrs (map (m: {name = m; value = lambda { name = m; path = (machinesDir + "/${m}"); }; }) machineNames);
  evaluateConfig = pkgs: args: (import "${pkgs}/nixos/lib/eval-config.nix" args).config;
  mkNixosSystemDerivations = { name, path }:
    let
      installResult = builtins.fromJSON (builtins.readFile (path + "/install-result.json"));
      nixpkgs = finalFlakeInputs."${installResult.nixpkgs or "nixpkgs"}";
      system = installResult.system or "x86_64-linux";
      mobileNixosDevice = installResult.mobileNixosDevice or null;
      isMobileNixos = mobileNixosDevice != null;
      mkMachineConfig = { name, path, isIso }: {
        imports = [
          (import ./configuration.nix {
            inherit name path isIso extraLayersDir system extraOverlays;
            flakes = finalFlakeInputs;
            nixpkgs = nixpkgs;
          })
          extraModules
        ] ++ optional isMobileNixos (import "${flakeInputs.mobile-nixos}/lib/configuration.nix" { device = mobileNixosDevice; });
        # TODO remove (replaced by "flakes")
        _module.args.flakeInputs = finalFlakeInputs;
        _module.args.flakeOutputs = finalFlakeOutputs;
        _module.args.flakes = finalFlakeInputs;
        _module.args.system = system;
        _module.args.isMobileNixos = isMobileNixos;
      };
      configuration = mkMachineConfig { inherit name path; isIso = false; };
      isoConfiguration = mkMachineConfig { inherit name path; isIso = true; };
      iso = (evaluateConfig nixpkgs {
        inherit system;
        modules = [
          isoConfiguration
          (mkAdditionalIsoConfig name)
        ];
      }).system.build.isoImage;
      systemDerivation = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ configuration ];
      };
    in {
      inherit systemDerivation iso;
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

in
{
  nixosSystemDerivations = withMachines (x: (mkNixosSystemDerivations x).systemDerivation);
  isos = withMachines (x: (mkNixosSystemDerivations x).iso);
  installers = withMachines (
    {name, path}: import ./bin/lib/installation.nix {
      pkgs=flakeInputs.nixpkgs.legacyPackages.x86_64-linux;
      hostname = name;
      template = import (path + /template.nix);
    }
  );
}
