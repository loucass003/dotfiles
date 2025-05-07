{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };
    ags.url = "github:Aylur/ags";
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    hyprpanel.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      hyprland,
      split-monitor-workspaces,
      hyprpanel,
      ags,
      ...
    }:

    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
      callPackage = pkgs.callPackage;
    in
    {
      nixosConfigurations = {
        nixos = lib.nixosSystem rec {
          inherit system;
          specialArgs = {
            inherit hyprland;
            inherit split-monitor-workspaces;
            inherit ags;
            inherit hyprpanel;
          };

          modules = [
            # { environment.systemPackages = [ (callPackage ./pkgs/fusion360.nix { }) ]; }
            { nixpkgs.overlays = [ hyprpanel.overlay ]; }
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.users.llelievr = import ./home/llelievr/default.nix;
              home-manager.extraSpecialArgs = specialArgs;
            }
          ];
        };
      };
    };
}
