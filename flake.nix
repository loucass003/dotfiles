{
  description = "NixOS configuration";

  inputs = {
    self.submodules = true;
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    hytale-launcher.url = "github:JPyke3/hytale-launcher-nix";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    affinity-nix.url = "github:mrshmllow/affinity-nix";

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      plasma-manager,
      home-manager,
      ...
    }@inputs:
    let
      mkPkgsStable =
        system:
        import nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };

      mkNixosConfiguration =
        {
          system ? "x86_64-linux",
          hostname,
          modules,
        }:
        let
          pkgs-stable = mkPkgsStable system;
          specialArgs = { inherit inputs hostname pkgs-stable; };
        in
        nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            { nixpkgs.config.allowUnfree = true; }
            inputs.sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-backup";
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
            }
          ] ++ modules;
        };
    in
    {
      nixosConfigurations.desktop = mkNixosConfiguration {
        hostname = "llelievr-desktop";
        modules = [
          ./hardware/desktop/default.nix
          { home-manager.users.llelievr = import ./hardware/desktop/home/llelievr/default.nix; }
        ];
      };

      nixosConfigurations.laptop = mkNixosConfiguration {
        hostname = "llelievr-fw";
        modules = [
          inputs.nixos-hardware.nixosModules.framework-16-7040-amd
          ./hardware/laptop/default.nix
          { home-manager.users.llelievr = import ./hardware/laptop/home/llelievr/default.nix; }
        ];
      };
    };
}
