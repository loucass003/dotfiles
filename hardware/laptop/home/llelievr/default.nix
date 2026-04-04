{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:

let
  modules = ../../../../home-modules;
  mpvOpts = "loop-playlist --shuffle --panscan=1.0 --video-unscaled=no --image-display-duration=300 --loop-file=yes --length=300";
  mpvpaperLauncher = pkgs.writeShellScript "mpvpaper-launcher" ''
    mpvpaper "eDP-1" -o "${mpvOpts}" "$HOME/Pictures/Wallpapers" &
    mpvpaper "DP-6" -o "${mpvOpts}" "$HOME/Pictures/Wallpapers" &
    mpvpaper "DP-5" -o "${mpvOpts}" "$HOME/Pictures/Wallpapers" &
    wait
  '';
in
{
  imports = [
    (modules + /commons.nix)
    (modules + /shell.nix)
    (modules + /niri)
  ];

  programs.niri.settings.outputs = {
    "eDP-1" = {
      mode = { width = 2560; height = 1600; refresh = 165.0; };
      position = { x = 0; y = 734; };
      scale = 1.25;
    };
    "DP-6" = {
      mode = { width = 2560; height = 1440; refresh = 75.0; };
      position = { x = 2048; y = 0; };
      scale = 1.0;
    };
    "DP-5" = {
      mode = { width = 2560; height = 1440; refresh = 75.0; };
      position = { x = 2048; y = 1440; };
      scale = 1.0;
    };
  };

  programs.niri.settings.spawn-at-startup = [
    { argv = [ "${mpvpaperLauncher}" ]; }
  ];

  home.username = "llelievr";
  home.homeDirectory = "/home/llelievr";

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
