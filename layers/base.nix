# Basic configuration for all machines

{ pkgs, lib, ... }:

{
  imports = [
    ./zsh.nix
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = lib.mkDefault "19.09"; # Did you read the comment?

  # Is it worth to specify this where it is needed instead of configuring it globally? Not sure yet.
  nixpkgs.config.allowUnfree = true;

  # Always run the latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.tmpOnTmpfs = true;

  # Restore systemd default
  services.logind.killUserProcesses = true;

  # Freezes on shutdown on some machines. Also probably should only be enabled when required?
  security.rngd.enable = lib.mkDefault false;

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
    neovim
    git
    gitAndTools.tig
    lf
    fzf
    tree
    htop
    killall
    tmux
    gotop
    inxi
    lm_sensors
    acpi
    ldns
    pwgen
    mosquitto
    gopass
    unzip
    file
    darkhttpd
    ncdu
    ripgrep
    fd
    loc
    gotty
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
      extraGroups = [ "wheel" "audio" "dialout" ];
    };
  };
}