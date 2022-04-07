{ lib, buildGoModule, fetchFromGitea, pkg-config, xorg, libglvnd }:

buildGoModule rec {
  pname = "itd";
  version = "unstable";

  src = fetchFromGitea {
    domain = "gitea.arsenm.dev";
    owner = "Arsen6331";
    repo = pname;
    rev = "365414f951fab2ca378855beeef6a624a4158186";
    sha256 = "sha256-Hosg8ftyxs7HFNrPRBVM8NTJBXMc65mXnrxNN8qyU7g=";
  };

  buildInputs = [ xorg.libX11 xorg.libXcursor xorg.libXrandr xorg.libXinerama xorg.libXi xorg.libXext xorg.libXxf86vm libglvnd ];
  nativeBuildInputs = [ pkg-config ];

  vendorSha256 = "sha256-wi8GIXPeAD3RRcNNJgULoeUt9fURsRBVbaizl++ux7Q=";

  meta = with lib; {
    homepage = "https://gitea.arsenm.dev/Arsen6331/itd";
    description = "itd is a daemon that uses my infinitime library to interact with the PineTime snartwatch running InfiniTime.";
    license = with licenses; [ gpl3 ];
  };
}
