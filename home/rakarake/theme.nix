# General style, import this, no options available
{ pkgs, ... }:
{
  stylix.cursor.name = "Adwaita";
  stylix.cursor.size = 24;
  stylix.fonts = {
    monospace = {
      package = pkgs.fira-code;
      name = "Fira Code";
    };
    sizes = {
      desktop = 11;
      applications = 10;
      terminal = 12;
    };
  };
}
