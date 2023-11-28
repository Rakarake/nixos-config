# Root of my home-manager config, enable either desktop or server
# to get nice stuff.
# Choose a desktop such as gnome or kde.
{
  imports = [
    ./desktop.nix
    ./gnome.nix
    ./hyprland
  ];
}
