{ config, lib, pkgs, ... }:
{}

#{
#  inputs."nixpkgs".url = github:NixOS/nixpkgs/nixos-unstable;
#
#  outputs = { self, nixpkgs }:
#  with nixpkgs.lib;
#  let
#    systems = platforms.unix;
#    forAllSystems = genAttrs systems;
#  in {
#    devShell = forAllSystems (system: let
#      pkgs = nixpkgs.legacyPackages.${system};
#
#      # https://github.com/tidalcycles/vim-tidal
#      vim-tidal = pkgs.vimUtils.buildVimPlugin {
#        name = "vim-tidal";
#        src = pkgs.fetchFromGitHub {
#          owner = "tidalcycles";
#          repo = "vim-tidal";
#          rev = "1.4.8";
#          sha256 = "sha256-c12v9+s/JspQ9Am291RFI7eg0UAeXGDvJ5lK+7ukOb0=";
#        };
#        patchPhase = "rm Makefile";
#      };
#
#    in pkgs.mkShell {
#      packages = with pkgs; [
#        vim-tidal tmux
#        haskell-language-server
#        (haskellPackages.ghcWithPackages (f: with f; [
#          tidal
#        ]))
#
#        supercollider-with-sc3-plugins
#        # then, start `sclang` and run
#        #  - Quarks.checkForUpdates({Quarks.install("SuperDirt", "v1.7.2"); thisProcess.recompile()})
#        #  - include('SuperDirt'); SuperDirt.start
#
#      ];
#    });
#  };
#}
