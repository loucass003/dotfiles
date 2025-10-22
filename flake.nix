{
  description = "A simple NixOS flake";

  inputs = {
    self.submodules = true;
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # winboat = {
    #   url = "github:TibixDev/winboat";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:

     let
      nixpkgsWithOverlays = with inputs; rec {
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            # FIXME:: add any insecure packages you absolutely need here
          ];
        };
        overlays = [];
      };

      configurationDefaults = args: {
        nixpkgs = nixpkgsWithOverlays;
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "hm-backup";
        home-manager.extraSpecialArgs = args;
      };

      argDefaults = {
        inherit inputs;
        channels = {
          inherit nixpkgs;
        };
      };

      mkNixosConfiguration = {
        system ? "x86_64-linux",
        hostname,
        username,
        args ? {},
        modules,
      }: let
        specialArgs = argDefaults // {inherit hostname username;} // args;
      in
        nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules =
            [
              (configurationDefaults specialArgs)
              home-manager.nixosModules.home-manager
            ]
            ++ modules;
        };
    in {
      nixosConfigurations.desktop = mkNixosConfiguration {
        hostname = "llelievr-desktop";
        username = "llelievr";
        modules = [
          ./hardware/desktop/default.nix
          {
            home-manager.users.llelievr = import ./hardware/desktop/home/llelievr/default.nix;
          }
        ];
      };

      nixosConfigurations.laptop = mkNixosConfiguration {
        hostname = "llelievr-fw";
        username = "llelievr";
        modules = [
          inputs.nixos-hardware.nixosModules.framework-16-7040-amd
          ./hardware/laptop/default.nix
          {
            home-manager.users.llelievr = import ./hardware/desktop/home/llelievr/default.nix;
          }
        ];
      };
    };
}