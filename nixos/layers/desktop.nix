{ pkgs, ... }:

{
  imports = [
    ./base.nix
  ];

  environment.systemPackages = with pkgs; [
    glxinfo
    gnome3.gnome-disk-utility
    vscode
    acpilight
  ];

  fonts.fonts = [ pkgs.fira-code ];

  programs.sway_on_tty1.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  users = {
    users.jens = {
      packages = with pkgs; [
        chromium
        tdesktop
        spotify
        pavucontrol
        playerctl
        xdg_utils
      ];
      extraGroups = [
        "video"
      ];
      dotfiles.profiles = [ "kitty" "vscode" ];
    };
  };
}
