{ pkgs, ... }:

let
  all-hies-repo = pkgs.fetchFromGitHub (builtins.fromJSON (builtins.readFile ./all-hies.json));
  all-hies = import all-hies-repo {};
in
{
  haskell-ide-engine = all-hies.latest;
}