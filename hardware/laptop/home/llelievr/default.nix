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
    # (modules + /ssh)
    (modules + /ulauncher)
    # (modules + /winboat)
    (modules + /winapps)
    (modules + /gnome)
    (modules + /wallpaper-engine)
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
