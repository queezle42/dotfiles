{ stdenv, fetchFromGitHub, meson, pkgconfig, ninja, libdrm, libX11, pixman, libuv, libGL, libxkbcommon, wayland, neatvnc }:

with builtins;

let
  repo = fromJSON ( readFile ./repo.json );
in
stdenv.mkDerivation {
  pname = "wayvnc";
  version = repo.rev;

  src = fetchFromGitHub repo;

  nativeBuildInputs = [
    pkgconfig meson ninja
  ];

  buildInputs = [
    pixman libuv libGL libxkbcommon wayland neatvnc libdrm libX11
  ];

  enableParallelBuilding = true;

  # mesonFlags = [
  #   "-Ddefault-wallpaper=false" "-Dxwayland=enabled" "-Dgdk-pixbuf=enabled"
  #   "-Dtray=enabled" "-Dman-pages=enabled"
  # ];

  # meta = with stdenv.lib; {
  #   description = "i3-compatible tiling Wayland compositor";
  #   homepage    = https://swaywm.org;
  #   license     = licenses.mit;
  #   platforms   = platforms.linux;
  #   maintainers = with maintainers; [ primeos synthetica ma27 ];
  # };
}