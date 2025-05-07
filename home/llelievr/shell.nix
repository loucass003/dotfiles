{ config, pkgs, ... }:

{
  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableAutosuggestions = true;
    enableCompletion = true; 
    oh-my-zsh = {
      enable = true;
      plugins = [ 
        "git"
        "python"
        "man"
      ];
    };
    plugins = [
    ];
  };
}