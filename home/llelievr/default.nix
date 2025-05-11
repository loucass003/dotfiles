{
  config,
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ./shell.nix
    ./ssh
    ./hypridle
    ./rofi
    # ./waybar
    # ./ags
    ./hyprlock
    ./hyprland
    ./hyprpanel
  ];

  home.username = "llelievr";
  home.homeDirectory = "/home/llelievr";

  programs.bash.enable = true;

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    oh-my-zsh
    nerd-fonts.fira-code

    # archives
    zip
    xz
    unzip
    p7zip

    #apps
    discord
    spotify
    (prismlauncher.override {
      # Add binary required by some mod
      additionalPrograms = [ ffmpeg ];

      # Change Java runtimes available to Prism Launcher
      jdks = [
        openjdk17
      ];
    })
    google-chrome
    steam

    # utils
    jq # A lightweight and flexible command-line JSON processor

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    htop
    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    wireplumber

    easyeffects
    pwvucontrol

    nixfmt-rfc-style

    kitty

    gtk3
    gtk4
    xdg-user-dirs
    bottles

    lutris

    parsec-bin

    baobab
    loupe
    file-roller
    gedit
    plex-desktop
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "loucass003";
    userEmail = "loucass003@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  programs.vscode = {
    enable = true;
    profiles.default.userSettings = {
      "editor.formatOnSave" = true;
    };
  };

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
        "text/html" = "google-chrome.desktop";
        "x-scheme-handler/http" = "google-chrome.desktop";
        "x-scheme-handler/https" = "google-chrome.desktop";
        "x-scheme-handler/ftp" = "google-chrome.desktop";
        "x-scheme-handler/chrome" = "google-chrome.desktop";
        "x-scheme-handler/about" = "google-chrome.desktop";
        "x-scheme-handler/unknown" = "google-chrome.desktop";
        "application/x-extension-htm" = "google-chrome.desktop";
        "application/x-extension-html" = "google-chrome.desktop";
        "application/x-extension-shtml" = "google-chrome.desktop";
        "application/xhtml+xml" = "google-chrome.desktop";
        "application/x-extension-xhtml" = "google-chrome.desktop";
        "application/x-extension-xht" = "google-chrome.desktop";
      };
    };
    portal = {
      enable = true;
      config.common.default = "*";
      extraPortals = [
        pkgs.xdg-desktop-portal
        pkgs.xdg-desktop-portal-gtk
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland
      ];
    };
    userDirs = {
      createDirectories = true;
    };
  };

  # programs.direnv.enable = true;

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
