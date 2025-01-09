  { lib, outputs, system, config, pkgs, ... }:
  with lib;                      
  let
    cfg = config.cfg-dwl;
  in {
    options.cfg-dwl = {
      enable = mkEnableOption "dwl custom";
    };
    config = mkIf cfg.enable {

      environment.systemPackages = with pkgs; [
        outputs.packages.${system}.dwl-custom
        foot
        wlr-randr
      ];
      # Enable "pam thingy" for swaylock so that it can unlock with password
      security.pam.services.swaylock = {};
      security.pam.services.polkit_gnome = {};

      # Bluetooth
      hardware.bluetooth.enable = true;
      services.blueman.enable = true;

      # Portals
      xdg.portal.enable = true;
      xdg.portal.configPackages = [ pkgs.xdg-desktop-portal-wlr ];
      xdg.portal.wlr.enable = true;    # Desktop portal
      xdg.portal.wlr.settings = {
        screencast = {
          output_name = "HDMI-A-1";
          max_fps = 30;
          chooser_type = "simple";
          chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
        };
      };
    };
}
