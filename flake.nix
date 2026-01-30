# If you want to use another channel of nixpkgs, override nixpkgs input from
# arguments.
{
  description = "Super system amazing wow";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # UwU
    queercat = {
      url = "github:Elsa002/queercat";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flimpy: Vscode Extensions
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix pre-baked index
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Styling / Colorscheme / Font management
    stylix = {
      url = "github:danth/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Steamdeck related options
    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Bingbingo server
    bingbingo = {
      url = "github:Rakarake/bingbingo";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Agenix
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Catppuccin
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Xremap
    xremap = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Grompt
    grompt = {
      url ="github:loafey/grompt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Discord to matrix bridge
    out-of-your-element = {
      url = "git+https://cgit.rory.gay/nix/OOYE-module.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # NetworkManager GUI
    nmrs = {
      url = "github:cachebag/nmrs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      inherit (self) outputs;

      lib = nixpkgs.lib;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      # Smooth
      forEachSystem = (f: lib.genAttrs systems (system: f pkgsFor.${system}));

      # Attr set of pkgs access like this: pkgsFor."x86_64-linux"
      pkgsFor = lib.genAttrs systems (
        system:
        import nixpkgs {
          inherit system overlays;
          config.allowUnfree = true;
        }
      );

      overlays = [
        # SDL2 newer version
        #(final: prev: {
        #  SDL2 = prev.SDL2.overrideAttrs (finalAttrs: previousAttrs: {
        #    src = final.fetchFromGitHub {
        #      owner = "libsdl-org";
        #      repo = "sdl2-compat";
        #      rev = "a5d1e2a0dfd6b6b7d3fd257f3efccbb20e9c30e4";
        #      hash = "sha256-En6DGRcdOLGljUlBLcHD1E6PYdwMpU1vqq4o3hfOU44=";
        #    };
        #  });
        #})
      ];

      # Create packages from ./pkgs
      genPkgs = pkgs:
        lib.genAttrs (builtins.attrNames (builtins.readDir ./pkgs)) (pkgName:
          pkgs.callPackage ./pkgs/${pkgName} { }
      );

      # foldl implementation.
      # (b -> a -> b) -> b -> [a] -> b
      foldl = builtins.foldl'; #f : acc : xs : if xs == [] then acc else foldl f (f acc (builtins.head xs)) (builtins.tail xs);

      # Stuff accessible in nixos/home-manager modules
      args = {
        inherit inputs outputs self;
        ssh-keys = import ./ssh-keys.nix;
      };

      # Helper function to create a list of only the provided paths that actually exist.
      optionalPaths = listOfPaths: foldl
        (acc: val: acc ++ (lib.optional (if val != "" then builtins.pathExists val else false)) val)
        [] listOfPaths;

      # All hosts/hostnames with extra info (system for now).
      # List of attr-sets with schema: { hostname = <hostname>; system = <system>; }
      allHosts = map (hostname: { inherit hostname; } // (import ./hosts/${hostname}/system.nix))
          (builtins.attrNames (builtins.readDir ./hosts));
      
      # List of all home-manager users, that is all directories in home/
      allHomeUsers = builtins.attrNames (builtins.readDir ./home);

      # Helper function to create a home-manager config.
      # Takes user, varation (typically "light", "dark", or null)
      # and host (see allHosts above).
      homeUserTemplate = user: variation: host:
      let
        hostname = host.hostname;
        system = host.system;
      in {
        "${user}@${hostname}${if variation != null then "-${variation}" else ""}"
          = home-manager.lib.homeManagerConfiguration {
          modules = optionalPaths ([
            ./home/${user}/default.nix
            (lib.optionalString (variation != null) ./home/${user}/${variation}.nix)
            ./hosts/${hostname}/home.nix
            ./home/${user}/hosts/${hostname}.nix
          ]) ++ [
            {
              home.username = user;
              home.homeDirectory = "/home/${user}";
              programs.home-manager.enable = true;
              nixpkgs.overlays = overlays;
              home.stateVersion = "23.05";
            }
          ];
          pkgs = pkgsFor.${system};
          extraSpecialArgs = args // { inherit system hostname user; };
        };
      };

      # Creates home-manager configurations for all users, for all
      # systems, for all variations (quite a lot of them).
      makeHomeConfigs = foldl ( acc: user-dir:
          let
            u = user-dir;
            t = homeUserTemplate;
            hs = allHosts;
          in
          acc //
            (foldl (acc: host: acc // (t u null host)) {} hs) //
            (foldl (acc: host: acc // (t u "light" host)) {} hs) //
            (foldl (acc: host: acc // (t u "dark" host)) {} hs)
      ) {} allHomeUsers;

      # Creates nixos system configurations from the hosts/ directory,
      # expects there to be a system.nix file there.
      makeSystemConfigs = foldl ( acc: host:
          let
            hostname = host.hostname;
            system = (import ./hosts/${hostname}/system.nix).system;
          in
          acc // {
            ${hostname} = lib.nixosSystem {
              inherit system;
              modules = optionalPaths ([
                ./hosts/${hostname}/configuration.nix
                ./modules/default.nix
              ]) ++ [
                {
                  networking.hostName = lib.mkDefault hostname;
                  nixpkgs.overlays = overlays;
                  nixpkgs.hostPlatform = lib.mkDefault system;
                }
              ];
              specialArgs = args // { inherit system hostname; };
            };
          }
      ) {} allHosts;
    in
    rec {
      # Expose NixOS and HomeManager modules, just to be nice
      #nixosModules = import ./modules;
      homeManagerModules = import ./home;
      # Packages and scripts
      packages = (forEachSystem (pkgs: (genPkgs pkgs) // ((import ./scripts/.) pkgs extra.writeShellApplicationWithArguments)));
      # Only scripts
      scripts = (forEachSystem (pkgs: ((import ./scripts/.) pkgs extra.writeShellApplicationWithArguments)));
      # Some functions
      extra = {
        inherit foldl;
        inherit makeSystemConfigs;
        inherit makeHomeConfigs;
        statefulServerTemplate = import ./functions/statefulServerTemplate.nix;
        writeShellApplicationWithArguments = import ./functions/writeShellApplicationWithArguments.nix;
        mutableDotfiles = import ./functions/mutableDotfiles.nix;
      };
      nixosConfigurations = makeSystemConfigs;
      homeConfigurations = makeHomeConfigs;
    };
}

