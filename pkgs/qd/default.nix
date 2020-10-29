{ haskell, fetchgit, callCabal2nix }:

let
  repo = with builtins; fromJSON ( readFile ./repo.json );
  src = fetchgit {
    inherit (repo) url rev sha256;
  };
in
haskell.lib.generateOptparseApplicativeCompletions ["qd" "qctl"] (
  callCabal2nix "qd" src {}
)
