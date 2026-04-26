{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:

let
  modules = ../../../../home-modules;
  mpvOpts = "loop-playlist --shuffle --panscan=1.0 --video-unscaled=no --image-display-duration=300 --loop-file=yes --length=300 --hwdec=auto --vo=gpu";
  mpvpaperLauncher = pkgs.writeShellScript "mpvpaper-launcher" ''
    mpvpaper "HDMI-A-1" -o "${mpvOpts}" "$HOME/Pictures/Wallpapers" &
    mpvpaper "DP-2" -o "${mpvOpts}" "$HOME/Pictures/Wallpapers" &
    wait
  '';
in
{

  imports = [
    (modules + /commons.nix)
    (modules + /shell.nix)
    # (modules + /kde)
    (modules + /hyprland)
  ];

  wayland.windowManager.hyprland.settings = {
    monitor = [
      "HDMI-A-1, 1920x1080@60,   320x0,    1"
      "DP-2,     2560x1440@144,  0x1080,   1"
    ];

    workspace = [
      "8, monitor:HDMI-A-1"
      "9, monitor:HDMI-A-1"
    ];

    exec-once = [ "${mpvpaperLauncher}" ];
  };

  home.username = "llelievr";
  home.homeDirectory = "/home/llelievr";

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
