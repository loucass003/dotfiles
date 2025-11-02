{
  description = "A simple NixOS flake";

  inputs = {
    self.submodules = true;
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    
    distroav.url = "path:./distroav";

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
      nixpkgs-stable,
      home-manager,
      ...
    }@inputs:

     let
      nixpkgsWithOverlays = with inputs; rec {
        config = {
          allowUnfree = true;
        };
        overlays = [];
      };

      mkPkgsStable = system: import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };

      configurationDefaults = args: {
        nixpkgs = nixpkgsWithOverlays;
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "hm-backup";
        home-manager.extraSpecialArgs = args;
      };

      mkNixosConfiguration = {
        system ? "x86_64-linux",
        hostname,
        args ? {},
        modules,
      }: let
        pkgs-stable = mkPkgsStable system;
        specialArgs = {
          inherit inputs hostname pkgs-stable;
          channels = {
            inherit nixpkgs;
            nixpkgs-stable = pkgs-stable;
          };
        } // args;
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
        modules = [
          ./hardware/desktop/default.nix
          {
            home-manager.users.llelievr = import ./hardware/desktop/home/llelievr/default.nix;
          }
        ];
      };

      nixosConfigurations.laptop = mkNixosConfiguration {
        hostname = "llelievr-fw";
        modules = [
          inputs.nixos-hardware.nixosModules.framework-16-7040-amd
          ./hardware/laptop/default.nix
          {
            home-manager.users.llelievr = import ./hardware/laptop/home/llelievr/default.nix;
          }
        ];
      };
    };
}