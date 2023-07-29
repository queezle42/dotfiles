{ lib, buildGoModule, fetchFromGitea, pkg-config, xorg, libGL }:

buildGoModule rec {
  pname = "itd";
  version = "1.1.0";

  src = fetchFromGitea {
    domain = "gitea.elara.ws";
    owner = "Elara6331";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-95/9Qy0HhrX+ORuv6g1T4/Eq1hf539lYG5fTkLeY6B0=";
  };

  buildInputs = [ xorg.libX11 xorg.libXcursor xorg.libXrandr xorg.libXinerama xorg.libXi xorg.libXext xorg.libXxf86vm libGL ];
  nativeBuildInputs = [ pkg-config ];

  vendorSha256 = "sha256-ZkAxNs4yDUFBhhmIRtzxQlEQtsa/BTuHy0g3taFcrMM=";

  preConfigure = ''
    echo "v${version}" > version.txt
  '';

  meta = with lib; {
    homepage = "https://gitea.elara.ws/Elara6331/itd";
    description = "itd is a daemon that uses my infinitime library to interact with the PineTime smartwatch running InfiniTime.";
    license = with licenses; [ gpl3 ];
  };
}
