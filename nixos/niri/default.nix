{
  config,
  pkgs,
  ...
}:

{
  programs.niri.enable = true;

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.gnome.gcr-ssh-agent.enable = false; # conflicts with programs.ssh.startAgent in config-commons

  services.displayManager.sddm = {
    enable = true;
    theme = "sddm-astronaut-theme";
    extraPackages = with pkgs.kdePackages; [
      qtmultimedia
      qtsvg
    ];
  };

  environment.systemPackages = [ pkgs.sddm-astronaut ];

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";
  };

  environment.pathsToLink = [
    "/share/sddm/themes"
    "/share/wayland-sessions"
    "/share/xsessions"
  ];
}
