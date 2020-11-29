pkgs:

with pkgs;
rec {
  neovim-queezle = import ./neovim { inherit pkgs; };
  simpleandsoft = import ./simpleandsoft { inherit pkgs; };
  netevent = callPackage ./netevent {};
  g810-led = callPackage ./g810-led {};
  gamescope = callPackage ./gamescope {};

  haskell = pkgs.haskell // {
    packageOverrides = self: super: {
      q = self.callPackage ./q {};
      qd = self.callPackage ./qd {};
      qbar = self.callPackage ./qbar {};
    };
  };

  mumble-git = (mumble.overrideAttrs (attrs: {
    src = pkgs.fetchFromGitHub {
      owner = "mumble-voip";
      repo = "mumble";
      rev = "f8ee53688353c8f5e1650504a961ee582ac16668";
      sha256 = "1ifax91w5d0311sx8nkflfih61ccn0vcghyl1j6r8qn96zvz5dzq";
      fetchSubmodules = true;
    };
  }));

  factorio = pkgs.factorio.override {
    username = "Queezle";
    token = "706b6ebdf7539bc7539e55a580c669";
  };

  q = haskellPackages.q;
  qd = haskellPackages.qd;
  qbar = haskellPackages.qbar;
}
