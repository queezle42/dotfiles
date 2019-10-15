{ mkDerivation, aeson, async, attoparsec, base, bytestring, colour
, concurrent-extra, directory, fetchgit, filepath, hpack, mtl
, network, optparse-applicative, pipes, pipes-aeson
, pipes-concurrency, pipes-network, pipes-parse, stdenv, stm, text
, time, typed-process, unix, unordered-containers
}:
mkDerivation {
  pname = "qbar";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://git.c3pb.de/jens/qbar";
    sha256 = "1bf4ff522fp7rhhw3rnz6mc2iy9yf8dgbj3705wfdnbviaxcixaa";
    rev = "ccc975c4bbac56e212d6dddc070ee345d0c14000";
    fetchSubmodules = true;
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    aeson async attoparsec base bytestring colour concurrent-extra
    directory filepath mtl network optparse-applicative pipes
    pipes-aeson pipes-concurrency pipes-network pipes-parse stm text
    time typed-process unix unordered-containers
  ];
  libraryToolDepends = [ hpack ];
  executableHaskellDepends = [
    aeson async attoparsec base bytestring colour concurrent-extra
    directory filepath mtl network optparse-applicative pipes
    pipes-aeson pipes-concurrency pipes-network pipes-parse stm text
    time typed-process unix unordered-containers
  ];
  testHaskellDepends = [
    aeson async attoparsec base bytestring colour concurrent-extra
    directory filepath mtl network optparse-applicative pipes
    pipes-aeson pipes-concurrency pipes-network pipes-parse stm text
    time typed-process unix unordered-containers
  ];
  prePatch = "hpack";
  license = stdenv.lib.licenses.bsd3;
}
