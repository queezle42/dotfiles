{ lib, config, pkgs, ... }:
with lib;

let
  tts = pkgs.writeScriptBin "tts" ''
    #!${pkgs.zsh}/bin/zsh

    curl --silent -X POST --data @- 'localhost:59125/api/tts?voice=en_US/hifi-tts_low%2392&lengthScale=1&noiseScale=0.2&noiseW=0.2' | mpv --no-terminal --no-config --no-video -
  '';
in
{
  options.queezle.tts.enable = mkEnableOption "tts server";

  config = mkIf config.queezle.tts.enable {

    virtualisation.oci-containers.backend = "podman";
    virtualisation.oci-containers.containers.tts = {
      image = "mycroftai/mimic3:0.2.3-amd64";
      imageFile = pkgs.dockerTools.pullImage {
        imageName = "mycroftai/mimic3";
        finalImageTag = "0.2.3-amd64";
        imageDigest = "sha256:8213f6d146e9d9d5614f0cdc141403926d2d2a4d1b8d2b24e8179adf74ebc2a2";
        sha256 = "sha256-gVyS6V3IX9K8dpE+777TNHZFdtpImkHQzRx1kOsXfmY=";
      };
      volumes = [
        "mimic3:/home/mimic3/.local/share/mycroft/mimic3"
      ];
      ports = [
        "127.0.0.1:59125:59125"
      ];
      extraOptions = [
        #"--userns=auto"
        "--uidmap=1000:4000:1"
        "--uidmap=0:4001:1"
        "--gidmap=1000:4000:1"
        "--gidmap=0:4001:1"
      ];
    };

    users.users.mimic3 = {
      description = "tts daemon user";
      uid = 4000;
      # also requires uid 4001
      isSystemUser = true;
      group = "mimic3";
    };

    users.groups.mimic3 = {
      gid = 4000;
      # also requires gid 4001
    };

    environment.systemPackages = [ tts ];
  };
}
