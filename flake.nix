{
  description = "A super system conf";
  inputs = {
    # Use latest nixpkgs for system, and nixpkgs-unstable for programs
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    #nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager flake dependency
    #home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Nix Software Center and NixOS-conf-editor dependency
    nix-software-center.url = "github:vlinkz/nix-software-center";
    nixos-conf-editor.url = "github:vlinkz/nixos-conf-editor";

    # UwU
    queercat.url = "github:Elsa002/queercat";

    # Hyprland flake
    hyprland.url = "github:hyprwm/Hyprland";

    # Programming environment
    dev-stuff.url = "github:Rakarake/nix-dev-environment";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, dev-stuff, ... }@attrs:
  let
    overlays = [
      # Replace openssl with libressl
      (final: super: { 
          nginxStable = super.nginxStable.override { openssl = super.pkgs.libressl; }; 
      })
    ];
    # Must havs for all systems
    commonModule = { pkgs, ... }: {
      nixpkgs.overlays = overlays;
      # Enable Flakes
      nix.settings.experimental-features = [ "flakes" "nix-command" ];
      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;
    };
    # Common among home-manager systems
    commonHome =  {
      imports = [
        # For some reason, this cannot be imported in the hyprland module,
        # I get infinate recursion.
        hyprland.homeManagerModules.default
        # Enable to use development environment
        dev-stuff.homeManagerModules.default
      ];
    };
  in
  {
    # Live configurations for when you wanna put NixOS on a USB-stick
    nixosConfigurations.live = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
        ./live.nix
        # Module to enable bcachefs support in the live-environment
        ({ lib, pkgs, ... }: {
          boot.supportedFilesystems = [ "bcachefs" ];
          boot.kernelPackages = lib.mkOverride 0 pkgs.linuxPackages_testing_bcachefs;
        })
      ];
    };

    # Thonkpad configuration go wrroom
    nixosConfigurations.rakarake-thinkpad = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = attrs; # // { pkgs-unstable = import nixpkgs-unstable { inherit overlays system; }; };
      modules = [
        commonModule
        ./hosts/rakarake-thinkpad/configuration.nix 
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users.rakarake.imports = [
            commonHome
            ./hosts/rakarake-thinkpad/home.nix
          ];
        }
      ];
    };

    # PC
    nixosConfigurations.rakarake-pc = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = attrs; # // { pkgs-unstable = import nixpkgs-unstable { inherit overlays system; }; };
      modules = [
        commonModule
        ./hosts/rakarake-pc/configuration.nix 
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users.rakarake.imports = [
            commonHome
            ./hosts/rakarake-pc/home.nix
          ];
        }
      ];
    };

    # Home server
    nixosConfigurations.creeper-spawner = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        commonModule
        ./hosts/creeper-spawner/configuration.nix 
      ];
    };
  };
}

