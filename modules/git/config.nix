{ lib, pkgs, config, ... }:
with lib;
pkgs.writeText "git-config" ''
[user]
  email = git@queezle.net
  name = Jens Nolte

[init]
  defaultBranch = main

[commit]
  verbose = true
  template = ~/.config/git/commit-template

[alias]
  graph = log --graph --decorate --all --format=format:'%C(yellow)%h%C(reset) %C(red)%aN%C(reset) %C(dim cyan)(%ar)%C(reset)%C(dim magenta)%d%C(reset)%n%C(white)%s%C(reset)'

  g = !git graph

[diff]
  colorMoved = true
  colorMovedWS = ignore-space-change

[blame]
  coloring = highlightRecent
''
