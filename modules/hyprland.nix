# Hyprland system configuration
{ lib, config, hyprland, pkgs, ... }:
with lib;                      
let
  cfg = config.cfg-hyprland;
in {
  options.cfg-hyprland = {
    enable = mkEnableOption "Custom gnome system configuration";
  };
  config = mkIf cfg.enable {
    # Enable hyprland
    programs.hyprland = {
      enable = true;
      package = hyprland.packages.${pkgs.system}.hyprland;
    };
    # Enable "pam thingy" for swaylock so that it can unlock with password
    security.pam.services.swaylock = {};
    # We use gdm cuz lazy
    services.xserver.displayManager.gdm.enable = true;
    # Cuz we lazy
    services.xserver.desktopManager.gnome.enable = true;
  };
}
