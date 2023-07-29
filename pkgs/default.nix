final: prev:

rec {
  #terraria-server = prev.terraria-server.overrideAttrs (attrs: {
  #  version = "1.4.4.9";
  #  src = final.fetchurl {
  #    url = "https://terraria.org/api/download/pc-dedicated-server/terraria-server-1449.zip";
  #    sha256 = "sha256-Mk+5s9OlkyTLXZYVT0+8Qcjy2Sb5uy2hcC8CML0biNY=";
  #  };
  #});

  simpleandsoft = import ./simpleandsoft { pkgs = final; };
  netevent = final.callPackage ./netevent {};
  g810-led = final.callPackage ./g810-led {};

  pragmatapro = final.callPackage ./pragmatapro {};

  itd = final.callPackage ./itd {};

  tabfs = final.callPackage ./tabfs {};

  mpv-queezle = final.wrapMpv final.mpv-unwrapped {
    scripts = [ final.mpvScripts.mpris ];
  };

  jellyfin-mpv-shim-queezle = final.writeScriptBin "jellyfin-mpv-shim" ''
    #!${final.zsh}/bin/zsh

    set -euo pipefail

    readonly config_file=.config/jellyfin-mpv-shim/conf.json

    if [[ ! -e $config_file ]] {
      mkdir -p $(dirname $config_file)
      echo '{}' > $config_file
    }

    jq '. + {
      mpv_ext: true
    }' $config_file | sponge $config_file

    path=("${final.mpv-queezle}/bin" $path)
    exec ${final.jellyfin-mpv-shim}/bin/jellyfin-mpv-shim $@
  '';

  #haskell = prev.haskell // {
  #  packageOverrides = hfinal: hprev: prev.haskell.packageOverrides hfinal hprev // {
  #    net-mqtt = final.haskell.lib.doJailbreak hprev.net-mqtt;
  #    net-mqtt = final.haskell.lib.unmarkBroken hprev.net-mqtt;
  #  };
  #};

  mumble-git = (final.mumble.overrideAttrs (attrs: {
    src = final.fetchFromGitHub {
      owner = "mumble-voip";
      repo = "mumble";
      rev = "f8ee53688353c8f5e1650504a961ee582ac16668";
      sha256 = "1ifax91w5d0311sx8nkflfih61ccn0vcghyl1j6r8qn96zvz5dzq";
      fetchSubmodules = true;
    };
  }));

  foot = (prev.foot.overrideAttrs (attrs: {
    # Colored and styled underlines
    # https://codeberg.org/dnkl/foot/pulls/1099
    src = final.fetchFromGitea {
      domain = "codeberg.org";
      owner = "dnkl";
      repo = "foot";
      rev = "b9c8d68845251419377a9b402c912e0f1e983031";
      sha256 = "sha256-O9K8Uo5Wc3turFptTg84AUlfIIiWdfx2spsCFYwSPDM=";
    };
    mesonFlags = attrs.mesonFlags ++ [ "-Dext-underline=true" ];
    CFLAGS=["-Wno-error=missing-profile"];
  }));

  #lapce-git = (final.lapce.overrideAttrs (drv: rec {
  #  src = final.fetchFromGitHub {
  #    owner = "lapce";
  #    repo = "lapce";
  #    rev = "ada8499e1e17e90c8a62983cb7b3cbae5749c7ab";
  #    sha256 = "sha256-smyXSQmjSsJxKjGCA4OoQTQc9F8r4xF2/XCUMnhm9Dw=";
  #  };

  #  cargoDeps = drv.cargoDeps.overrideAttrs (_: {
  #    inherit src;
  #    outputHash = "sha256-S593nuXsxNAx1TQDV4cyEG1OHeDkgsWTWCKDSZ+grnM=";
  #  });

  #  buildInputs = drv.buildInputs ++ [ final.gtk3 ];
  #}));
}
