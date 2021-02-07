{ stdenv, fetchFromGitHub, pkg-config, alsaLib, glib, json-glib }:

let
  repository = fetchFromGitHub {
    owner = "google";
    repo = "midi-dump-tools";
    rev = "8572e6313a0d7ec95492dcab04a46c5dd30ef33a";
    sha256 = "LQ9LLVumi3GN6c9tuMSOd1Bs2pgrwrLLQbs5XF+NZeA=";
  };
in
  stdenv.mkDerivation {
    pname = "aseq2json";
    version = "git";
    src = "${repository}/aseq2json";

    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ alsaLib glib json-glib ];

    installPhase = ''
      install -D --target-directory "$out/bin" aseq2json
    '';
  }
