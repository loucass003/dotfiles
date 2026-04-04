{
  pkgs,
  config,
  inputs,
  ...
}:

{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia-shell = {
    enable = true;
    settings = {
      bar = {
        position = "top";
        displayMode = "always_visible";
        backgroundOpacity = 0.93;
        widgets = {
          left = [
            { id = "Launcher"; }
            { id = "Clock"; }
            { id = "SystemMonitor"; compactMode = true; showCpuUsage = true; showCpuTemp = true; showMemoryUsage = true; }
            { id = "ActiveWindow"; }
            { id = "MediaMini"; }
          ];
          center = [
            { id = "Workspace"; }
          ];
          right = [
            { id = "Tray"; }
            { id = "NotificationHistory"; }
            { id = "Battery"; hideIfNotDetected = true; }
            { id = "Volume"; displayMode = "onhover"; }
            { id = "Brightness"; displayMode = "onhover"; }
            { id = "ControlCenter"; }
          ];
        };
      };
      general = {
        telemetryEnabled = false;
        showChangelogOnStartup = false;
        lockOnSuspend = true;
      };
      wallpaper = {
        enabled = true;
        directory = "/home/llelievr/Pictures/Wallpapers";
        fillMode = "crop";
      };
      appLauncher = {
        terminalCommand = "kitty";
        sortByMostUsed = true;
        position = "center";
      };
      colorSchemes = {
        darkMode = true;
        predefinedScheme = "Tokyo Night";
      };
      idle = {
        enabled = false;
      };
      dock = {
        enabled = true;
        position = "bottom";
        displayMode = "auto_hide";
      };
      audio = {
        volumeStep = 5;
      };
      brightness = {
        brightnessStep = 5;
      };
    };
  };

  home.packages = with pkgs; [
    kitty
    fuzzel
    brightnessctl
    swaylock
  ];

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
  };

  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/json" = [ "org.kde.kate.desktop" ];
        "text/plain" = [ "org.kde.kate.desktop" ];
        "application/zip" = "org.kde.ark.desktop";
        "application/rar" = "org.kde.ark.desktop";
        "application/7z" = "org.kde.ark.desktop";
        "application/*tar" = "org.kde.ark.desktop";
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
      config = {
        common.default = [ "gtk" ];
        niri = {
          default = [ "gnome" "gtk" ];
          "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
          "org.freedesktop.impl.portal.Screenshot" = "hyprland";
        };
      };
      extraPortals = [
        pkgs.xdg-desktop-portal-gnome
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-hyprland
      ];
    };
    userDirs = {
      createDirectories = true;
    };
    configFile."niri/config.kdl".source = ./config.kdl;
  };
}
