{
  config,
  split-monitor-workspaces,
  hyprland,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    copyq
    nautilus
    overskride
    grim
    slurp
    phinger-cursors
  ];

  services.dunst = {
    enable = true;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprland.packages.${pkgs.system}.hyprland;
    portalPackage = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    extraConfig = builtins.readFile ./config/hyprland.conf;
    plugins = [
      split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
    ];
  };

  home.file."${config.home.homeDirectory}/.config/hypr/defaults" = {
    source = ./config/defaults;
    recursive = true;
  };

  home.pointerCursor = {
    name = "phinger-cursors-light";
    package = pkgs.phinger-cursors;
    size = 32;
    gtk.enable = true;
  };
}
