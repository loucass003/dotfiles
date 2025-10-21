{
  config,
  inputs,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
  ];

  programs.rofi = {
    package = pkgs.rofi;
    enable = true;
    terminal = "${pkgs.kitty}";
    theme = ./theme.rasi;
    plugins = with pkgs; [
    ];
  };

  home.file."${config.home.homeDirectory}/.config/rofi/calc.sh" = {
    source = ./calc.sh;
    executable = true;
  };
}
