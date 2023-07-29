{ stdenv, fetchFromGitHub, fuse3 }:

stdenv.mkDerivation rec {
  pname = "TabFS";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "osnr";
    repo = pname;
    rev = "09d57f94b507f68ec5e16f53b1cc868fbaf6cceb";
    sha256 = "sha256-PHKRJh8JSBdccW5hJfePhYlbRqe/f4ooKkMvegnB314=";
  };

  buildInputs = [ fuse3 ];
}
