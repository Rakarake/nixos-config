# Hyprland system configuration
{ lib, inputs, config, pkgs, ... }:
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
    };

    ## Witchcraft to get nautilus to open other terminals
    #services.xserver.desktopManager.gnome.extraGSettingsOverridePackages = [
    #  pkgs.nautilus-open-any-terminal
    #];
    ## Let nautilus find extensions
    #environment.sessionVariables.NAUTILUS_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";
    #environment.pathsToLink = [
    #  "/share/nautilus-python/extensions"
    #];

    environment.sessionVariables = {
      # NixOS specific option for enabling wayland in Electron apps
      #NIXOS_OZONE_WL = "1";
      # Make QT use wayland
      #QT_QPA_PLATFORM = "wayland";
    };
    # Enable "pam thingy" for swaylock so that it can unlock with password
    security.pam.services.swaylock = {};
    security.pam.services.polkit_gnome = {};
    # We use gdm cuz lazy
    services.xserver.displayManager.gdm.enable = true;
    # Cuz we lazy
    services.xserver.desktopManager.gnome.enable = true;
    # Blueman service
    services.blueman.enable = true;
  };
}
