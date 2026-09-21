{ config, pkgs, ... }:

{
  imports = [
    ./modules/neovim.nix
  ];

  home.username = "tony";
  home.homeDirectory = "/home/tony";
  home.file.".config/qtile".source = ./config/qtile;
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

  programs.git.enable = true;
  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo i use nixos, btw";
    };
  };
  
}
