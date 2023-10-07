{
  description = "A super system conf";
  inputs = {
    # Use nixos-unstable as nixpkgs source
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager flake dependency
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Nix Software Center and NixOS-conf-editor dependency
    nix-software-center.url = "github:vlinkz/nix-software-center";
    nixos-conf-editor.url = "github:vlinkz/nixos-conf-editor";

    # Rust Overlay Flake (to use the nightly channel)
    #fenix = {
    #  url = "github:nix-community/fenix/monthly";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
  };

  outputs = attrs@{ self, nixpkgs, home-manager, ... }:
  let
    overlayModule = { pkgs, ... }: {
      nixpkgs.overlays = [
        # Replace openssl with libressl
        (final: super: { 
            nginxStable = super.nginxStable.override { openssl = super.pkgs.libressl; }; 
        })
      ];
    };
    # Module for replacing rust tools with overlay
      #({ pkgs, ... }: {
      #  nixpkgs.overlays = [ fenix.overlays.default ];
      #  environment.systemPackages = [
      #    (fenix.packages.x86_64-linux.default.withComponents [
      #        "cargo"
      #        "clippy"
      #        "rustc"
      #        "rustfmt"
      #    ])
      #    pkgs.rust-analyzer-nightly
      #  ];
      #})
  in
  {
    # Live configurations for when installing NixOS
    nixosConfigurations.live = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
        ./live-configuration.nix
      ];
    };

    # Thonkpad configuration go wrrom
    nixosConfigurations.rakarake-thinkpad = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./desktop-configuration.nix
        ./gnome.nix
        ./hosts/rakarake-thinkpad/configuration.nix 
        overlayModule
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.rakarake.imports = [
              ./home.nix
              ./home-gnome.nix
              ./hosts/rakarake-thinkpad/home.nix
          ];

          # Optionally, use home-manager.extraSpecialArgs to pass
          # arguments to home.nix
        }
      ];
    };

    # PC
    nixosConfigurations.rakarake-pc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./desktop-configuration.nix
        ./kde.nix
        ./hosts/rakarake-pc/configuration.nix 
        overlayModule
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.rakarake.imports = [
              ./home.nix
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
        ./hosts/creeper-spawner/configuration.nix 
        overlayModule
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.rakarake.imports = [
              ./hosts/creeper-spawner/home.nix
          ];
        }
      ];
    };

  };
}

