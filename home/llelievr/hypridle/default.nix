{
  config,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    hypridle
  ];

  home.file."${config.home.homeDirectory}/.config/hypr/hypridle.conf" = {
    source = ./config/hypridle.conf;
  };
}
