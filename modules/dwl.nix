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

      security.polkit.enable = true;

      # Bluetooth
      hardware.bluetooth.enable = true;
      services.blueman.enable = true;

      # Portals
      xdg.portal.enable = true;
      xdg.portal.configPackages = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];

      # Dbus go wrommm 
      services.dbus.enable = lib.mkDefault true;

      # Keyring, dbus service to remember passwords
      services.gnome.gnome-keyring.enable = true;
      
      xdg.portal.wlr.enable = true;  # Desktop portal
      #services.seatd.enable = true;  # Arch wiki says this is needed
    };
}
