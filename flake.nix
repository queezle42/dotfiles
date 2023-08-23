{
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;

    #nixpkgs-master.url = github:nixos/nixpkgs/master;

    nixpkgs-pinephone.url = github:nixos/nixpkgs/nixos-unstable;
    nixpkgs-pinephone.follows = "nixpkgs";
    #tow-boot.url = github:Tow-Boot/Tow-Boot/released;
    #tow-boot.flake = false;

    nixpkgs-foot.url = "github:nixos/nixpkgs/684c17c429c42515bafb3ad775d2a710947f3d67";

    nftables-firewall.url = github:thelegy/nixos-nftables-firewall;

    homemanager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    qed.url = github:queezle42/qed;
    matrix-homeserver.url = github:queezle42/matrix-homeserver;

    qauth = {
      url = gitlab:jens/qauth?host=git.c3pb.de;
    };
    q = {
      url = github:queezle42/q;
    };

    qbar.url = gitlab:jens/qbar?host=git.c3pb.de;

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
