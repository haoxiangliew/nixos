{
  description = "Hao Xiang's nixos-unstable configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    lanzaboote.url = "github:nix-community/lanzaboote";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacsunstable.url = "github:nix-community/emacs-overlay";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mozilla.url = "github:mozilla/nixpkgs-mozilla";
  };

  outputs = { self, nixpkgs, lanzaboote, home-manager, ... }@inputs:
    let
      user = "haoxiangliew";
      env = "gnome";
    in {
      nixosConfigurations = {
        e595 = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            lanzaboote.nixosModules.lanzaboote
            ./overlays.nix
            ./configuration.nix

            ./hardware/e595.nix

            ./modules/security.nix
            # ./modules/secure-boot.nix

            ./modules/environments/${env}.nix
            ./modules/fonts.nix
            ./modules/udev.nix

            ./hosts/e595.nix
            ./users/${user}.nix

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${user}.imports = [
                  ./home-manager/e595-home.nix
                  ./modules/environments/${env}-home.nix
                ];
              };
            }
          ];
          specialArgs = { inherit inputs; };
        };

        nixos-kvm = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            lanzaboote.nixosModules.lanzaboote
            ./overlays.nix
            ./configuration.nix

            ./modules/security.nix
            ./modules/secure-boot.nix

            ./modules/environments/${env}.nix
            ./modules/fonts.nix
            ./modules/udev.nix

            ./hosts/nixos-kvm.nix
            ./users/${user}.nix

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${user}.imports = [ ./home-manager/nixos-kvm-home.nix ];
              };
            }
          ];
          specialArgs = { inherit inputs; };
        };
      };
    };
}
