{ lib, pkgs, config, ... }:
with lib;
pkgs.writeText "xdg-desktop-portal.config" ''
[screencast]
max_fps=30
chooser_cmd=${pkgs.slurp}/bin/slurp -f %o -or
chooser_type=simple
''
