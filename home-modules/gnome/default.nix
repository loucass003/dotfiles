{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:

{

  home.packages = with pkgs; [
    baobab
    loupe
    file-roller
    gedit
    gnome-tweaks
    gtk3
    gtk4
    xdg-user-dirs
    hicolor-icon-theme

    gnomeExtensions.pip-on-top
    gnomeExtensions.auto-power-profile
    gnomeExtensions.appindicator
  ];

  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/json" = [ "gedit.desktop" ];
        "text/plain" = [ "gedit.desktop" ];
        "application/zip" = "org.gnome.FileRoller.desktop";
        "application/rar" = "org.gnome.FileRoller.desktop";
        "application/7z" = "org.gnome.FileRoller.desktop";
        "application/*tar" = "org.gnome.FileRoller.desktop";
        "text/html" = "brave-browser.desktop";
        "x-scheme-handler/http" = "brave-browser.desktop";
        "x-scheme-handler/https" = "brave-browser.desktop";
        "x-scheme-handler/ftp" = "brave-browser.desktop";
        "x-scheme-handler/chrome" = "brave-browser.desktop";
        "x-scheme-handler/about" = "brave-browser.desktop";
        "x-scheme-handler/unknown" = "brave-browser.desktop";
        "application/x-extension-htm" = "brave-browser.desktop";
        "application/x-extension-html" = "brave-browser.desktop";
        "application/x-extension-shtml" = "brave-browser.desktop";
        "application/xhtml+xml" = "brave-browser.desktop";
        "application/x-extension-xhtml" = "brave-browser.desktop";
        "application/x-extension-xht" = "brave-browser.desktop";
      };
    };
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      config.common.default = "*";
      extraPortals = [
        pkgs.xdg-desktop-portal
        pkgs.xdg-desktop-portal-gnome
        pkgs.xdg-desktop-portal-gtk
      ];
    };
    userDirs = {
      createDirectories = true;
    };
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
      "org/gnome/shell" = {
        favorite-apps = [
          "brave-browser.desktop"
          "code.desktop"
          "org.gnome.Console.desktop"
          "spotify.desktop"
          "discord.desktop"
          "org.gnome.Nautilus.desktop"
        ];
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          pip-on-top.extensionUuid
          auto-power-profile.extensionUuid
          appindicator.extensionUuid
        ];
      };
      "org/gnome/mutter" = {
        experimental-features = [
          "scale-monitor-framebuffer" # Enables fractional scaling (125% 150% 175%)
          "variable-refresh-rate" # Enables Variable Refresh Rate (VRR) on compatible displays
          # "xwayland-native-scaling" # Scales Xwayland applications to look crisp on HiDPI screens
        ];
      };
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "Adwaita-dark";
    style = {
      name = "Adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

}
