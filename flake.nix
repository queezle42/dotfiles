{
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;

    nixpkgs-pinephone.url = github:nixos/nixpkgs/nixos-unstable;

    homemanager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    qauth = {
      url = gitlab:jens/qauth?host=git.c3pb.de;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    q = {
      url = gitlab:jens/q?host=git.c3pb.de;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mobile-nixos = {
      url = github:NixOS/mobile-nixos;
      flake = false;
    };
  };

  outputs = inputs_@{ self, nixpkgs, ... }: {
    machine-manager = (import ./machine-manager.nix) {
      flakeInputs = inputs_;
      flakeOutputs = self;
    };
    overlay = import ./pkgs;
  };
}
