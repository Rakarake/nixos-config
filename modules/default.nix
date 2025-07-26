{ inputs, pkgs, ... }: {
  imports = [
    ./desktop.nix
    ./gnome.nix
    ./kde.nix
    ./hyprland.nix
    ./wlroots.nix
    ./river.nix
    # At least make home manager available
    inputs.home-manager.nixosModules.home-manager
    inputs.agenix.nixosModules.default
  ];
  environment.systemPackages = with pkgs; [
    # Make the home manager command available
    pkgs.home-manager
    inputs.agenix.packages."${system}".default
    comma
  ];
  nixpkgs.overlays = [
    # Replace openssl with libressl
    (final: super: { 
      nginxStable = super.nginxStable.override { openssl = super.pkgs.libressl; }; 
    })
  ];
  # Global nix settings
  nix.settings = {
    # Enable Flakes
    experimental-features = [ "flakes" "nix-command" ];
    # Cachix
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
