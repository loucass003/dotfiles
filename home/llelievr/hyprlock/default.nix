{
  config,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    metar
    bc
  ];

  programs.hyprlock = {
    enable = true;
    extraConfig = builtins.readFile ./config/hyprlock.conf;
  };
}
