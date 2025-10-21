{
  config,
  inputs,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    ulauncher
  ];

  systemd.user.services.ulauncher = {
    Unit = {
      Description = "Linux Application Launcher";
      Documentation = [ "https://ulauncher.io/" ];
    };

    Service = {
      Type = "Simple";
      Restart = "Always";
      RestartSec = 1;
      ExecStart = "${pkgs.ulauncher}/bin/ulauncher --hide-window";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  home.file."${config.home.homeDirectory}/.config/ulauncher/settings.json" = {
    source = ./settings.json;
  };
}
