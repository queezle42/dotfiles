{ lib, rustPlatform, fetchurl, scdoc, gnused, installShellFiles, pam }:

rustPlatform.buildRustPackage rec {
  pname = "greetd";
  version = "0.7.0";

  src = fetchurl {
    url = "https://git.sr.ht/~kennylevinsen/${pname}/archive/${version}.tar.gz";
    sha256 = "sha256-Uim38AvkAYfenfYkD8Ox9AEt1eR3e7hmEBbMfCwQXfc=";
  };

  cargoSha256 = "w6d8rIc03Qa2/TpztpyVijjd3y0Vo38+JDhsOkSFG5E=";

  nativeBuildInputs = [ scdoc installShellFiles ];
  buildInputs = [ pam ];

  postBuild = ''
    for i in man/*
    do
      # drop file extension, replace last '-' with '.'
      targetname="$(echo "''${i%%.*}" | sed -r 's/(.*)-/\1\./')"
      scdoc < "$i" > "$targetname"
      installManPage "$targetname"
    done
  '';

  meta = with lib; {
    description = "A login manager daemon";
    homepage = "https://git.sr.ht/~kennylevinsen/greetd";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ metadark ];
  };
}
