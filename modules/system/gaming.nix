{ config, lib, pkgs, ... }:

{
  # Steam configuration with firewall rules for streaming / multiplayer
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  # Feral GameMode for performance optimizations during gaming
  programs.gamemode.enable = true;

  # Virtualization & gaming utilities
  environment.systemPackages = with pkgs; [
    quickemu
    qemu
    mangohud
  ];
}
