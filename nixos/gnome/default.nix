{
  config,
  hostname,
  pkgs,
  lib,
  modulesPath,
  ...
}:

{
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

  services.gnome.games.enable = false;

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
}
