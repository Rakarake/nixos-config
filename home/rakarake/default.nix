# Root of my home-manager config, enable either desktop or server
# to get nice stuff.
# Choose a desktop such as gnome or kde.
{ inputs, ... }:
{
  imports = [
    ./common.nix
    ./desktop.nix
    ./server.nix
    ./gnome.nix
    ./hyprland
    inputs.nix-index-database.hmModules.nix-index
    # Enable to use development environment
    inputs.dev-stuff.homeManagerModules.default
    inputs.stylix.homeManagerModules.stylix
  ];
}
