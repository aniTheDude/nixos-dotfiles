{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];

  # Enable Caelestia Shell and CLI
  programs.caelestia = {
    enable = true;
    cli.enable = true;
    systemd.enable = true;
  };

  # Link bundled Caelestia configuration files (shell.json, cli.json, plugins, monitors)
  xdg.configFile."caelestia".source = ../../config/caelestia;

  # Make caelestia-keybinds accessible in ~/.local/bin
  home.file.".local/bin/caelestia-keybinds" = {
    source = ../../config/caelestia/plugins/keybinds/caelestia_keybinds.py;
    executable = true;
  };

  # Runtime dependencies for Caelestia plugins & scripts
  home.packages = with pkgs; [
    python3
    headsetcontrol
  ];
}
