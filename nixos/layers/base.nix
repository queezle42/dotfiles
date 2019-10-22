# Basic configuration for all machines

{ pkgs, ... }:

{
  imports = [
    ./zsh.nix
  ];
  
  # Is it worth to specify this where it is needed instead of configuring it globally? Not sure yet.
  nixpkgs.config.allowUnfree = true;

  # Always run the latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.tmpOnTmpfs = true;

  # Restore systemd default
  services.logind.killUserProcesses = true;

  time.timeZone = "Europe/Berlin";

  # German locale with english messages
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "de-latin1-nodeadkeys";
    defaultLocale = "de_DE.UTF-8";
    extraLocaleSettings = { LC_MESSAGES = "en_US.UTF-8"; };
    supportedLocales = [ "en_US.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8" ];
  };

  # Gruvbox tty colors
  i18n.consoleColors = [ "000000" "cc241d" "98971a" "d79921" "458588" "b16286" "689d6a" "a89984" "928374" "fb4934" "b8bb26" "fabd2f" "83a598" "d3869b" "8ec07c" "ebdbb2" ];

  # I like to be able to carry my laptops with the lid closed while they are still running
  services.logind.lidSwitch = "ignore";
  # I have some machines where the power key can be easily pressed on accident
  services.logind.extraConfig = "HandlePowerKey=ignore";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    kitty
    git
    lf
    fzf
    tree
    htop
    gotop
    inxi
    lm_sensors
    acpi
    pwgen
  ];

  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.zsh;
    users.root = {
      passwordFile = "/q/passwords/root";
    };
    users.jens = {
      uid = 1000;
      isNormalUser = true;
      passwordFile = "/q/passwords/jens";
      extraGroups = [ "wheel" "audio" ];
    };
  };
}
