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
  };

  outputs = attrs@{ self, nixpkgs, home-manager, fenix, ... }:
  let
    overlays = [
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
    ];
  in
  {
    # Thonkpad configuration go wrrom
    nixosConfigurations.rakarake-thinkpad = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./desktop-configuration.nix
        ./hosts/rakarake-thinkpad/configuration.nix 
        home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rakarake = import ./home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
      ] ++ overlays;
    };
    # PC
    nixosConfigurations.rakarake-pc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./desktop-configuration.nix
        ./hosts/rakarake-pc/configuration.nix 
        home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rakarake = import ./hosts/rakarake-pc/home.nix;
          }
      ] ++ overlays;
    };
  };
}

