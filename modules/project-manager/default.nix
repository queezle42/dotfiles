{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.queezle.project-manager;
  project-launcher = pkgs.writeScriptBin "project-launcher" ''
    #!/usr/bin/env zsh

    set -euo pipefail

    readonly index_file=/srv/sync/dev/projects.json

    projects=$(jq --raw-output '.projects | keys | .[]' $index_file)

    project=$(dmenu <<<$projects)

    projectpath=$(jq --raw-output ".projects[\"$project\"].path" $index_file)

    exec terminal --working-directory $projectpath
  '';
in {
  options = {
    queezle.project-manager = {
      enable = mkEnableOption "queezles project manager";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ project-launcher ];
  };
}
