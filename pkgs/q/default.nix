{ haskell, fetchgit, callCabal2nix }:

let
  repo = with builtins; fromJSON ( readFile ./repo.json );
  src = fetchgit {
    inherit (repo) url rev sha256;
  };
in
haskell.lib.generateOptparseApplicativeCompletion "q" (
  callCabal2nix "q" src {}
)
