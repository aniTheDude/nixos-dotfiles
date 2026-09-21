{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/base.nix
    ../../modules/system/hyprland.nix
    ../../modules/system/fonts.nix
    ../../modules/system/hardware.nix
    ../../modules/system/gaming.nix
    inputs.astra-airlock.nixosModules.default
  ];
}
