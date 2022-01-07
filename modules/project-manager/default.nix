{ lib, pkgs, ... }:
with lib;

let
  project-launcher = pkgs.writeScriptBin "project-launcher" ''
    #!/usr/bin/env zsh

    set -euo pipefail

    projects=$(jq --raw-output '.projects | keys | .[]' ~/dev/projects.json)

    project=$(dmenu <<<$projects)

    projectpath=$(jq --raw-output ".projects[\"$project\"].path" ~/dev/projects.json)

    terminal --working-directory $projectpath
  '';
in {
  options = {
    queezle.project-manager.enable = mkEnableOption "queezles project manager";
  };

  config = {
    environment.systemPackages = [ project-launcher ];
  };
}
