{ pkgs, ... }:
{
  imports = [ ./styling.nix ];
  stylix.polarity = "light";
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-latte.yaml";
  catppuccin.flavor = "latte";
}
