{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    man-pages
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
