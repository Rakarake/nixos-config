{ lib, config, ... }:
with lib;                      
let
  cfg = config.cfg-kde;
in {
  options.cfg-kde = {
    enable = mkEnableOption "Kde system config";
  };
  config = mkIf cfg.enable {
    # Enable KDE
    services.xserver.desktopManager.plasma5.enable = true;
    services.xserver.displayManager.sddm.enable = true;
    programs.dconf.enable = true;
    # Plasma Wayland as default session
    services.xserver.displayManager.defaultSession = "plasmawayland";
  };
}
