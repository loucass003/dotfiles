{
  pkgs,
  config,
  inputs,
  ...
}:

let
  colors = {
    bg        = "#1a1b26";
    bgDark    = "#15161e";
    bgVariant = "#24283b";
    outline   = "#353d57";
    shadow    = "#15161e";
    fg        = "#c0caf5";
    fgMuted   = "#9aa5ce";
    fgDim     = "#a9b1d6";
    onDark    = "#16161e";
    blue      = "#7aa2f7";
    purple    = "#bb9af7";
    green     = "#9ece6a";
    red       = "#f7768e";
    yellow    = "#e0af68";
    cyan      = "#7dcfff";
    brightBg  = "#414868";
    selection = "#33467c";
    inactiveBorder = "#3b4261";
  };
in

{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia-shell = {
    enable = true;
    colors = {
      mError            = colors.red;
      mHover            = colors.green;
      mOnError          = colors.onDark;
      mOnHover          = colors.onDark;
      mOnPrimary        = colors.onDark;
      mOnSecondary      = colors.onDark;
      mOnSurface        = colors.fg;
      mOnSurfaceVariant = colors.fgMuted;
      mOnTertiary       = colors.onDark;
      mOutline          = colors.outline;
      mPrimary          = colors.blue;
      mSecondary        = colors.purple;
      mShadow           = colors.shadow;
      mSurface          = colors.bg;
      mSurfaceVariant   = colors.bgVariant;
      mTertiary         = colors.green;
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
        animationSpeed = 2.0;
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
        active.color = colors.blue;
        inactive.color = colors.inactiveBorder;
      };
      border.enable = false;
    };

    environment = {
      NIXOS_OZONE_WL = "1";
      GTK_THEME = "Tokyonight-Dark";
      QT_STYLE_OVERRIDE = "adwaita-dark";
      LIBVA_DRIVER_NAME = "radeonsi";
      AMD_VULKAN_ICD = "RADV";
      QSG_RHI_BACKEND = "vulkan";
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
      "Mod+Return" = { hotkey-overlay.title = "Open terminal"; action.spawn = "kitty"; };
      "Mod+Shift+Q" = { hotkey-overlay.title = "Close window"; action.close-window = { }; };

      "Mod+F1" = {
        hotkey-overlay.title = "Toggle keybind cheatsheet";
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "plugin:keybind-cheatsheet"
          "toggle"
        ];
      };

      # Noctalia panels
      "Mod+Space" = {
        hotkey-overlay.title = "Toggle app launcher";
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "launcher"
          "toggle"
        ];
      };
      "Mod+Ctrl+C" = {
        hotkey-overlay.title = "Toggle control center";
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "controlCenter"
          "toggle"
        ];
      };
      "Mod+Ctrl+N" = {
        hotkey-overlay.title = "Toggle notification history";
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "notifications"
          "toggleHistory"
        ];
      };
      "Mod+Ctrl+M" = {
        hotkey-overlay.title = "Toggle media player";
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "media"
          "toggle"
        ];
      };

      # Session
      "Mod+Shift+L" = {
        hotkey-overlay.title = "Lock screen";
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "lockScreen"
          "lock"
        ];
      };
      "Mod+Shift+E" = {
        hotkey-overlay.title = "Toggle session menu";
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "sessionMenu"
          "toggle"
        ];
      };
      "Mod+Shift+P" = { hotkey-overlay.title = "Power off monitors"; action.power-off-monitors = { }; };

      # Focus movement
      "Mod+Left" = { hotkey-overlay.title = "Focus column left"; action.focus-column-left = { }; };
      "Mod+Down" = { hotkey-overlay.title = "Focus window down"; action.focus-window-down = { }; };
      "Mod+Up" = { hotkey-overlay.title = "Focus window up"; action.focus-window-up = { }; };
      "Mod+Right" = { hotkey-overlay.title = "Focus column right"; action.focus-column-right = { }; };
      "Mod+H" = { hotkey-overlay.title = "Focus column left"; action.focus-column-left = { }; };
      "Mod+J" = { hotkey-overlay.title = "Focus window down"; action.focus-window-down = { }; };
      "Mod+K" = { hotkey-overlay.title = "Focus window up"; action.focus-window-up = { }; };
      "Mod+L" = { hotkey-overlay.title = "Focus column right"; action.focus-column-right = { }; };

      # Window movement
      "Mod+Shift+Left" = { hotkey-overlay.title = "Move column left"; action.move-column-left = { }; };
      "Mod+Shift+Down" = { hotkey-overlay.title = "Move window down"; action.move-window-down = { }; };
      "Mod+Shift+Up" = { hotkey-overlay.title = "Move window up"; action.move-window-up = { }; };
      "Mod+Shift+Right" = { hotkey-overlay.title = "Move column right"; action.move-column-right = { }; };
      "Mod+Shift+H" = { hotkey-overlay.title = "Move column left"; action.move-column-left = { }; };
      "Mod+Shift+J" = { hotkey-overlay.title = "Move window down"; action.move-window-down = { }; };
      "Mod+Shift+K" = { hotkey-overlay.title = "Move window up"; action.move-window-up = { }; };

      # Column / window sizing
      "Mod+R" = { hotkey-overlay.title = "Cycle preset column width"; action.switch-preset-column-width = { }; };
      "Mod+Shift+R" = { hotkey-overlay.title = "Cycle preset window height"; action.switch-preset-window-height = { }; };
      "Mod+F" = { hotkey-overlay.title = "Maximize column"; action.maximize-column = { }; };
      "Mod+Shift+F" = { hotkey-overlay.title = "Fullscreen window"; action.fullscreen-window = { }; };
      "Mod+C" = { hotkey-overlay.title = "Center column"; action.center-column = { }; };
      "Mod+Minus" = { hotkey-overlay.title = "Decrease column width"; action.set-column-width = "-10%"; };
      "Mod+Equal" = { hotkey-overlay.title = "Increase column width"; action.set-column-width = "+10%"; };
      "Mod+Shift+Minus" = { hotkey-overlay.title = "Decrease window height"; action.set-window-height = "-10%"; };
      "Mod+Shift+Equal" = { hotkey-overlay.title = "Increase window height"; action.set-window-height = "+10%"; };

      # Workspaces
      "Mod+Page_Down" = { hotkey-overlay.title = "Focus workspace below"; action.focus-workspace-down = { }; };
      "Mod+Page_Up" = { hotkey-overlay.title = "Focus workspace above"; action.focus-workspace-up = { }; };
      "Mod+Shift+Page_Down" = { hotkey-overlay.title = "Move column to workspace below"; action.move-column-to-workspace-down = { }; };
      "Mod+Shift+Page_Up" = { hotkey-overlay.title = "Move column to workspace above"; action.move-column-to-workspace-up = { }; };

      "Mod+1" = { hotkey-overlay.title = "Focus workspace 1"; action.focus-workspace = 1; };
      "Mod+2" = { hotkey-overlay.title = "Focus workspace 2"; action.focus-workspace = 2; };
      "Mod+3" = { hotkey-overlay.title = "Focus workspace 3"; action.focus-workspace = 3; };
      "Mod+4" = { hotkey-overlay.title = "Focus workspace 4"; action.focus-workspace = 4; };
      "Mod+5" = { hotkey-overlay.title = "Focus workspace 5"; action.focus-workspace = 5; };
      "Mod+6" = { hotkey-overlay.title = "Focus workspace 6"; action.focus-workspace = 6; };
      "Mod+7" = { hotkey-overlay.title = "Focus workspace 7"; action.focus-workspace = 7; };
      "Mod+8" = { hotkey-overlay.title = "Focus workspace 8"; action.focus-workspace = 8; };
      "Mod+9" = { hotkey-overlay.title = "Focus workspace 9"; action.focus-workspace = 9; };
      "Mod+Shift+1" = { hotkey-overlay.title = "Move column to workspace 1"; action.move-column-to-workspace = 1; };
      "Mod+Shift+2" = { hotkey-overlay.title = "Move column to workspace 2"; action.move-column-to-workspace = 2; };
      "Mod+Shift+3" = { hotkey-overlay.title = "Move column to workspace 3"; action.move-column-to-workspace = 3; };
      "Mod+Shift+4" = { hotkey-overlay.title = "Move column to workspace 4"; action.move-column-to-workspace = 4; };
      "Mod+Shift+5" = { hotkey-overlay.title = "Move column to workspace 5"; action.move-column-to-workspace = 5; };
      "Mod+Shift+6" = { hotkey-overlay.title = "Move column to workspace 6"; action.move-column-to-workspace = 6; };
      "Mod+Shift+7" = { hotkey-overlay.title = "Move column to workspace 7"; action.move-column-to-workspace = 7; };
      "Mod+Shift+8" = { hotkey-overlay.title = "Move column to workspace 8"; action.move-column-to-workspace = 8; };
      "Mod+Shift+9" = { hotkey-overlay.title = "Move column to workspace 9"; action.move-column-to-workspace = 9; };

      # Multi-monitor
      "Mod+Ctrl+Left" = { hotkey-overlay.title = "Focus monitor left"; action.focus-monitor-left = { }; };
      "Mod+Ctrl+Right" = { hotkey-overlay.title = "Focus monitor right"; action.focus-monitor-right = { }; };
      "Mod+Ctrl+Up" = { hotkey-overlay.title = "Focus monitor up"; action.focus-monitor-up = { }; };
      "Mod+Ctrl+Down" = { hotkey-overlay.title = "Focus monitor down"; action.focus-monitor-down = { }; };
      "Mod+Shift+Ctrl+Left" = { hotkey-overlay.title = "Move column to monitor left"; action.move-column-to-monitor-left = { }; };
      "Mod+Shift+Ctrl+Right" = { hotkey-overlay.title = "Move column to monitor right"; action.move-column-to-monitor-right = { }; };
      "Mod+Shift+Ctrl+Up" = { hotkey-overlay.title = "Move column to monitor up"; action.move-column-to-monitor-up = { }; };
      "Mod+Shift+Ctrl+Down" = { hotkey-overlay.title = "Move column to monitor down"; action.move-column-to-monitor-down = { }; };

      # Screenshots
      "Print" = {
        hotkey-overlay.title = "Screenshot region to clipboard";
        action.spawn = [
          "bash"
          "-c"
          ''
            FILE="$HOME/Pictures/Screenshots/Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png"
            grim -g "$(slurp)" "$FILE" && wl-copy < "$FILE"
          ''
        ];
      };
      "Ctrl+Print" = {
        hotkey-overlay.title = "Screenshot full screen to clipboard";
        action.spawn = [
          "bash"
          "-c"
          ''
            FILE="$HOME/Pictures/Screenshots/Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png"
            grim "$FILE" && wl-copy < "$FILE"
          ''
        ];
      };
      "Alt+Print" = { hotkey-overlay.title = "Screenshot focused window"; action.screenshot-window = { }; };

      # Screen recording (toggle)
      "Shift+Print" = {
        hotkey-overlay.title = "Toggle screen recording";
        action.spawn = [
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
      };

      # Media keys — routed through noctalia for overlays
      "XF86AudioRaiseVolume" = {
        hotkey-overlay.title = "Increase volume";
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
        hotkey-overlay.title = "Decrease volume";
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
        hotkey-overlay.title = "Mute output";
        allow-when-locked = true;
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "volume"
          "muteOutput"
        ];
      };
      "XF86AudioMicMute" = {
        hotkey-overlay.title = "Mute microphone";
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "volume"
          "muteInput"
        ];
      };
      "XF86MonBrightnessUp" = {
        hotkey-overlay.title = "Increase brightness";
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "brightness"
          "increase"
        ];
      };
      "XF86MonBrightnessDown" = {
        hotkey-overlay.title = "Decrease brightness";
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "brightness"
          "decrease"
        ];
      };
      "XF86AudioPlay" = {
        hotkey-overlay.title = "Play/pause media";
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "media"
          "playPause"
        ];
      };
      "XF86AudioPause" = {
        hotkey-overlay.title = "Play/pause media";
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "media"
          "playPause"
        ];
      };
      "XF86AudioNext" = {
        hotkey-overlay.title = "Next track";
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "media"
          "next"
        ];
      };
      "XF86AudioPrev" = {
        hotkey-overlay.title = "Previous track";
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "media"
          "previous"
        ];
      };
    };
  };

  home.file."Pictures/Wallpapers".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/wallpapers";

  programs.kitty = {
    enable = true;
    settings = {
      # Tokyo Night – matches Noctalia color scheme
      background            = colors.bg;
      foreground            = colors.fg;
      selection_background  = colors.selection;
      selection_foreground  = colors.fg;
      url_color             = colors.cyan;
      cursor                = colors.fg;
      cursor_text_color     = colors.bg;

      # Normal colors
      color0  = colors.bgDark;    # black
      color1  = colors.red;       # red
      color2  = colors.green;     # green
      color3  = colors.yellow;    # yellow
      color4  = colors.blue;      # blue
      color5  = colors.purple;    # magenta
      color6  = colors.cyan;      # cyan
      color7  = colors.fgDim;     # white

      # Bright colors
      color8  = colors.brightBg;  # bright black
      color9  = colors.red;       # bright red
      color10 = colors.green;     # bright green
      color11 = colors.yellow;    # bright yellow
      color12 = colors.blue;      # bright blue
      color13 = colors.purple;    # bright magenta
      color14 = colors.cyan;      # bright cyan
      color15 = colors.fg;        # bright white

      # Window / decoration
      background_opacity    = "0.95";
      window_padding_width  = 8;
      window_border_width   = "1px";
      active_border_color   = colors.blue;
      inactive_border_color = colors.inactiveBorder;

      # Font
      font_family      = "FiraCode Nerd Font";
      bold_font        = "FiraCode Nerd Font Bold";
      italic_font      = "FiraCode Nerd Font Italic";
      bold_italic_font = "FiraCode Nerd Font Bold Italic";
      font_size        = "12.0";

      # Misc
      enable_audio_bell = false;
      cursor_shape      = "block";
      cursor_blink_interval = "0";
    };
  };

  home.packages = with pkgs; [
    mpvpaper
    kdePackages.qtmultimedia
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
