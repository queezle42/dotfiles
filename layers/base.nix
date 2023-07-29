# Basic configuration for all machines

{ pkgs, lib, isMobileNixos, ... }:

with lib;

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

  queezle.common.enable = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  #nix.daemonNiceLevel = 13;
  nix.daemonCPUSchedPolicy = "batch";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = mkDefault "22.05"; # Did you read the comment?

  # Is it worth to specify this where it is needed instead of configuring it globally? Not sure yet.
  nixpkgs.config.allowUnfree = true;

  # Always run the latest kernel
  boot.kernelPackages = mkIf (!isMobileNixos) (mkDefault pkgs.linuxPackages_latest);

  boot.tmp.useTmpfs = mkDefault true;

  # schedutil is a modern replacement for ondemand and conservative that is tied to the scheduler
  # priority 100 is default; mkDefault is priority 1000; the goal here is to prefer schedutil over the auto-generated cpuFreqGovernor
  powerManagement.cpuFreqGovernor = mkOverride 900 "schedutil";

  # Restore systemd default
  services.logind.killUserProcesses = true;

  time.timeZone = "Europe/Berlin";

  # German locale with english messages
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };
    #defaultLocale = "de_DE.UTF-8";
    #extraLocaleSettings = { LC_MESSAGES = "en_US.UTF-8"; };
    supportedLocales = [ "en_US.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8" ];
  };

  console = {
    font = "Lat2-Terminus16";
    #keyMap = "de-latin1-nodeadkeys";
    useXkbConfig = true;
    # Gruvbox tty colors
    #colors = [ "000000" "cc241d" "98971a" "d79921" "458588" "b16286" "689d6a" "a89984" "928374" "fb4934" "b8bb26" "fabd2f" "83a598" "d3869b" "8ec07c" "ebdbb2" ];
    # Kanagawa tty colors
    colors = [ "090618" "c34043" "76946a" "c0a36e" "7e9cd8" "957fb8" "6a9589" "c8c093" "727169" "e82424" "98bb6c" "e6c384" "7fb4ca" "938aa9" "7aa89f" "dcd7ba" ];
  };

  # Bluetooth SIM access profile
  # Gives external devices (e.g. car radio) access to a SIM card (if available)
  hardware.bluetooth.disabledPlugins = [ "sap" ];

  services.xserver = {
    layout = "de";
    xkbModel = "pc105";
    xkbVariant = "nodeadkeys";
    xkbOptions = "caps:escape";
  };

  # I like to be able to carry my laptops with the lid closed while they are still running
  services.logind.lidSwitch = "ignore";

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  programs.ssh.startAgent = true;

  security.sudo.wheelNeedsPassword = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    root

    kitty.terminfo
    foot.terminfo
    git
    gitAndTools.tig
    git-revise
    lazygit
    lf
    fzf
    tree
    htop
    # Enabled by zsh layer
    # tmux
    gotop
    btop

    (inxi.override { withRecommends = true; })
    lm_sensors
    smartmontools
    pciutils
    usbutils
    hdparm
    wireguard-tools

    ripgrep
    fd

    pwgen
    mosquitto
    unzip
    file
    darkhttpd
    ncdu
    duf
    fastmod
    loc
    gotty
    entr
    netevent
    picocom
    pv
    socat
    #reptyr
    ldns
    libfaketime
    moreutils
    viddy
    wol
  ];

  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.zsh;
    users.root = {
      passwordFile = "/etc/secrets/passwords/root";
    };
    users.jens = {
      uid = 1000;
      group = "jens";
      isNormalUser = true;
      passwordFile = "/etc/secrets/passwords/jens";
      extraGroups = [ "wheel" "users" "audio" "dialout" "networkmanager" ];
    };
    groups.jens = {};
    users.containers = {
      isSystemUser = true;
      group = "containers";
      subUidRanges = [{
        startUid = 2147483647;
        count = 2147483648;
      }];
      subGidRanges = [{
        startGid = 2147483647;
        count = 2147483648;
      }];
    };
    groups.containers = {};
  };

  home-manager.users.jens.home.stateVersion = "22.05";
}
