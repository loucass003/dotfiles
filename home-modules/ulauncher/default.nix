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

  # Configure GNOME keyboard shortcut for ulauncher
  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };
    
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Primary>space";
      command = "${pkgs.ulauncher}/bin/ulauncher-toggle";
      name = "Ulauncher";
    };
  };

  xdg.configFile."autostart/ulauncher.desktop".text = ''
    [Desktop Entry]
    Name=Ulauncher
    Comment=Application launcher for Linux
    GenericName=Launcher
    Categories=GNOME;GTK;Utility;
    TryExec=${pkgs.ulauncher}/bin/ulauncher
    Exec=${pkgs.ulauncher}/bin/ulauncher
    Icon=ulauncher
    Terminal=false
    Type=Application
    X-GNOME-Autostart-enabled=true
  '';

  home.file."${config.home.homeDirectory}/.config/ulauncher/settings.json" = {
    source = ./settings.json;
  };
}