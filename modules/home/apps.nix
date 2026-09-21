{ config, pkgs, ... }:

{
  # Firefox web browser
  programs.firefox.enable = true;

  # Graphical user applications and media tools
  home.packages = with pkgs; [
    # Communication (Wayland-native Discord with screen/audio share)
    vesktop

    # Note-taking & Knowledge Base
    obsidian

    # File Management
    xfce.thunar
    xfce.thunar-volman
    xfce.tumbler

    # Media Playback
    mpv
    imv

    # Audio Control & Equalization
    easyeffects
    pavucontrol

    # Streaming & Content Creation
    obs-studio
    krita
    kdenlive
  ];
}
