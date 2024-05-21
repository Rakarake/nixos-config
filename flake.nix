{
  description = "Super system amazing wow";
  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # UwU
    queercat= {
      url = "github:Elsa002/queercat";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Flimpy: Vscode Extensions
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Programming environment
    dev-stuff = {
      url = "github:Rakarake/nix-dev-environment";
    };

    # Nix pre-baked index
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Styling / Colorscheme / Font management
    stylix = {
      url = "github:danth/stylix";
    };
  };
  outputs = { self, nixpkgs-stable, nixpkgs-unstable, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      # If using nixpkgs-stable, just don't use home manager stuff
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      # Smooth
      forEachSystem = nixpkgs: (f: nixpkgs.lib.genAttrs systems (system: f (pkgsFor nixpkgs).${system}));
      # Set of { "system".pkgs }
      pkgsFor = nixpkgs: nixpkgs.lib.genAttrs systems (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
      );
      args = { inherit inputs outputs self; };
    in
    {
      # Expose NixOS and HomeManager modules, just to be nice
      nixosModules = import ./modules;
      homeManagerModules = import ./home;
      packages = forEachSystem nixpkgs-unstable (pkgs: import ./pkgs { inherit pkgs; });

      nixosConfigurations = {
        # Lappy
        thinky = nixpkgs-unstable.lib.nixosSystem {
          modules = [ ./hosts/thinky/configuration.nix ];
          specialArgs = args;
        };
        # Desky
        cobblestone-generator = nixpkgs-unstable.lib.nixosSystem {
          modules = [ ./hosts/cobblestone-generator/configuration.nix ];
          specialArgs = args;
        };
        # Server
        creeper-spawner = nixpkgs-stable.lib.nixosSystem {
          modules = [ ./hosts/creeper-spawner/configuration.nix ];
          specialArgs = args;
        };
        # Live configurations for when you wanna put NixOS on a USB-stick
        live = nixpkgs-unstable.lib.nixosSystem {
          modules = [ ./hosts/live/configuration.nix ];
          specialArgs = args;
        };
        # MASS DESTRUCTION, oh yeah, baby baby
        mass-destruction = nixpkgs-stable.lib.nixosSystem {
          modules = [ ./hosts/mass-destruction/configuration.nix ];
          specialArgs = args;
        };
      };

      homeConfigurations = {
        # Lappy
        "rakarake@thinky-dark" = home-manager.lib.homeManagerConfiguration {
          modules = [ ./hosts/thinky/dark.nix ];
          pkgs = (pkgsFor nixpkgs-unstable).x86_64-linux;
          extraSpecialArgs = args;
        };
        "rakarake@thinky-light" = home-manager.lib.homeManagerConfiguration {
          modules = [ ./hosts/thinky/light.nix ];
          pkgs = (pkgsFor nixpkgs-unstable).x86_64-linux;
          extraSpecialArgs = args;
        };
        "rakarake@cobblestone-generator-dark" = home-manager.lib.homeManagerConfiguration {
          modules = [ ./hosts/cobblestone-generator/dark.nix ];
          pkgs = (pkgsFor nixpkgs-unstable).x86_64-linux;
          extraSpecialArgs = args;
        };
        "rakarake@cobblestone-generator-light" = home-manager.lib.homeManagerConfiguration {
          modules = [ ./hosts/cobblestone-generator/light.nix ];
          pkgs = (pkgsFor nixpkgs-unstable).x86_64-linux;
          extraSpecialArgs = args;
        };
        "rakarake@creeper-spawner" = home-manager.lib.homeManagerConfiguration {
          modules = [ ./hosts/creeper-spawner/home.nix ];
          pkgs = (pkgsFor nixpkgs-unstable).x86_64-linux;
          extraSpecialArgs = args;
        };
      };
    };
}

