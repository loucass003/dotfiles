{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:

let
  modules = ../../../../home-modules;
in
{

  imports = [
    (modules + /commons.nix)
    (modules + /shell.nix)
    # (modules + /kde)
    (modules + /niri)
  ];

  programs.niri.settings.outputs = {
    # Acer K242HL — top monitor
    "HDMI-A-1" = {
      mode = { width = 1920; height = 1080; refresh = 60.0; };
      position = { x = 320; y = 0; };
      scale = 1.0;
    };
    # LG UltraGear — bottom monitor (primary)
    "DP-2" = {
      mode = { width = 2560; height = 1440; refresh = 144.0; };
      position = { x = 0; y = 1080; };
      scale = 1.0;
      variable-refresh-rate = true;
    };
  };

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
