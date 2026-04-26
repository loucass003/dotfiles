{
  config,
  inputs,
  pkgs,
  pkgs-stable,
  ...
}:

let
  enableWayland =
    drv: bin:
    drv.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/bin/${bin} \
          --add-flags "--enable-features=UseOzonePlatform,WaylandWindowDecorations,WaylandPerMonitorScaling" \
          --add-flags "--ozone-platform=wayland"
      '';
    });

  discord-wl = enableWayland pkgs.discord "discord";
in
{

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    oh-my-zsh
    nerd-fonts.fira-code
    source-han-sans

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    jq # A lightweight and flexible command-line JSON processor
    rclone # Sync tool for cloud storage

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses

    # nix related
    nix-output-monitor
    nixfmt

    # secrets management
    sops
    age
    ssh-to-age

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
    # helvum
    crosspipe
    roomeqwizard
    alsa-utils
    ledfx

    orca-slicer
    # bottles
    sidequest
    gamescope
    bambu-studio
    # lutris
    parsec-bin
    blender
    (plex-desktop.override {
      extraEnv = {
        QT_STYLE_OVERRIDE = "default";
      };
    })
    spotify
    (
      (prismlauncher.override {
        additionalPrograms = [
          ffmpeg
          glfw3-minecraft
          zenity
          xkeyboard_config
        ];
        jdks = [
          temurin-bin-17
          temurin-bin-21
        ];
      })
    )
    steam

    proton-pass

    jetbrains.idea
    jetbrains.datagrip
    slimevr

    direnv
    inputs.affinity-nix.packages.${pkgs.system}.v3

    inputs.hytale-launcher.packages.${pkgs.system}.default

    # davinci-resolve
    kdePackages.kdenlive

    rpi-imager

    proton-vpn
    gimp
    vlc
    mixxx
    steam-run
    obsidian
    winboat
    realvnc-vnc-viewer

    discord-wl

    android-studio

    (pkgs.runCommand "claude-code-wrapped" { buildInputs = [ pkgs.makeWrapper ]; } ''
      mkdir -p $out/bin
      makeWrapper ${inputs.claude-code.packages.${pkgs.system}.claude-code}/bin/claude \
        $out/bin/claude \
        --prefix PATH : ${pkgs.nodejs}/bin
    '')

    codex
  ];

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs-stable.obs-studio-plugins; [
      # obs-ndi
      # inputs.distroav.packages.${pkgs.system}.distroav
    ];
  };

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user.name = "loucass003";
      user.email = "loucass003@gmail.com";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  programs.vscode = {
    enable = true;
  };

  programs.brave = {
    enable = true;
    package = pkgs.brave;
    commandLineArgs = [
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
      "--disable-features=PasswordManager"
    ];
    extensions = [
      { id = "ghmbeldphafepmbegfdlkpapadhbakde"; }
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; }
    ];
  };
}
