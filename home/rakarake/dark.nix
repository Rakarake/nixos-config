{ pkgs, ... }:
{
  imports = [ ./styling.nix ];
  stylix.polarity = "dark";
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/decaf.yaml";
  catppuccin.flavor = "macchiato";
}
