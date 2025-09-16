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
    podman-compose
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
    substituters = [
      "https://hyprland.cachix.org"
      # Needed for CUDA
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      # Needed for CUDA
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # This program is sooo good, I want it everywhere
  programs.nh.enable = true;

  # Podman
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
    # Virtualbox
    #virtualbox.host.enable = true;
  };
}

