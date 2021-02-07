self: super:

rec {
  neovim-queezle = import ./neovim { pkgs = self; };
  simpleandsoft = import ./simpleandsoft { pkgs = self; };
  netevent = self.callPackage ./netevent {};
  g810-led = self.callPackage ./g810-led {};
  gamescope = self.callPackage ./gamescope {};
  greetd = self.callPackage ./greetd {};

  mpv-queezle = self.mpv-with-scripts.override {
    scripts = [ self.mpvScripts.mpris ];
  };

  haskell = super.haskell // {
    packageOverrides = hself: hsuper: {
      #net-mqtt = self.haskell.lib.doJailbreak hsuper.net-mqtt;
      net-mqtt = self.haskell.lib.unmarkBroken hsuper.net-mqtt;
      q = hself.callPackage ./q {};
      qd = hself.callPackage ./qd {};
      qbar = hself.callPackage ./qbar {};
    };
  };

  mumble-git = (self.mumble.overrideAttrs (attrs: {
    src = self.fetchFromGitHub {
      owner = "mumble-voip";
      repo = "mumble";
      rev = "f8ee53688353c8f5e1650504a961ee582ac16668";
      sha256 = "1ifax91w5d0311sx8nkflfih61ccn0vcghyl1j6r8qn96zvz5dzq";
      fetchSubmodules = true;
    };
  }));

  factorio = super.factorio.override {
    username = "Queezle";
    token = "706b6ebdf7539bc7539e55a580c669";
  };

  q = self.haskellPackages.q;
  qd = self.haskellPackages.qd;
  qbar = self.haskellPackages.qbar;
}
