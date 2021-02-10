{
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    #homemanager = {
    #  url = github:nix-community/home-manager;
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    #qauth = {
    #  url = gitlab:jens/qauth?host=git.c3pb.de;
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
  };
  outputs = { ... }: {
    overlay = import ./pkgs;
  };
}
