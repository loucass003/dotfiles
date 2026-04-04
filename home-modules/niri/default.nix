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
    colors = {
      mError = "#f7768e";
      mHover = "#9ece6a";
      mOnError = "#16161e";
      mOnHover = "#16161e";
      mOnPrimary = "#16161e";
      mOnSecondary = "#16161e";
      mOnSurface = "#c0caf5";
      mOnSurfaceVariant = "#9aa5ce";
      mOnTertiary = "#16161e";
      mOutline = "#353d57";
      mPrimary = "#7aa2f7";
      mSecondary = "#bb9af7";
      mShadow = "#15161e";
      mSurface = "#1a1b26";
      mSurfaceVariant = "#24283b";
      mTertiary = "#9ece6a";
    };
    plugins = {
      sources = [
        {
          enabled = true;
          name = "Noctalia Plugins";
          url = "https://github.com/noctalia-dev/noctalia-plugins";
        }
      ];
      states = {
        network-manager-vpn = {
          enabled = true;
        };
        screen-toolkit = {
          enabled = true;
        };
        keybind-cheatsheet = {
          enabled = true;
        };
        video-wallpaper = { enabled = true; };
      };
      version = 2;
    };
    settings = {
      bar = {
        position = "top";
        displayMode = "always_visible";
        backgroundOpacity = 1;
        widgets = {
          left = [
            { id = "Launcher"; }
            { id = "Clock"; }
            {
              id = "SystemMonitor";
              compactMode = true;
              showCpuUsage = true;
              showCpuTemp = true;
              showMemoryUsage = true;
            }
            { id = "ActiveWindow"; }
            { id = "MediaMini"; }
          ];
          center = [
            { id = "Workspace"; }
          ];
          right = [
            {
              id = "CustomButton";
              textCommand = ''
                emit() {
                  if [ -f /tmp/.wf-recording ]; then
                    echo '{"text":"●","color":"error"}'
                  else
                    echo '{"text":""}'
                  fi
                }
                emit
                while inotifywait -qq -e create,delete --include '\.wf-recording' /tmp; do
                  emit
                done
              '';
              textStream = true;
              parseJson = true;
              hideMode = "expandWithOutput";
              showIcon = false;
              leftClickExec = "pkill -SIGINT wf-recorder && rm -f /tmp/.wf-recording";
              generalTooltipText = "Recording in progress — click to stop";
            }
            { id = "Tray"; }
            {
              id = "plugin:network-manager-vpn";
            }
            {
              id = "plugin:screen-toolkit";
            }
            {
              id = "plugin:keybind-cheatsheet";
            }
            { id = "NotificationHistory"; }
            {
              id = "Battery";
              hideIfNotDetected = true;
            }
            {
              id = "Volume";
              displayMode = "onhover";
            }
            {
              id = "Brightness";
              displayMode = "onhover";
            }
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
        enabled = false;
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
        enabled = true;
      };
      dock = {
        enabled = true;
        position = "bottom";
        displayMode = "auto_hide";
        pinnedApps = [
          "brave-browser.desktop"
          "kitty.desktop"
          "org.gnome.Nautilus.desktop"
          "vesktop.desktop"
        ];
        floatingRatio = 1;
        size = 2;
        animationSpeed = 1.7;
        indicatorThickness = 3;
        indicatorOpacity = 1;
        indicatorColor = "primary";
      };
      audio = {
        volumeStep = 5;
      };
      brightness = {
        brightnessStep = 5;
      };
    };
  };

  programs.niri.settings = {
    input = {
      keyboard.xkb.layout = "us";
      touchpad = {
        tap = true;
        natural-scroll = true;
      };
    };

    layout = {
      gaps = 8;
      preset-column-widths = [
        { proportion = 0.33333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }
      ];
      default-column-width = {
        proportion = 1.0;
      };
      focus-ring = {
        width = 2;
        active.color = "#7aa2f7";
        inactive.color = "#3b4261";
      };
      border.enable = false;
    };

    environment = {
      NIXOS_OZONE_WL = "1";
      GTK_THEME = "Tokyonight-Dark";
      QT_STYLE_OVERRIDE = "adwaita-dark";
    };

    prefer-no-csd = true;

    screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

    window-rules = [
      {
        geometry-corner-radius = {
          top-left = 8.0;
          top-right = 8.0;
          bottom-right = 8.0;
          bottom-left = 8.0;
        };
        clip-to-geometry = true;
      }
      {
        matches = [ { title = "Select what to share"; } ];
        open-floating = true;
      }
    ];

    spawn-at-startup = [
      { argv = [ "noctalia-shell" ]; }
    ];

    binds = {
      # Terminal
      "Mod+Return".action.spawn = "kitty";
      "Mod+Shift+Q".action.close-window = { };

      "Mod+F1".action.spawn = [
        "noctalia-shell"
        "ipc"
        "call"
        "plugin:keybind-cheatsheet"
        "toggle"
      ];

      # Noctalia panels
      "Mod+Space".action.spawn = [
        "noctalia-shell"
        "ipc"
        "call"
        "launcher"
        "toggle"
      ];
      "Mod+Ctrl+C".action.spawn = [
        "noctalia-shell"
        "ipc"
        "call"
        "controlCenter"
        "toggle"
      ];
      "Mod+Ctrl+N".action.spawn = [
        "noctalia-shell"
        "ipc"
        "call"
        "notifications"
        "toggleHistory"
      ];
      "Mod+Ctrl+M".action.spawn = [
        "noctalia-shell"
        "ipc"
        "call"
        "media"
        "toggle"
      ];

      # Session
      "Mod+Shift+L".action.spawn = [
        "noctalia-shell"
        "ipc"
        "call"
        "lockScreen"
        "lock"
      ];
      "Mod+Shift+E".action.spawn = [
        "noctalia-shell"
        "ipc"
        "call"
        "sessionMenu"
        "toggle"
      ];
      "Mod+Shift+P".action.power-off-monitors = { };

      # Focus movement
      "Mod+Left".action.focus-column-left = { };
      "Mod+Down".action.focus-window-down = { };
      "Mod+Up".action.focus-window-up = { };
      "Mod+Right".action.focus-column-right = { };
      "Mod+H".action.focus-column-left = { };
      "Mod+J".action.focus-window-down = { };
      "Mod+K".action.focus-window-up = { };
      "Mod+L".action.focus-column-right = { };

      # Window movement
      "Mod+Shift+Left".action.move-column-left = { };
      "Mod+Shift+Down".action.move-window-down = { };
      "Mod+Shift+Up".action.move-window-up = { };
      "Mod+Shift+Right".action.move-column-right = { };
      "Mod+Shift+H".action.move-column-left = { };
      "Mod+Shift+J".action.move-window-down = { };
      "Mod+Shift+K".action.move-window-up = { };

      # Column / window sizing
      "Mod+R".action.switch-preset-column-width = { };
      "Mod+Shift+R".action.switch-preset-window-height = { };
      "Mod+F".action.maximize-column = { };
      "Mod+Shift+F".action.fullscreen-window = { };
      "Mod+C".action.center-column = { };
      "Mod+Minus".action.set-column-width = "-10%";
      "Mod+Equal".action.set-column-width = "+10%";
      "Mod+Shift+Minus".action.set-window-height = "-10%";
      "Mod+Shift+Equal".action.set-window-height = "+10%";

      # Workspaces
      "Mod+Page_Down".action.focus-workspace-down = { };
      "Mod+Page_Up".action.focus-workspace-up = { };
      "Mod+Shift+Page_Down".action.move-column-to-workspace-down = { };
      "Mod+Shift+Page_Up".action.move-column-to-workspace-up = { };

      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;
      "Mod+6".action.focus-workspace = 6;
      "Mod+7".action.focus-workspace = 7;
      "Mod+8".action.focus-workspace = 8;
      "Mod+9".action.focus-workspace = 9;
      "Mod+Shift+1".action.move-column-to-workspace = 1;
      "Mod+Shift+2".action.move-column-to-workspace = 2;
      "Mod+Shift+3".action.move-column-to-workspace = 3;
      "Mod+Shift+4".action.move-column-to-workspace = 4;
      "Mod+Shift+5".action.move-column-to-workspace = 5;
      "Mod+Shift+6".action.move-column-to-workspace = 6;
      "Mod+Shift+7".action.move-column-to-workspace = 7;
      "Mod+Shift+8".action.move-column-to-workspace = 8;
      "Mod+Shift+9".action.move-column-to-workspace = 9;

      # Multi-monitor
      "Mod+Ctrl+Left".action.focus-monitor-left = { };
      "Mod+Ctrl+Right".action.focus-monitor-right = { };
      "Mod+Ctrl+Up".action.focus-monitor-up = { };
      "Mod+Ctrl+Down".action.focus-monitor-down = { };
      "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = { };
      "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = { };
      "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = { };
      "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = { };

      # Screenshots
      "Print".action.spawn = [
        "bash"
        "-c"
        ''
          FILE="$HOME/Pictures/Screenshots/Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png"
          grim -g "$(slurp)" "$FILE" && wl-copy < "$FILE"
        ''
      ];
      "Ctrl+Print".action.spawn = [
        "bash"
        "-c"
        ''
          FILE="$HOME/Pictures/Screenshots/Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png"
          grim "$FILE" && wl-copy < "$FILE"
        ''
      ];
      "Alt+Print".action.screenshot-window = { };

      # Screen recording (toggle)
      "Shift+Print".action.spawn = [
        "bash"
        "-c"
        ''
          if [ -f /tmp/.wf-recording ]; then
            pkill -SIGINT wf-recorder
          else
            REGION="$(slurp)" || exit 1
            mkdir -p "$HOME/Videos/Recordings"
            FILE="$HOME/Videos/Recordings/Recording from $(date '+%Y-%m-%d %H-%M-%S').mp4"
            touch /tmp/.wf-recording
            wf-recorder -g "$REGION" -f "$FILE"
            rm -f /tmp/.wf-recording
            action=$(notify-send --wait -i media-record --action="open=Open Folder" "Screen Recording" "Saved to ~/Videos/Recordings")
            [ "$action" = "open" ] && xdg-open "$HOME/Videos/Recordings"
          fi
        ''
      ];

      # Media keys — routed through noctalia for overlays
      "XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "volume"
          "increase"
        ];
      };
      "XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "volume"
          "decrease"
        ];
      };
      "XF86AudioMute" = {
        allow-when-locked = true;
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "volume"
          "muteOutput"
        ];
      };
      "XF86AudioMicMute".action.spawn = [
        "noctalia-shell"
        "ipc"
        "call"
        "volume"
        "muteInput"
      ];
      "XF86MonBrightnessUp".action.spawn = [
        "noctalia-shell"
        "ipc"
        "call"
        "brightness"
        "increase"
      ];
      "XF86MonBrightnessDown".action.spawn = [
        "noctalia-shell"
        "ipc"
        "call"
        "brightness"
        "decrease"
      ];
      "XF86AudioPlay".action.spawn = [
        "noctalia-shell"
        "ipc"
        "call"
        "media"
        "playPause"
      ];
      "XF86AudioPause".action.spawn = [
        "noctalia-shell"
        "ipc"
        "call"
        "media"
        "playPause"
      ];
      "XF86AudioNext".action.spawn = [
        "noctalia-shell"
        "ipc"
        "call"
        "media"
        "next"
      ];
      "XF86AudioPrev".action.spawn = [
        "noctalia-shell"
        "ipc"
        "call"
        "media"
        "previous"
      ];
    };
  };

  home.file."Pictures/Wallpapers".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/wallpapers";

  home.packages = with pkgs; [
    mpvpaper
    kdePackages.qtmultimedia
    kitty
    fuzzel
    brightnessctl
    swaylock
    adwaita-qt6
    nautilus
    gnome-text-editor
    file-roller
    grim
    slurp
    wl-clipboard
    wf-recorder
    libnotify
    inotify-tools
    celluloid
    vlc
    ffmpegthumbnailer
    tesseract
    imagemagick
    zbar
    curl
    translate-shell
    wl-screenrec
    ffmpeg
    gifski
    cliphist
    qt6.qt5compat
  ];

  gtk = {
    enable = true;
    theme = {
      name = "Tokyonight-Dark";
      package = pkgs.tokyonight-gtk-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      accent-color = "blue";
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "org.gnome.Nautilus.desktop";
        "video/mp4" = "io.github.celluloid_player.Celluloid.desktop";
        "video/mkv" = "io.github.celluloid_player.Celluloid.desktop";
        "video/webm" = "io.github.celluloid_player.Celluloid.desktop";
        "video/x-matroska" = "io.github.celluloid_player.Celluloid.desktop";
        "video/avi" = "io.github.celluloid_player.Celluloid.desktop";
        "application/json" = [ "org.gnome.TextEditor.desktop" ];
        "text/plain" = [ "org.gnome.TextEditor.desktop" ];
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
      config = {
        common.default = [ "gtk" ];
        niri = {
          default = [
            "gnome"
            "gtk"
          ];
          "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
          "org.freedesktop.impl.portal.Screenshot" = "hyprland";
        };
      };
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-hyprland
      ];
    };
    userDirs = {
      createDirectories = true;
    };
  };
}
