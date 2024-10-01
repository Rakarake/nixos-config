{ lib, ... }: {
  # Wallpaper
  stylix.image = lib.mkForce ./wallpaper.png;

  home-desktop.enable = true;
  home-hyprland.enable = true;
}
