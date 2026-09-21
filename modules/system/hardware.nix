{ config, lib, pkgs, ... }:

{
  # Intel Arc B580 (Battlemage) Hardware Graphics Acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };

  # AMD CPU Microcode
  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;

  # ZRAM Compressed Swap (keeps multitasking responsive under memory pressure)
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  # Udev rules for HeadsetControl (allows non-root battery queries for Caelestia)
  services.udev.packages = with pkgs; [
    headsetcontrol
  ];

  # Tailscale mesh VPN
  services.tailscale.enable = true;
}
