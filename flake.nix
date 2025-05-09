{
  description = "A simple NixOS flake";

  inputs = {
    self.submodules = true;
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
      mkWindowsApp = callPackage ./pkgs/mkwindowsapp { makeBinPath = pkgs.lib.makeBinPath; };
      lib = nixpkgs.lib;
      callPackage = pkgs.callPackage;

      # fusion360 = callPackage ./pkgs/fusion360 {
      #   inherit mkWindowsApp;
      #   wine = (
      #     pkgs.wineWowPackages.stable.override {
      #       alsaSupport = true;
      #       cairoSupport = true;
      #       cupsSupport = true;
      #       cursesSupport = true;
      #       dbusSupport = true;
      #       embedInstallers = true;
      #       fontconfigSupport = true;
      #       gettextSupport = true;
      #       gphoto2Support = true;
      #       gstreamerSupport = true;
      #       gtkSupport = true;
      #       krb5Support = true;
      #       mingwSupport = true;
      #       netapiSupport = true;
      #       odbcSupport = true;
      #       openclSupport = true;
      #       openglSupport = true;
      #       pcapSupport = true;
      #       pulseaudioSupport = true;
      #       saneSupport = true;
      #       sdlSupport = true;
      #       tlsSupport = true;
      #       udevSupport = true;
      #       usbSupport = true;
      #       v4lSupport = true;
      #       vaSupport = true;
      #       vulkanSupport = true;
      #       waylandSupport = true;
      #     }
      #   );
      #   wineArch = "win64";
      # };
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
            {
              environment.systemPackages =
                [
                  # fusion360
                ];
            }
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
