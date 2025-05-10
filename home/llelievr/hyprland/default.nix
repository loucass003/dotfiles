{
  config,
  inputs,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    nautilus
    overskride
    hyprshot
    # grim
    # slurp
    phinger-cursors
    wl-clipboard
    wl-clip-persist
  ];

  home.sessionVariables = {
    HYPRSHOT_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
  };

  services.clipman.enable = true;

  services.dunst = {
    enable = true;
  };

  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri-dark = "file://${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src}";
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    extraConfig = builtins.readFile ./config/hyprland.conf;
    plugins = [
      inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
      inputs.hyprspace.packages.${pkgs.system}.Hyprspace
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
