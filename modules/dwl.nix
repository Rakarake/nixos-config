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
      xdg.portal.configPackages = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      # Taken from https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/programs/wayland/sway.nix
      xdg.portal.config = {
        dwl = {
          default = "gtk";
          "org.freedesktop.impl.portal.ScreenCast" = "wlr";
          "org.freedesktop.impl.portal.Screenshot" = "wlr";
          # ignore inhibit bc gtk portal always returns as success,
          # despite sway/the wlr portal not having an implementation,
          # stopping firefox from using wayland idle-inhibit
          "org.freedesktop.impl.portal.Inhibit" = "none";
        };
      };

      # Must specify monitors in host config
      xdg.portal.wlr.enable = true;

      security.polkit.enable = true;               # Polkit
      services.dbus.enable = lib.mkDefault true;   # Dbus go wrommm 
      services.gnome.gnome-keyring.enable = true;  # Keyring, dbus service to remember passwords
      services.seatd.enable = true;                # Arch wiki says this is needed
    };
}
