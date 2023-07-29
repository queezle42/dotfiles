{ lib, pkgs, config, ... }:

with lib;
let
  terminal = pkgs.writeScriptBin "terminal" ''
    PROMPT_NO_INITIAL_NEWLINE=1 ${config.queezle.terminal.executable} "$@"
  '';
  terminal2 = pkgs.writeScriptBin "terminal2" ''
    PROMPT_NO_INITIAL_NEWLINE=1 ${config.queezle.terminal.alt.executable} "$@"
  '';
  # FIXME foot-specific config is used to change the background color of floating terminals
  terminal-floating = pkgs.writeScriptBin "terminal-floating" ''
    PROMPT_NO_INITIAL_NEWLINE=1 ${config.queezle.terminal.executable} --app-id terminal-floating --config ~/.config/foot/foot-floating.ini "$@"
  '';
in
{
  options = {
    queezle.terminal.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Install a 'terminal' and 'terminal2' wrapper script that launches the configured terminal emulator.";
    };

    queezle.terminal.executable = mkOption {
      type = types.path;
      default = "${pkgs.foot}/bin/foot";
    };

    queezle.terminal.alt.executable = mkOption {
      type = types.path;
      default = if config.queezle.terminal.forceSoftwareRenderer then "${pkgs.foot}/bin/foot" else "${pkgs.kitty}/bin/kitty";
    };

    queezle.terminal.forceSoftwareRenderer = mkOption {
      type = types.bool;
      default = false;
    };
  };
  config = mkIf config.queezle.terminal.enable {
    environment.systemPackages = [
      terminal
      terminal2
      terminal-floating
      pkgs.foot
    ] ++ optional (!config.queezle.terminal.forceSoftwareRenderer) pkgs.kitty;
  };
}
