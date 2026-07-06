# If you want to use another channel of nixpkgs, override nixpkgs input from
# arguments.
{
  description = "Super system amazing wow";
  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    home-manager-unstable = {
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
      url = "github:danth/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    stylix-unstable = {
      url = "github:danth/stylix/master";
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
    
    # Agenix
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Xremap
    xremap = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Grompt
    grompt = {
      url ="github:loafey/grompt";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    
    # Discord to matrix bridge
    out-of-your-element = {
      url = "git+https://cgit.rory.gay/nix/OOYE-module.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # NetworkManager GUI
    #nmrs = {
    #  url = "github:cachebag/nmrs";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    eden = {
      url = "github:Grantimatter/eden-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Wallpaper engine thinymajingy
    glonkers = {
      url = "git+https://git.rakarake.xyz/Rakarake/glonkers";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    mdf-bouncer = {
      url = "git+https://codeberg.org/Rakarake/mdf-bouncer";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nix-versions = {
      url = "github:vic/nix-versions";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager-unstable";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";
  };
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
    } {
      _module.args = {
        dotfiles = "/home/rakarake/Projects/nixos-config";
      };
      imports = [
        (inputs.import-tree ./modules)
      ];
    };
}

