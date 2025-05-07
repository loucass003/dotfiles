{
  config,
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
        graalvm-ce
        zulu8
        zulu17
        zulu
      ];
    })
    google-chrome
    vscode
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
    xdg-desktop-portal-gtk
    bottles

    parsec-bin
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "loucass003";
    userEmail = "loucass003@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
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
