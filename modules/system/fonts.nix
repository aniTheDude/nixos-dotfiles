{ config, lib, pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.cascadia-code
      material-symbols
      rubik
      font-awesome
      noto-fonts
      noto-fonts-emoji
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Rubik" "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" "Cascadia Code" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
