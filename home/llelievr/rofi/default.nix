{
  config,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
  ];

  programs.rofi = {
    enable = true;
    terminal = "${pkgs.kitty}";
    theme = ./theme.rasi;
  };
}
