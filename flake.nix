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
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = attrs@{ self, nixpkgs, home-manager, rust-overlay, ... }:
  let
    overlays = [
      ({ pkgs, ... }: {
        nixpkgs.overlays = [ rust-overlay.overlays.default ];
        environment.systemPackages = [ (pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default)) ];
      })
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
            home-manager.users.rakarake = import ./home.nix;
          }
      ] ++ overlays;
    };
  };
}
