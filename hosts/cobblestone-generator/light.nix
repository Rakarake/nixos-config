{ pkgs, ... }:
{
  imports = [ ./home.nix ];
  stylix.polarity = "light";
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-latte.yaml";
}
