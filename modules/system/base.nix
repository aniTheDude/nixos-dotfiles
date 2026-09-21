{ config, lib, pkgs, ... }:

{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixarchy";
  networking.networkmanager.enable = true;

  # Time zone and locale
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  # User account
  users.users.ani = {
    isNormalUser = true;
    description = "Preston Shumway";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "input"
    ];
    packages = with pkgs; [
      tree
    ];
  };

  # Essential system packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    htop
    pciutils
    usbutils
  ];

  # Nix configuration
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  system.stateVersion = "26.05";
}
