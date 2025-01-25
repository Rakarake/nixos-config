# Hyprland system configuration
{ lib, inputs, outputs, system, config, pkgs, ... }:
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

    # Needed for thunar/nautilus trash-can, other one for dolphin
    services.gvfs.enable = true;

    ## Get nautilus to open other terminals
    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "foot";
    };
    environment.systemPackages = with pkgs; [
      nautilus
    ];

    environment.sessionVariables = {
      # NixOS specific option for enabling wayland in Electron apps
      #NIXOS_OZONE_WL = "1";
      # Make QT use wayland
      #QT_QPA_PLATFORM = "wayland";
    };
    # Enable "pam thingy" for swaylock so that it can unlock with password
    security.pam.services.swaylock = {};
    security.pam.services.polkit_gnome = {};

    #  Polkit
    security.polkit.enable = true;

    # Keyring, dbus service to remember passwords
    services.gnome.gnome-keyring.enable = true;
    # Bluetooth
    services.blueman.enable = true;
    hardware.bluetooth.enable = true;
  };
}
