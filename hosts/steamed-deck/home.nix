{ pkgs, ... }: {
  imports = [ ../../home/rakarake ../../home/rakarake/theme.nix ];

  # Wallpaper
  stylix.enable = true;
  stylix.image = ./wallpaper.jpg;
  stylix.polarity = "dark";
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";

  home-desktop.enable = true;
  home-hyprland.enable = true;
}
