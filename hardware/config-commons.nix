# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  hostname,
  pkgs,
  ...
}:

{

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://cache.garnix.io"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      default = "saved";
    };
  };

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";

  services.displayManager = {
    gdm = {
      enable = true;
      wayland = true;
    };
  };

  services.desktopManager = {
    gnome = {
      enable = true;
    };
  };

  programs.xwayland.enable = true;

  services.gnome.games.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;

  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

  services.pipewire = {
    enable = true;

    # Optional but commonly needed:
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # Add the loopback configuration
    extraConfig.pipewire = {
      "10-my-loop" = {
        "context.modules" = [
          {
            name = "libpipewire-module-loopback";
            args = {
              "audio.position" = [
                "FL"
                "FR"
              ];
              "capture.props" = {
                "media.class" = "Audio/Sink";
                "node.name" = "myloop";
                "node.description" = "MyLoop";
              };
              "playback.props" = {
                "node.name" = "myloop_playback";
                "node.description" = "MyLoop_Playback";
                "node.target" = "@DEFAULT_AUDIO_SINK@";
                "audio.position" = [
                  "FL"
                  "FR"
                  "LFE"
                ];
                "audio.rate" = 48000;
                # Add LFE mixing properties here
                "channelmix.normalize" = false;
                "channelmix.mix-lfe" = true;
                "channelmix.lfe-cutoff" = 150;
                "channelmix.upmix" = true;
              };
            };
          }
        ];
      };
    };
  };

  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
      logDriver = "json-file";
      extraOptions = "--log-opt max-size=10m --log-opt max-file=3";
    };
  };

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  programs = {
    zsh.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git

    ethtool
  ];

  environment.shells = with pkgs; [
    zsh
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  services.teamviewer.enable = true;

  # services.xrdp.enable = true;

  # Use the GNOME Wayland session
  # services.xrdp.defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session";
  # systemd.services.gnome-remote-desktop = {
  # wantedBy = [ "graphical.target" ];
  # };

  # XRDP needs the GNOME remote desktop backend to function
  # services.gnome.gnome-remote-desktop.enable = true;

  # Open the default RDP port (3389)
  # services.xrdp.openFirewall = true;

  # Disable autologin to avoid session conflicts
  services.displayManager.autoLogin.enable = false;
  services.getty.autologinUser = null;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
