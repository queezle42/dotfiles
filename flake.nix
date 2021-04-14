{
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;

    homemanager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    qauth = {
      url = gitlab:jens/qauth?host=git.c3pb.de;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    qd = {
      url = gitlab:jens/qd?host=git.c3pb.de;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    q = {
      url = gitlab:jens/q?host=git.c3pb.de;
      inputs.qd.follows = "qd";
      inputs.nixpkgs.follows = "qd/nixpkgs";
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
