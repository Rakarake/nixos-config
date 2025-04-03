{ inputs, ... }: {
  imports = [
    ./global.nix
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
}
