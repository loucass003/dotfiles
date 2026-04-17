{
  pkgs,
  config,
  inputs,
  ...
}:

let
  colors = {
    bg = "#1a1b26";
    bgDark = "#15161e";
    bgVariant = "#24283b";
    outline = "#353d57";
    shadow = "#15161e";
    fg = "#c0caf5";
    fgMuted = "#9aa5ce";
    fgDim = "#a9b1d6";
    onDark = "#16161e";
    blue = "#7aa2f7";
    purple = "#bb9af7";
    green = "#9ece6a";
    red = "#f7768e";
    yellow = "#e0af68";
    cyan = "#7dcfff";
    brightBg = "#414868";
    selection = "#33467c";
    inactiveBorder = "#3b4261";
  };

  # Strip leading '#' for Hyprland rgb() format
  hex = s: builtins.substring 1 (builtins.stringLength s - 1) s;

  discord-unread-json = pkgs.writers.writePython3Bin "discord-unread-json" {
    libraries = with pkgs.python3Packages; [
      dbus-python
      pygobject3
    ];
  } (builtins.readFile ./discord_status.py);
in

{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia-shell = {
    enable = true;
    colors = {
      mError = colors.red;
      mHover = colors.green;
      mOnError = colors.onDark;
      mOnHover = colors.onDark;
      mOnPrimary = colors.onDark;
      mOnSecondary = colors.onDark;
      mOnSurface = colors.fg;
      mOnSurfaceVariant = colors.fgMuted;
      mOnTertiary = colors.onDark;
      mOutline = colors.outline;
      mPrimary = colors.blue;
      mSecondary = colors.purple;
      mShadow = colors.shadow;
      mSurface = colors.bg;
      mSurfaceVariant = colors.bgVariant;
      mTertiary = colors.green;
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
      };
      autoUpdate = true;
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
            { id = "Tray"; }
            {
              colorName = "tertiary";
              hideWhenIdle = true;
              id = "AudioVisualizer";
              width = 200;
            }
            {
              id = "CustomButton";
              type = "text";
              name = "discord";
              textCommand = "discord-unread-json";
              textStream = true;
              hideMode = "expandWithOutput";
              parseJson = true;
              leftClickExec = "hyprctl dispatch focuswindow class:discord";
              showIcon = false;
              showExecTooltip = false;
            }
            { id = "Bluetooth"; }
            { id = "PowerProfile"; }
            { id = "plugin:network-manager-vpn"; }
            { id = "plugin:screen-toolkit"; }
            { id = "plugin:keybind-cheatsheet"; }
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
        mouseWheelAction = "workspace";
        mouseWheelWrap = true;
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
        enableClipboardHistory = true;
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

  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };
    settings = {
      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        "col.active_border" = "rgb(${hex colors.blue})";
        "col.inactive_border" = "rgb(${hex colors.inactiveBorder})";
        layout = "dwindle";
      };

      decoration = {
        rounding = 8;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        shadow = {
          enabled = true;
          range = 8;
          render_power = 3;
          color = "rgba(${hex colors.shadow}bb)";
        };
        blur = {
          enabled = false;
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "easeOutExpo, 0.16, 1, 0.3, 1"
          "easeOutQuad, 0.25, 0.46, 0.45, 0.94"
          "snappySpring, 0.5, 1.0, 0.3, 1.0"
        ];
        animation = [
          "windows,     1, 4, easeOutExpo, slide"
          "windowsOut,  1, 3, easeOutQuad, slide"
          "border,      1, 8, easeOutExpo"
          "fade,        1, 4, easeOutQuad"
          "workspaces,  1, 5, snappySpring, slide"
        ];
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
        };
        mouse_refocus = false;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
        force_split = 2;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
        vfr = true;
        vrr = 1;
      };

      env = [
        # "GTK_THEME,Tokyonight-Dark"
        # "QT_STYLE_OVERRIDE,adwaita-dark"
        "_JAVA_AWT_WM_NONREPARENTING,1"
      ];

      exec-once = [
        "wl-clip-persist --clipboard both"
        "wl-paste --watch cliphist store"
        "noctalia-shell"
        "discord"
        "spotify"
        "easyeffects --gapplication-service"
      ];

      windowrule = [
        "match:class ^(discord)$, workspace 8 silent"
        "match:class ^(spotify)$, workspace 9 silent"
        "match:class ^(easyeffect)$, workspace 10 silent"
        "match:title ^(Select what to share)$, float on"

        # fix minecraft focus bug
        "match:class ^(minecraft-launcher|Minecraft.*|FTBGOBRRRRR)$, immediate on"
        "match:class ^(minecraft-launcher|Minecraft.*|FTBGOBRRRRR)$, render_unfocused on"

        # fix IntelliJ/JetBrains popup windows flickering/going out of view
        "match:class ^(jetbrains-.*)$, match:float true, tag +jetbrains-float"
        "match:tag ^jetbrains-float$, stay_focused on"
        "match:tag ^jetbrains-float$, no_initial_focus on"
      ];
    };
    extraConfig = ''
      # 1. Open / Close actions
      bind = SUPER, Return, exec, kitty                                          #"Open terminal"
      bind = SUPER SHIFT, Q, killactive,                                         #"Close window"
      bind = SUPER, F1,      exec, noctalia-shell ipc call plugin:keybind-cheatsheet toggle      #"Toggle keybind cheatsheet"
      bind = SUPER, Space,   exec, noctalia-shell ipc call launcher toggle                       #"Toggle app launcher"
      bind = SUPER CTRL, C,  exec, noctalia-shell ipc call controlCenter toggle                  #"Toggle control center"
      bind = SUPER CTRL, N,  exec, noctalia-shell ipc call notifications toggleHistory           #"Toggle notification history"
      bind = SUPER CTRL, M,  exec, noctalia-shell ipc call media toggle                          #"Toggle media player"

      # 2. Session lockscreen and monitors
      bind = SUPER, L, exec, noctalia-shell ipc call lockScreen lock                       #"Lock screen"
      bind = SUPER SHIFT, E, exec, noctalia-shell ipc call sessionMenu toggle                    #"Toggle session menu"
      bind = SUPER SHIFT, P, dpms, off                                                           #"Power off monitors"

      # 3. Focus
      bind = SUPER, Left,  movefocus, l                                          #"Focus window left"
      bind = SUPER, Down,  movefocus, d                                          #"Focus window down"
      bind = SUPER, Up,    movefocus, u                                          #"Focus window up"
      bind = SUPER, Right, movefocus, r                                          #"Focus window right"

      # 4. Move window
      bind = SUPER SHIFT, Left,  movewindow, l                                   #"Move window left"
      bind = SUPER SHIFT, Down,  movewindow, d                                   #"Move window down"
      bind = SUPER SHIFT, Up,    movewindow, u                                   #"Move window up"
      bind = SUPER SHIFT, Right, movewindow, r                                   #"Move window right"

      # 5. Window size
      bind = SUPER, F,        fullscreen, 1                                      #"Maximize window"
      bind = SUPER SHIFT, F,  fullscreen, 0                                      #"Fullscreen window"
      bind = SUPER, C,        centerwindow,                                      #"Center window"
      bind = SUPER, Minus,        resizeactive, -100 0                           #"Decrease window width"
      bind = SUPER, Equal,        resizeactive,  100 0                           #"Increase window width"
      bind = SUPER SHIFT, Minus,  resizeactive, 0 -100                           #"Decrease window height"
      bind = SUPER SHIFT, Equal,  resizeactive, 0  100                           #"Increase window height"

      # 6. Workspaces
      bind = SUPER, Page_Down,        workspace,       e+1                       #"Focus workspace below"
      bind = SUPER, Page_Up,          workspace,       e-1                       #"Focus workspace above"
      bind = SUPER SHIFT, Page_Down,  movetoworkspace, e+1                       #"Move window to workspace below"
      bind = SUPER SHIFT, Page_Up,    movetoworkspace, e-1                       #"Move window to workspace above"
      bind = SUPER, 1, workspace, 1                                              #"Focus workspace 1"
      bind = SUPER, 2, workspace, 2                                              #"Focus workspace 2"
      bind = SUPER, 3, workspace, 3                                              #"Focus workspace 3"
      bind = SUPER, 4, workspace, 4                                              #"Focus workspace 4"
      bind = SUPER, 5, workspace, 5                                              #"Focus workspace 5"
      bind = SUPER, 6, workspace, 6                                              #"Focus workspace 6"
      bind = SUPER, 7, workspace, 7                                              #"Focus workspace 7"
      bind = SUPER, 8, workspace, 8                                              #"Focus workspace 8"
      bind = SUPER, 9, workspace, 9                                              #"Focus workspace 9"
      bind = SUPER SHIFT, 1, movetoworkspace, 1                                  #"Move window to 1"
      bind = SUPER SHIFT, 2, movetoworkspace, 2                                  #"Move window to 2"
      bind = SUPER SHIFT, 3, movetoworkspace, 3                                  #"Move window to 3"
      bind = SUPER SHIFT, 4, movetoworkspace, 4                                  #"Move window to 4"
      bind = SUPER SHIFT, 5, movetoworkspace, 5                                  #"Move window to 5"
      bind = SUPER SHIFT, 6, movetoworkspace, 6                                  #"Move window to 6"
      bind = SUPER SHIFT, 7, movetoworkspace, 7                                  #"Move window to 7"
      bind = SUPER SHIFT, 8, movetoworkspace, 8                                  #"Move window to 8"
      bind = SUPER SHIFT, 9, movetoworkspace, 9                                  #"Move window to 9"

      # 7. Multi monitor controls
      bind = SUPER CTRL, Left,  focusmonitor, l                                  #"Focus monitor left"
      bind = SUPER CTRL, Right, focusmonitor, r                                  #"Focus monitor right"
      bind = SUPER SHIFT CTRL, Left,  movewindow, mon:l                          #"Move window to monitor left"
      bind = SUPER SHIFT CTRL, Right, movewindow, mon:r                          #"Move window to monitor right"

      # 8. Mouse binds
      bindm = SUPER, mouse:272, movewindow #"Move window"
      bindm = SUPER, mouse:273, resizewindow #"Resize window"

      # 9. Media controls
      bindl = , XF86AudioRaiseVolume,  exec, noctalia-shell ipc call volume increase               #"Increase volume"
      bindl = , XF86AudioLowerVolume,  exec, noctalia-shell ipc call volume decrease               #"Decrease volume"
      bindl = , XF86AudioMute,          exec, noctalia-shell ipc call volume muteOutput            #"Mute output"
      bindl = , XF86AudioMicMute,       exec, noctalia-shell ipc call volume muteInput             #"Mute microphone"
      bindl = , XF86MonBrightnessUp,    exec, noctalia-shell ipc call brightness increase          #"Increase brightness"
      bindl = , XF86MonBrightnessDown,  exec, noctalia-shell ipc call brightness decrease          #"Decrease brightness"
      bindl = , XF86AudioPlay,  exec, noctalia-shell ipc call media playPause                      #"Play/pause media"
      bindl = , XF86AudioNext,  exec, noctalia-shell ipc call media next                           #"Next track"
      bindl = , XF86AudioPrev,  exec, noctalia-shell ipc call media previous                       #"Previous track"

      # 10. Screenshots
      bind = , Print, exec, grim -g "$(slurp)" - | tee ~/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png | wl-copy   #"Screenshot a region"

      # 11. Clipboard
      bind = SUPER, V, exec, noctalia-shell ipc call launcher clipboard
    '';
  };

  home.file."Pictures/Wallpapers".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/wallpapers";

  programs.kitty = {
    enable = true;
    settings = {
      # Tokyo Night – matches Noctalia color scheme
      background = colors.bg;
      foreground = colors.fg;
      selection_background = colors.selection;
      selection_foreground = colors.fg;
      url_color = colors.cyan;
      cursor = colors.fg;
      cursor_text_color = colors.bg;

      color0 = colors.bgDark;
      color1 = colors.red;
      color2 = colors.green;
      color3 = colors.yellow;
      color4 = colors.blue;
      color5 = colors.purple;
      color6 = colors.cyan;
      color7 = colors.fgDim;
      color8 = colors.brightBg;
      color9 = colors.red;
      color10 = colors.green;
      color11 = colors.yellow;
      color12 = colors.blue;
      color13 = colors.purple;
      color14 = colors.cyan;
      color15 = colors.fg;

      background_opacity = "0.95";
      window_padding_width = 8;
      window_border_width = "1px";
      active_border_color = colors.blue;
      inactive_border_color = colors.inactiveBorder;

      font_family = "FiraCode Nerd Font";
      bold_font = "FiraCode Nerd Font Bold";
      italic_font = "FiraCode Nerd Font Italic";
      bold_italic_font = "FiraCode Nerd Font Bold Italic";
      font_size = "12.0";

      enable_audio_bell = false;
      cursor_shape = "block";
      cursor_blink_interval = "0";
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
    hyprcursor.enable = true;
    hyprcursor.size = 24;
  };

  home.packages = with pkgs; [
    discord-unread-json
    mpvpaper
    kdePackages.qtmultimedia
    brightnessctl
    swaylock
    adwaita-qt6
    nautilus
    gnome-text-editor
    file-roller
    grim
    slurp
    wl-clipboard
    wl-clip-persist
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
    gtk3
    gtk4
    libunity
  ];

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
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
        hyprland = {
          default = [
            "hyprland"
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
