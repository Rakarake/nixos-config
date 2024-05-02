{
  description = "Super system amazing wow";
  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Hyprland
    hyprland = {
      url = "github:hyprwm/hyprland";
    };
    xdg-desktop-portal-hyprland = {
      url = "github:hyprwm/xdg-desktop-portal-hyprland";
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

    # Wgsl language server
    wgsl_analyzer = {
      url = "github:wgsl-analyzer/wgsl-analyzer";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Nix pre-baked index
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
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
      nixosModules = import ./modules;
      homeManagerModules = import ./home;
      packages = forEachSystem nixpkgs-unstable (pkgs: import ./pkgs { inherit pkgs; });

      nixosConfigurations = {
        # Lappy
        rakarake-thinkpad = nixpkgs-unstable.lib.nixosSystem {
          modules = [ ./hosts/rakarake-thinkpad/configuration.nix ];
          specialArgs = args;
        };
        # Desky
        rakarake-pc = nixpkgs-unstable.lib.nixosSystem {
          modules = [ ./hosts/rakarake-pc/configuration.nix ];
          specialArgs = args;
        };
        # Server
        creeper-spawner = nixpkgs-stable.lib.nixosSystem {
          modules = [ ./hosts/creeper-spawner/configuration.nix ];
          specialArgs = args;
        };
        # Live configurations for when you wanna put NixOS on a USB-stick
        live = nixpkgs-unstable.lib.nixosSystem {
          modules = [ ./live.nix ];
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
        "rakarake@rakarake-thinkpad" = home-manager.lib.homeManagerConfiguration {
          modules = [ ./hosts/rakarake-thinkpad/home.nix ];
          pkgs = (pkgsFor nixpkgs-unstable).x86_64-linux;
          extraSpecialArgs = args;
        };
        "rakarake@rakarake-pc" = home-manager.lib.homeManagerConfiguration {
          modules = [ ./hosts/rakarake-pc/home.nix ];
          pkgs = (pkgsFor nixpkgs-unstable).x86_64-linux;
          extraSpecialArgs = args;
        };
      };
    };
}

