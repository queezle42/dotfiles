{
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;

    nixpkgs-master.url = github:nixos/nixpkgs/master;

    nixpkgs-pinephone.url = github:nixos/nixpkgs/nixos-unstable;
    nixpkgs-pinephone.follows = "nixpkgs";

    homemanager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    qauth = {
      url = gitlab:jens/qauth?host=git.c3pb.de;
    };
    q = {
      url = gitlab:jens/q?host=git.c3pb.de;
    };

    mobile-nixos = {
      url = github:NixOS/mobile-nixos;
      flake = false;
    };

    emacs-overlay.url = github:nix-community/emacs-overlay;
    emacs-term-cursor = {
      url = github:denrat/term-cursor.el;
      flake = false;
    };

    matrix-homeserver.url = github:queezle42/matrix-homeserver;
  };

  outputs = inputs_@{ self, nixpkgs, ... }: {
    machine-manager = (import ./machine-manager.nix) {
      flakeInputs = inputs_;
      flakeOutputs = self;
    };
    overlay = import ./pkgs;
  };
}
