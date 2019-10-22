{ pkgs, ... }:

let
  all-hies-repo = pkgs.fetchFromGitHub {
    owner = "infinisil";
    repo = "all-hies";
    rev = "0cba12ce4df375766dd183b4beebdee7d8e36e12";
    sha256 = "1f91nrksr2x0zi2kbsy6qf4fmb1ybpx9p55rijhhs05rssk4b0nq";
  };
  all-hies = import all-hies-repo {};

in
{
  environment.systemPackages = with pkgs; [
    stack
    all-hies.latest
  ];
}
