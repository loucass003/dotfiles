{
  config,
  inputs,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    freerdp
    inputs.winapps.packages.${pkgs.system}.winapps
  ];

  home.file."${config.home.homeDirectory}/.config/winapps/winapps.conf" = {
    source = ./winapps.conf;
  };

  home.file."${config.home.homeDirectory}/.config/winapps/compose.yaml" = {
    source = ./compose.yaml;
  };
}
