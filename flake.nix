{
  description = "My NixOS configuration";
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
  outputs =
    {
      self,
      nixpkgs-stable,
      nixpkgs-unstable,
      home-manager,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      # If using nixpkgs-stable, just don't use home manager stuff
      lib = nixpkgs: (nixpkgs.lib // home-manager.lib);
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      # Smooth
      forEachSystem = nixpkgs: (f: (lib nixpkgs).genAttrs systems (system: f (pkgsFor nixpkgs).${system}));
      # Set of { "system".pkgs }
      pkgsFor = nixpkgs: (lib nixpkgs).genAttrs systems (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
      );
    in
    {
      nixosModules = import ./modules;
      homeManagerModules = import ./home;
      packages = forEachSystem nixpkgs-unstable (pkgs: import ./pkgs { inherit pkgs; });

      nixosConfigurations = {
        # Lappy
        rakarake-thinkpad = (lib nixpkgs-unstable).nixosSystem {
          modules = [ ./hosts/rakarake-thinkpad/configuration.nix ];
          specialArgs = {
            inherit inputs outputs;
          };
        };
      };

      homeConfigurations = {
        # Lappy
        "rakarake@rakarake-thinkpad" = (lib nixpkgs-unstable).homeManagerConfiguration {
          modules = [ ./hosts/rakarake-thinkpad/home.nix ];
          pkgs = (pkgsFor nixpkgs-unstable).x86_64-linux;
          extraSpecialArgs = {
            inherit inputs outputs;
          };
        };
      };
    };
}

