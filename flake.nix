# If you want to use another channel of nixpkgs, override nixpkgs input from
# arguments.
{
  description = "Super system amazing wow";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
      #url = "github:danth/stylix/release-26.05";
      url = "github:danth/stylix/release-26.05";
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

    # Xremap
    xremap = {
      url = "github:xremap/nix-flake";
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
    #nmrs = {
    #  url = "github:cachebag/nmrs";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    eden = {
      url = "github:Grantimatter/eden-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Wallpaper engine thinymajingy
    glonkers = {
      url = "git+https://git.rakarake.xyz/Rakarake/glonkers";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mdf-bouncer = {
      url = "git+https://codeberg.org/Rakarake/mdf-bouncer";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-versions = {
      url = "github:vic/nix-versions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";
  };
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}

