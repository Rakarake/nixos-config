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

    # Hyprland flake
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... }@attrs:
  let
    # Must havs for all systems
    commonModule = { pkgs, ... }: {
      # Replace openssl with libressl
      nixpkgs.overlays = [
        (final: super: { 
            nginxStable = super.nginxStable.override { openssl = super.pkgs.libressl; }; 
        })
      ];
      # Enable Flakes
      nix.settings.experimental-features = [ "flakes" "nix-command" ];
    };
    commonHome =  {
      imports = [
        # For some reason, this cannot be imported in the hyprland module,
        # I get infinate recursion.
        hyprland.homeManagerModules.default
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
        ./live.nix
      ];
    };

    # Thonkpad configuration go wrrom
    nixosConfigurations.rakarake-thinkpad = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        commonModule
        ./hosts/rakarake-thinkpad/configuration.nix 
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = attrs;
          home-manager.users.rakarake.imports = [
            commonHome
            ./hosts/rakarake-thinkpad/home.nix
          ];
        }
      ];
    };

    # PC
    nixosConfigurations.rakarake-pc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        commonModule
        ./hosts/rakarake-pc/configuration.nix 
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = attrs;
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
        #home-manager.nixosModules.home-manager {
        #  home-manager.useGlobalPkgs = true;
        #  home-manager.useUserPackages = true;
        #  home-manager.users.rakarake.imports = [
        #      #./hosts/creeper-spawner/home.nix
        #  ];
        #}
      ];
    };
  };
}

