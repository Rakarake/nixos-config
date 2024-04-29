# Gnome system configuration
{ lib, config, ... }:
with lib;                      
let
  cfg = config.cfg-gnome;
in {
  options.cfg-gnome = {
    enable = mkEnableOption "Custom gnome system configuration";
  };
  config = mkIf cfg.enable {
    # Enable the GNOME Desktop Environment.
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    programs.gnupg.agent = {
      pinentryPackage = "gnome3";
    };

    environment.variables = {
      #QT_QPA_PLATFORM = "wayland";
    };
  };
}
