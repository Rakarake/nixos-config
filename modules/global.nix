{ pkgs, inputs, system, ... }: {
  imports = [
    # At least make home manager available
    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-cosmic.nixosModules.default
    inputs.agenix.nixosModules.default
  ];
  environment.systemPackages = [
    # Make the home manager command available
    pkgs.home-manager
    inputs.agenix.packages."${system}".default
  ];
  nixpkgs.overlays = [
    # Replace openssl with libressl
    (final: super: { 
      nginxStable = super.nginxStable.override { openssl = super.pkgs.libressl; }; 
    })
  ];
  # Enable Flakes
  nix.settings.experimental-features = [ "flakes" "nix-command" ];
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
