# If you want to use another channel of nixpkgs, override nixpkgs input from
# arguments.
{
  description = "Super system amazing wow";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # UwU
    queercat = {
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
    
    # Agenix
    agenix = {
      url = "github:ryantm/agenix";
    };

    # Catppuccin
    catppuccin = {
      url = "github:catppuccin/nix";
    };

    # Xremap
    xremap = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Hyprland
    hyprland = {
      url = "github:hyprwm/Hyprland";
    };

    # Grompt
    grompt = {
      url ="github:loafey/grompt";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };
  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      # If using nixpkgs-stable, just don't use home manager stuff
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      # Smooth
      forEachSystem = (f: nixpkgs.lib.genAttrs systems (system: f pkgsFor.${system}));
      # Set of { "system".pkgs }
      pkgsFor = nixpkgs.lib.genAttrs systems (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
      );

      # (b -> a -> b) -> b -> [a] -> b
      foldl = f : acc : xs : if xs == [] then acc else foldl f (f acc (builtins.head xs)) (builtins.tail xs);

      # Stuff accessible in modules
      args = {
        inherit inputs outputs self;
        ssh-keys = import ./ssh-keys.nix;
      };

      # Helper function to create a list of only the provided paths that actually exist.
      optionalPaths = listOfPaths: foldl (acc: val: acc ++ (nixpkgs.lib.optional (builtins.pathExists val)) val) [] listOfPaths;

      # Creates a home-manager configs from list
      # If no variation is specified, "user@system-default" is generated
      makeHomeConfigs = homeConfigs: foldl ( acc: user-dir:
          let
            user = user-dir;
            hostname = **;
            variation = **;
            system = ;
            template = acc // {
              "${user}@${hostname}-${variation}" = home-manager.lib.homeManagerConfiguration {
                modules = optionalPaths [
                  ./home/${user}/default.nix
                  ./home/${user}/${variation}.nix
                  ./hosts/${hostname}/home.nix
                  ./home/${user}/hosts/${hostname}.nix
                ];
                pkgs = pkgsFor.${system};
                extraSpecialArgs = args // { inherit system hostname user; };
              };
            };
          in
          acc // [(template "dark") (template "light") (template "")]
      ) {} (builtins.attrNames (builtins.readDir ./home));

      # WIP idea: systems and hm-configs generated from file-folder pairs in
      # paths
      # WIP, generates the list of systems from directories
      # host-dir is the the name of the system/hostname, derived
      # from the files in ./hosts/
      newMakeSystemConfigs = foldl ( acc: host-dir:
          let
            hostname = host-dir;
            system = import ./hosts/${host-dir}/system.nix;
          in
          acc // {
            ${hostname} = nixpkgs.lib.nixosSystem {
              inherit system;
              modules = optionalPaths [ ./hosts/${hostname}/configuration.nix ./modules ];
              specialArgs = args // { inherit system hostname; };
            };
          }
      ) {} (builtins.attrNames (builtins.readDir ./hosts));
    in
    {
      # Expose NixOS and HomeManager modules, just to be nice
      nixosModules = import ./modules;
      homeManagerModules = import ./home;
      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });

      functions = {
        inherit foldl;
        inherit makeSystemConfigs;
        inherit makeHomeConfigs;
      };

      nixosConfigurations = newMakeSystemConfigs;

      homeConfigurations = makeHomeConfigs [
        {
          hostname = "thinky";
          user = "rakarake";
          variation = "dark";
          nixpkgs = nixpkgs-unstable;
          system = "x86_64-linux";
        }
        {
          hostname = "thinky";
          user = "rakarake";
          variation = "light";
          nixpkgs = nixpkgs-unstable;
          system = "x86_64-linux";
        }
        {
          hostname = "thinky";
          user = "rakarake";
          variation = "default";
          nixpkgs = nixpkgs-unstable;
          system = "x86_64-linux";
        }
        {
          hostname = "cobblestone-generator";
          user = "rakarake";
          variation = "dark";
          nixpkgs = nixpkgs-unstable;
          system = "x86_64-linux";
        }
        {
          hostname = "cobblestone-generator";
          user = "rakarake";
          variation = "light";
          nixpkgs = nixpkgs-unstable;
          system = "x86_64-linux";
        }
        {
          hostname = "cobblestone-generator";
          user = "rakarake";
          variation = "default";
          nixpkgs = nixpkgs-unstable;
          system = "x86_64-linux";
        }
        {
          hostname = "creeper-spawner";
          user = "rakarake";
          variation = "default";
          nixpkgs = nixpkgs-unstable;
          system = "x86_64-linux";
        }
        {
          hostname = "steamed-deck";
          user = "rakarake";
          variation = "light";
          nixpkgs = nixpkgs-unstable;
          system = "x86_64-linux";
        }
        {
          hostname = "steamed-deck";
          user = "rakarake";
          variation = "dark";
          nixpkgs = nixpkgs-unstable;
          system = "x86_64-linux";
        }
        {
          hostname = "mass-destruction";
          user = "rakarake";
          variation = "default";
          nixpkgs = nixpkgs-unstable;
          system = "x86_64-linux";
        }
      ];
    };
}

