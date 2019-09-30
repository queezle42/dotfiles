{ lib, config, ... }:

with lib;

{
  options.nixpkgs-jens = {
    enable = mkEnableOption "Load jens nixpkgs channel";
    location = mkOption {
      default = <nixpkgs-jens>;
      type = types.path;
    };
  };
  config = mkIf config.nixpkgs-jens.enable {
    nixpkgs.overlays = [ (import config.nixpkgs-jens.location) ];
  };
}
