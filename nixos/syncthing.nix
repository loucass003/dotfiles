{
  config,
  pkgs,
  lib,
  ...
}:

{
  services.syncthing = {
    enable = true;
    user = "llelievr";
    group = "users";
    dataDir = "/home/llelievr";
    configDir = "/home/llelievr/.config/syncthing";
    overrideDevices = true;
    overrideFolders = true;

    settings = {
      devices = {
        # Run `syncthing --device-id` on the NAS container to get its ID
        nas = {
          id = "HNB6XSW-WSNRFMP-Q5ADEIN-JECFINS-BLZQJQ7-POQCQGQ-ACUTW45-SOPZFQR";
        };
      };

      folders = {
        "obsidian" = {
          path = "/home/llelievr/Obsidian";
          devices = [ "nas" ];
          # Keep 30 days of staggered versions as safety net
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "3600";
              maxAge = "2592000";
            };
          };
        };
      };
    };
  };
}
