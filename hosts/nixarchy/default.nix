{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/base.nix
    ../../modules/system/hyprland.nix
    ../../modules/system/fonts.nix
  ];
}
