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

    # Nix pre-baked index
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Styling / Colorscheme / Font management
    stylix = {
      url = "github:danth/stylix";
    };

    # Wgsl language server
    wgsl_analyzer = {
      url = "github:wgsl-analyzer/wgsl-analyzer";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Steamdeck related options
    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Bingbingo server
    bingbingo = {
      url = "github:Rakarake/bingbingo";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
        thinky = nixpkgs-unstable.lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = [ ./hosts/thinky/configuration.nix ];
          specialArgs = args // { inherit system; };
        };
        # Desky
        cobblestone-generator = nixpkgs-unstable.lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = [ ./hosts/cobblestone-generator/configuration.nix ];
          specialArgs = args // { inherit system; };
        };
        # Server
        creeper-spawner = nixpkgs-stable.lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = [ ./hosts/creeper-spawner/configuration.nix ];
          specialArgs = args // { inherit system; };
        };
        # Live configurations for when you wanna put NixOS on a USB-stick
        live = nixpkgs-unstable.lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = [ ./hosts/live/configuration.nix ];
          specialArgs = args // { inherit system; };
        };
        # MASS DESTRUCTION, oh yeah, baby baby
        mass-destruction = nixpkgs-stable.lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = [ ./hosts/mass-destruction/configuration.nix ];
          specialArgs = args // { inherit system; };
        };
        # We are having steamed decks?
        steamed-deck = nixpkgs-unstable.lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = [ ./hosts/steamed-deck/configuration.nix ];
          specialArgs = args // { inherit system; };
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
        "rakarake@steamed-deck" = home-manager.lib.homeManagerConfiguration {
          modules = [ ./hosts/steamed-deck/home.nix ];
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

