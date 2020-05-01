{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
  ];

  users = {
    users.dev = {
      uid = 1300;
      isNormalUser = true;
      packages = with pkgs; [
      ];
      dotfiles.profiles = [ "kitty" "vscode" "tmux" ];
    };
  };
}
