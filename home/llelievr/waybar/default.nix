{
  config,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
  ];

  programs.waybar = {
    enable = true;
    style = builtins.readFile ./style.css;
  };

  home.file = {
    ".config/waybar/config".source = ./config;
  };
}
