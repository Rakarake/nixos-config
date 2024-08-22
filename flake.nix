{
  description = "Super system amazing wow";
  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
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
    
    # Cosmic WIP flake
    nixos-cosmic  = {
      url = "github:lilyinstarlight/nixos-cosmic";
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

      # (b -> a -> b) -> b -> [a] -> b
      foldl = f : acc : xs : if xs == [] then acc else foldl f (f acc (builtins.head xs)) (builtins.tail xs);

      args = { inherit inputs outputs self; };
      # Creates nixos configs from list
      makeSystemConfigs = systemConfigs: (foldl ( acc: { name, nixpkgs, system }:
          acc // {
            ${name} = nixpkgs.lib.nixosSystem  {
              inherit system;
              modules = [ ./hosts/${name}/configuration.nix ];
              specialArgs = args // { inherit system; };
            };
          }
      ) {} systemConfigs);

      # Creates a home-manager configs from list
      makeHomeConfigs = homeConfigs: foldl ( acc: { name, nixpkgs, user, variation, system }:
          acc // {
            "${user}@${name}-${variation}" = home-manager.lib.homeManagerConfiguration {
              modules = [ ./hosts/${name}/${variation}.nix ];
              pkgs = (pkgsFor nixpkgs).${system};
              extraSpecialArgs = args // { inherit system; };
            };
          }
      ) {} homeConfigs;
    in
    {
      # Expose NixOS and HomeManager modules, just to be nice
      nixosModules = import ./modules;
      homeManagerModules = import ./home;
      packages = forEachSystem nixpkgs-unstable (pkgs: import ./pkgs { inherit pkgs; });

      functions = {
        inherit foldl;
        inherit makeSystemConfigs;
        inherit makeHomeConfigs;
      };

      nixosConfigurations = makeSystemConfigs [
        # Lappy
        {
          name = "thinky";
          system ="x86_64-linux";
          nixpkgs = nixpkgs-unstable;
        }
        # Desky
        {
          name = "cobblestone-generator";
          system = "x86_64-linux";
          nixpkgs = nixpkgs-unstable;
        }
        # Server
        {
          name = "creeper-spawner";
          system = "x86_64-linux";
          nixpkgs = nixpkgs-stable;
        }
        # Live configurations for when you wanna put NixOS on a USB-stick
        {
          name = "live";
          system = "x86_64-linux";
          nixpkgs = nixpkgs-stable;
        }
        # MASS DESTRUCTION, oh yeah, baby baby
        {
          name = "mass-destruction";
          system = "x86_64-linux";
          nixpkgs = nixpkgs-stable;
        }
        # We are having steamed decks?
        {
          name = "steamed-deck";
          system = "x86_64-linux";
          nixpkgs = nixpkgs-unstable;
        }
      ];

      homeConfigurations = makeHomeConfigs [
        {
          name = "thinky";
          user = "rakarake";
          variation = "dark";
          nixpkgs = nixpkgs-unstable;
          system = "x86_64-linux";
        }
        {
          name = "thinky";
          user = "rakarake";
          variation = "light";
          nixpkgs = nixpkgs-unstable;
          system = "x86_64-linux";
        }
        {
          name = "cobblestone-generator";
          user = "rakarake";
          variation = "dark";
          nixpkgs = nixpkgs-unstable;
          system = "x86_64-linux";
        }
        {
          name = "cobblestone-generator";
          user = "rakarake";
          variation = "light";
          nixpkgs = nixpkgs-unstable;
          system = "x86_64-linux";
        }
        {
          name = "creeper-spawner";
          user = "rakarake";
          variation = "home";
          nixpkgs = nixpkgs-stable;
          system = "x86_64-linux";
        }
        {
          name = "steamed-deck";
          user = "rakarake";
          variation = "home";
          nixpkgs = nixpkgs-unstable;
          system = "x86_64-linux";
        }
      ];
    };
}

