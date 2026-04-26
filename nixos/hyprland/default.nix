{
  config,
  pkgs,
  ...
}:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.gnome.gcr-ssh-agent.enable = false; # conflicts with programs.ssh.startAgent in config-commons

  services.gvfs.enable = true;
  services.samba.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.displayManager.gdm = {
    enable = true;
  };

  environment.pathsToLink = [
    "/share/sddm/themes"
    "/share/wayland-sessions"
    "/share/xsessions"
  ];
}
