# Basic configuration for all machines

{ pkgs, lib, ... }:

let
  root = pkgs.writeShellScriptBin "root" ''
    if [ -n "$1" ] ; then
      TUSER="$1"
    else
      TUSER="root"
    fi
    shell="$(getent passwd "$TUSER" 2>/dev/null | { IFS=: read _ _ _ _ _ _ x; echo "$x"; })"
    exec machinectl shell --setenv=SHELL="$shell" "$TUSER@" "$shell" --login -i
  '';
in
{
  imports = [
    ./zsh.nix
    ./ioschedulers.nix
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = lib.mkDefault "20.09"; # Did you read the comment?

  # Is it worth to specify this where it is needed instead of configuring it globally? Not sure yet.
  nixpkgs.config.allowUnfree = true;

  # Always run the latest kernel
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  boot.tmpOnTmpfs = true;

  powerManagement.cpuFreqGovernor = "ondemand";

  # Restore systemd default
  services.logind.killUserProcesses = true;

  time.timeZone = "Europe/Berlin";

  # German locale with english messages
  i18n = {
    defaultLocale = "de_DE.UTF-8";
    extraLocaleSettings = { LC_MESSAGES = "en_US.UTF-8"; };
    supportedLocales = [ "en_US.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8" ];
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "de-latin1-nodeadkeys";
    # Gruvbox tty colors
    colors = [ "000000" "cc241d" "98971a" "d79921" "458588" "b16286" "689d6a" "a89984" "928374" "fb4934" "b8bb26" "fabd2f" "83a598" "d3869b" "8ec07c" "ebdbb2" ];
  };

  # I like to be able to carry my laptops with the lid closed while they are still running
  services.logind.lidSwitch = "ignore";
  # I have some machines where the power key can be easily pressed on accident
  services.logind.extraConfig = "HandlePowerKey=ignore";

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;

  programs.ssh.startAgent = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    root

    kitty.terminfo
    neovim-queezle
    git
    gitAndTools.tig
    git-revise
    lf
    fzf
    tree
    htop
    killall
    # Enabled by zsh layer
    # tmux
    gotop

    (inxi.override { withRecommends = true; })
    lm_sensors

    pwgen
    mosquitto
    unzip
    file
    darkhttpd
    ncdu
    ripgrep
    fd
    fastmod
    loc
    gotty
    entr
    netevent
    picocom
    pv
    socat
    reptyr
  ];

  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.zsh;
    users.root = {
      passwordFile = "/etc/secrets/passwords/root";
    };
    users.jens = {
      uid = 1000;
      isNormalUser = true;
      passwordFile = "/etc/secrets/passwords/jens";
      extraGroups = [ "wheel" "audio" "dialout" "networkmanager" ];
      dotfiles.profiles = [ "base" ];
    };
  };
}
