# Root of my home-manager config, enable either desktop or server
# to get nice stuff.
# Choose a desktop such as gnome or kde.
{ inputs, lib, ... }:
{
  nixpkgs.config.allowUnfree = true;
  imports = [
    ./common.nix
    ./desktop.nix
    ./server.nix
    ./gnome.nix
    ./hyprland
    ./cosmic
    ./neovim
    ./rofi
    ./dwl
    ./river
    inputs.nix-index-database.hmModules.nix-index
    inputs.stylix.homeManagerModules.stylix
    inputs.catppuccin.homeManagerModules.catppuccin
    inputs.xremap.homeManagerModules.default
  ];
  # Follow the rules!
  services.xremap.enable = lib.mkDefault false;
}
