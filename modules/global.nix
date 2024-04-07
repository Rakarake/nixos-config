{ pkgs, inputs, ... }: {
  imports = [
    # At least make home manager available
    inputs.home-manager.nixosModules.home-manager
  ];
  environment.systemPackages = [
    # Make the home manager command available
    pkgs.home-manager
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
