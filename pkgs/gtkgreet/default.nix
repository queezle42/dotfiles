{ lib, stdenv, fetchurl, scdoc, meson, ninja, pkg-config, gtk3, gtk-layer-shell, json_c }:

stdenv.mkDerivation rec {
  pname = "gtkgreet";
  version = "0.7";

  src = fetchurl {
    name = "${pname}-${version}.tar.gz";
    url = "https://git.sr.ht/~kennylevinsen/${pname}/archive/${version}.tar.gz";
    sha256 = "sha256-60ug4eT5z4iM57kyuSP5dSHCJ3AyYoz8BruG/sutk3M=";
  };

  nativeBuildInputs = [ meson ninja pkg-config scdoc ];
  buildInputs = [ gtk3 gtk-layer-shell json_c ];

  meta = with lib; {
    description = "GTK based greeter for greetd, to be run under cage or similar";
    homepage = "https://git.sr.ht/~kennylevinsen/gtkgreet";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ queezle ];
  };
}
