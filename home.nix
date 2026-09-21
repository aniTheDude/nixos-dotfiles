{ config, pkgs, inputs, ... }:

{
  imports = [
    ./modules/home/caelestia.nix
    ./modules/home/hyprland.nix
    ./modules/home/neovim.nix
  ];

  home.username = "ani";
  home.homeDirectory = "/home/ani";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    neovim
    ripgrep
    nil
    nixpkgs-fmt
    nodejs
    gcc
    steam
  ];

  programs.git = {
    enable = true;
    userName = "Preston Shumway";
    userEmail = "anidude98@gmail.com";
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo i use nixos with hyprland & caelestia, btw";
    };
  };
}
