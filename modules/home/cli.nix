{ config, pkgs, ... }:

{
  # Starship prompt with custom layout from dotfiles
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };
  xdg.configFile."starship.toml".source = ../../config/starship.toml;

  # Direnv with Nix integration (auto-loads nix-shell / flakes upon entering directories)
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
  };

  # Zoxide: smarter 'cd' command with auto-jump
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  # Eza: modern replacement for ls with icons and git integration
  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    icons = "auto";
    git = true;
  };

  # Bat: syntax-highlighted cat
  programs.bat.enable = true;

  # Tmux terminal multiplexer
  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
  };

  # Modern development and CLI productivity packages
  home.packages = with pkgs; [
    yazi
    btop
    nvtopPackages.intel
    lazygit
    fastfetch
    trash-cli
    ripgrep-all
    tldr
  ];
}
