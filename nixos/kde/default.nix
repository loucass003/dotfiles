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
    sddm = {
      enable = true;
      wayland.enable = true;
      settings.General.DisplayServer = "wayland";
    };
  };

  services.desktopManager = {
    plasma6 = {
      enable = true;
    };
  };

}
