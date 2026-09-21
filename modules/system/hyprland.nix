{ config, lib, pkgs, ... }:

{
  # Enable Hyprland compositor with UWSM session support
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # Display Manager: Ly (TUI display manager)
  services.displayManager.ly.enable = true;

  # XDG Desktop Portals
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  # PipeWire Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Bluetooth support
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Security & Polkit
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # Polkit authentication agent systemd user service
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # Location provider for night light
  services.geoclue2.enable = true;

  # Power profiles & brightness control
  services.power-profiles-daemon.enable = true;
  programs.light.enable = true;

  # Desktop environment & Wayland system packages
  environment.systemPackages = with pkgs; [
    # Wayland / Hyprland tooling
    wl-clipboard
    cliphist
    brightnessctl
    playerctl
    libnotify
    grim
    slurp
    swappy
    gammastep
    polkit_gnome

    # Terminal emulators
    foot
    alacritty
  ];
}
