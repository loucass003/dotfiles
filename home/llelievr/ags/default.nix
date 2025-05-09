{
  config,
  ags,
  pkgs,
  ...
}:
{

  imports = [
    ags.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    ollama
    pywal
    sassc
    (python311.withPackages (p: [
      p.material-color-utilities
      p.pywayland
    ]))
  ];

  programs.ags = {
    enable = true;
    configDir = null; # if ags dir is managed by home-manager, it'll end up being read-only. not too cool.

    extraPackages = with pkgs; [
      gtksourceview
      gtksourceview4
      ollama
      python311Packages.material-color-utilities
      python311Packages.pywayland
      pywal
      sassc
      webkitgtk
      webp-pixbuf-loader
      ydotool
    ];
  };

  home.file."${config.home.homeDirectory}/.config/ags" = {
    source = ./config;
    recursive = true;
  };
}
