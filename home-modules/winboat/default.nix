{
  config,
  inputs,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    freerdp
    inputs.winboat.packages.${pkgs.system}.winboat
  ];
}
