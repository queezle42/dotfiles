{ lib, config, pkgs, ... }:
with lib;

{
  options.queezle.rhasspy.server.enable = mkEnableOption "rhasspy server";

  config = mkIf config.queezle.rhasspy.server.enable {

    virtualisation.podman.extraPackages = [ pkgs.crun ];

    virtualisation.oci-containers.backend = "podman";
    virtualisation.oci-containers.containers.rhasspy = {
      image = "rhasspy/rhasspy:2.5.11-amd64";
      imageFile = pkgs.dockerTools.pullImage {
        imageName = "rhasspy/rhasspy";
        finalImageTag = "2.5.11-amd64";
        imageDigest = "sha256:b965c4fb61cf648ce79457dfbe65b92410cb62e64d45c89cc02d60dd95981068";
        sha256 = "sha256-C65qzzTAt3gcJEBNiHNdhCbIGIPyfpkDl95njBIf3/E=";
      };
      volumes = [
        "rhasspy-profiles:/profiles"
      ];
      ports = [
        "127.0.0.1:12101:12101"
      ];
      cmd = [
        "--user-profiles=/profiles"
        "--profile=en"
      ];
      extraOptions = [
        "--device=/dev/snd"
        #"--userns=auto"
      ];
    };
  };
}
