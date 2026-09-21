{ config, lib, pkgs, ... }:

{
  # Link bundled Hyprland Lua dotfiles
  xdg.configFile."hypr".source = ../../config/hypr;

  # Ensure ~/.local/bin is always in PATH
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  # Wayland session environment variables
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
  };

  # Hyprland user tools and utilities
  home.packages = with pkgs; [
    foot
    fzf
    ripgrep
    fd
    jq
  ];
}
