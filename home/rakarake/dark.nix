{ pkgs, ... }:
{
  imports = [ ./styling.nix ];
  stylix.polarity = "dark";
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
}
