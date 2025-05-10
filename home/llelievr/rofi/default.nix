{
  config,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
  ];

  programs.rofi = {
    package = pkgs.rofi-wayland;
    enable = true;
    terminal = "${pkgs.kitty}";
    theme = ./theme.rasi;
  };
}
