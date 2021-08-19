{ lib, pkgs, config, ... }:

with lib;
let
  softKitty = writeScript "kitty-always-software" ''
    LIBGL_ALWAYS_SOFTWARE=true ${pkgs.kitty}/bin/kitty "$@"
  '';
in
{
  options = {
    queezle.terminal.executable = mkOption {
      type = types.path;
      default = if config.queezle.terminal.forceSoftwareRenderer then softKitty else "${pkgs.kitty}/bin/kitty";
    };

    queezle.terminal.forceSoftwareRenderer = mkOption {
      type = types.bool;
      default = false;
    };
  };
}
