{
  config,
  hyprpanel,

  pkgs,
  ...
}:

let
  secrets = import ../secrets;
in
{
  imports = [ hyprpanel.homeManagerModules.hyprpanel ];

  home.packages = [
    hyprpanel
  ];

  # all the properties here https://github.com/Jas-SinghFSU/HyprPanel/blob/master/nix/module.nix#L94
  programs.hyprpanel = {
    enable = true;
    overwrite.enable = true;
    hyprland.enable = true;
    settings = {
      theme.name = "one_dark";
      menus.transitionTime = 100;
      # FIXME: Make it secret
      menus.clock.weather.key = secrets.weather.key;
      menus.clock.weather.location = "Rotterdam";
      menus.clock.weather.unit = "metric";
      bar.launcher.icon = "";
      bar.workspaces.showApplicationIcons = true;
      menus.dashboard.powermenu.avatar.image = "${./config/assets/profile.png}";
      layout = {
        "bar.layouts" = {
          "0" = {
            left = [
              "dashboard"
              "workspaces"
              "windowtitle"
            ];
            middle = [ "media" ];
            right = [
              "volume"
              "network"
              "bluetooth"
              "systray"
              "clock"
              "notifications"
            ];
          };
          "*" = {
            left = [
              "dashboard"
              "workspaces"
              "windowtitle"
            ];
            middle = [ "media" ];
            right = [
              "volume"
              "clock"
            ];
          };
        };
      };
    };
    override = {
      theme.font.size = "1rem";
      theme.bar.floating = true;
      theme.bar.menus.menu.dashboard.scaling = 90;
      theme.notification.scaling = 100;
      theme.osd.scaling = 90;
      theme.bar.scaling = 100;
      theme.bar.menus.menu.media.scaling = 90;
      theme.bar.menus.menu.volume.scaling = 90;
      theme.bar.menus.menu.network.scaling = 90;
      theme.bar.menus.menu.bluetooth.scaling = 90;
      theme.bar.menus.menu.clock.scaling = 90;
      theme.bar.menus.menu.battery.scaling = 90;
      theme.bar.menus.popover.scaling = 90;
      theme.tooltip.scaling = 90;
      theme.bar.menus.menu.notifications.scaling = 90;
      theme.bar.menus.menu.dashboard.confirmation_scaling = 90;
      theme.bar.transparent = true;
    };

  };
}
