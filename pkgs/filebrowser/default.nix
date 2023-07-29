{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "filebrowser";
  version = "2.19.0";

  src = fetchFromGitHub {
    owner = "filebrowser";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-q9Qt6f9gr53vUKe0ylYaMJvYKlGKG9dUQTaQDh+6lKc=";
  };

  vendorSha256 = "sha256-iq7/CUA1uLKk1W8YGAfcdXFpyT2ZBxUxuYOIeO7zVN8=";

  meta = with lib; {
    homepage = "https://github.com/filebrowser/filebrowser";
    description = "Web File Browser";
    license = with licenses; [ asl20 ];
  };
}
