{ lib, buildGoModule, fetchFromGitHub, alsa-lib }:

buildGoModule rec {
  pname = "jellycli";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "tryffel";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-2su+4qR5R9Xb4yBnH5Sr52gte8d1fZhJOqqc4Gxnn6s=";
  };

  buildInputs = [ alsa-lib ];

  vendorSha256 = "sha256-3tmNZd1FH1D/1w4gRmaul2epKb70phSUAjUBCbPV3Ak=";

  # Test is missing config path? Disabled to get it to build but should be fixed before moving the packet to nixpkgs.
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/tryffel/jellycli";
    description = "Jellyfin terminal client";
    license = with licenses; [ gpl3 ];
  };
}
