{ config, pkgs, ... }:
let
  wallpaperengine = pkgs.linux-wallpaperengine;
  assetsPath = "${config.home.homeDirectory}/.local/share/Steam/steamapps/common/wallpaper_engine/assets/";
  
  # Build the command line arguments for each monitor
  wallpaperArgs = builtins.concatStringsSep " " (
    map (wp: let
      scalingArg = if wp ? scaling then "--scaling ${wp.scaling}" else "";
    in
      "--screen-root ${wp.monitor} ${scalingArg} --dir ${assetsPath} --bg ${wp.wallpaperId}"
    ) [
      { monitor = "eDP-1"; wallpaperId = "3588515670"; }
      # { monitor = "DP-6"; wallpaperId = "3588515670"; }
      # { monitor = "DP-5"; wallpaperId = "3588515670"; }
    ]
  );
in
{
  # Does not work for gnome ..... sadge

  home.packages = [ wallpaperengine ];

  systemd.user.services.wallpaperengine = {
    Unit = {
      Description = "Wallpaper Engine for Linux";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${wallpaperengine}/bin/linux-wallpaperengine ${wallpaperArgs} --clapmp border";
      Restart = "on-failure";
      RestartSec = 3;
      Environment = [
        # "XDG_SESSION_TYPE=wayland"
        # "DISPLAY=:0"
      ];
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}