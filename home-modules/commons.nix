{
  config,
  inputs,
  channels,
  pkgs,
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
  spotify-wl = enableWayland pkgs.spotify "spotify";
in
{

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    oh-my-zsh
    nerd-fonts.fira-code

    # archives
    zip
    xz
    unzip
    p7zip

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
    nix-output-monitor
    nixfmt-rfc-style

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
    helvum
    roomeqwizard
    alsa-utils
    ledfx

    orca-slicer
    bottles
    sidequest
    bambu-studio
    # lutris
    parsec-bin
    blender
    (plex-desktop.override {
      extraEnv = {
        QT_STYLE_OVERRIDE = "default";
      };
    })
    discord-wl
    spotify
    (prismlauncher.override {
      # Add binary required by some mod
      additionalPrograms = [ ffmpeg ];

      # Change Java runtimes available to Prism Launcher
      jdks = [
        openjdk17
        openjdk21
      ];
    })
    steam

    proton-pass

    jetbrains.idea-oss
    slimevr

    direnv
    inputs.affinity-nix.packages.${pkgs.system}.v3

    ghostty
    # davinci-resolve
    kdePackages.kdenlive

    rpi-imager

    protonvpn-gui
    gimp
  ];

  programs.obs-studio = {
    enable = true;
    plugins = with channels.nixpkgs-stable.obs-studio-plugins; [
      # obs-ndi
      # inputs.distroav.packages.${pkgs.system}.distroav
    ];
  };

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

  # home.sessionVariables.NIXOS_OZONE_WL = "1";

}
