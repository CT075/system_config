# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = [
    { name = "lvm"; device = "/dev/sda3"; preLVM = true; }
  ];

  networking.hostName = "archer"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  fileSystems."/" = {
    mountPoint = "/";
    device = "/dev/mapper/Vol-root";
  };

  fileSystems."/boot" = {
    mountPoint = "/boot";
    device = "/dev/sda2";
  };

  fileSystems."/home" = {
    mountPoint = "/home";
    device = "/dev/mapper/Vol-home";
  };

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "US/Eastern";

  users.defaultUserShell = pkgs.bash;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    zsh vim wget sudo
    gcc gnumake htop tree man lsof tmux
    zip unzip
    alsaLib alsaPlugins alsaUtils
    git curl
    python
    binutils nix
    dmenu
    chromium
  ];

  programs.zsh.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "eurosign:e";
    displayManager = {
      gdm.enable = true;
    };
    desktopManager = {
      gnome3.enable = true;
      default = "gnome3";
    };
    windowManager = {
      xmonad = {
        enable = true;
	enableContribAndExtras = true;
      };
    };
  };

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.kdm.enable = true;
  # services.xserver.desktopManager.kde4.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.cam = {
    isNormalUser = true;
    home = "/home/cam";
    extraGroups = [ "wheel" "networkmanager" "audio" "pulse" ];
    shell = "/run/current-system/sw/bin/zsh";
  };
  # users.extraUsers.guest = {
  #   isNormalUser = true;
  #   uid = 1000;
  # };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";

}
