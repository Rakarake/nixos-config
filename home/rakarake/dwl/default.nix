{ lib, config, pkgs, ... }:
with lib;                      
let
  cfg = config.home-dwl;
  # pidof swaylock makes sure that we do not start multiple instances of swaylock
  swaylockCommand = "pidof swaylock || swaylock -k -C ~/.config/swaylock.conf -i ${config.stylix.image}";
  raiseVolumeCommand = "amixer set Master 5%+";
  lowerVolumeCommand = "amixer set Master 5%-";
  muteVolumeCommand = "amixer set Master toggle";
  muteMicCommand = "amixer set Capture toggle";
  fileManagerCommand = "thunar";
  # The autostart script
  dwl-autostart = pkgs.writeShellScriptBin "dwl-autostart" '' 
    # Needed for portal
    #dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=dwl
    ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY XDG_SESSION_TYPE
    wlr-randr --output DP-1 --mode 1920x1080@144.001007 --pos 1920,0
    wlr-randr --output DP-2 --mode 1920x1080@143.854996 --pos 0,0
    #${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &
    #${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr &
    #${pkgs.xdg-desktop-portal-gtk}/libexec/xdg-desktop-portal-gtk &
    swaybg -i ${config.stylix.image} &
    #swaync &
    gsettings set org.gnome.nm-applet disable-disconnected-notifications "true"
    gsettings set org.gnome.nm-applet disable-connected-notifications "true"
    #nextcloud &
    blueman-applet &
    nm-applet &
    sleep infinity
  '';
  # Starts dwl with the right options in the right context
  dwl-startup = pkgs.writeShellScriptBin "dwl-startup" '' 
    export XDG_CURRENT_DESKTOP=dwl
    ${dwl}/bin/dwl -s ${dwl-autostart}/bin/dwl-autostart
    #dbus-run-session ${dwl}/bin/dwl -s ${dwl-autostart}/bin/dwl-autostart
  '';
  dwl = pkgs.dwl.overrideAttrs (old: {
    src = ./.;
    prePatch = ''
      printf '${confighExtra}' >> config.h
    '';
  });
  confighExtra = ''
    /* logging */
    static int log_level = WLR_ERROR;
  '';
in {

  options.home-dwl = {
    # Option to enable dwl config
    enable = mkEnableOption "Custom dwl config";
  };
  config = mkIf cfg.enable {
    home-rofi.enable = true;
    home.packages = with pkgs; [
      pipewire                     # Screensharing
      polkit_gnome                 # Polkit / gparted popup prompt provider
      swaylock                     # Screenlocker
      grim                         # Screenshot utility
      slurp                        # Screen "area" picker utility
      swaybg                       # Anime wallpapers
      swaynotificationcenter       # Notification daemon
      pamixer                      # Used for panel sound control
      alsa-utils                   # keyboard volume control
      playerctl                    # MPRIS global player controller
      swayidle                     # Idle inhibitor, knows when computer is ueseless
      brightnessctl                # Laptop brighness controls
      networkmanagerapplet         # Log in to your wifi with this cool utility
      papirus-icon-theme           # Used to make nm-applet and blueman-applet not look ass
      xfce.thunar
      gvfs  # might be needed for thunar trash-can
      dwl-autostart
      dwl-startup
    ];

    # Swaylock config file
    xdg.configFile."swaylock.conf".source = ../swaylock.conf;

    ## Swaync theme file
    #xdg.configFile."swaync/style.css".source = ./swaync.css;
    
    # Dconf settings
    dconf.settings = {
      # Locale
      "system/locale" = {
        region = "sv_SE.UTF-8";
      };
    };

    ## Desktop portal config
    #xdg.configFile."xdg-desktop-portal-wlr/config".text = ''
    #  [screencast]
    #  output_name=DP-1
    #  max_fps=30
    #  chooser_type=simple
    #  chooser_cmd=slurp -f %o -or
    #'';
    #xdg.configFile."xdg-desktop-portal/default-portals.conf".text = ''
    #  [preferred]
    #  default=gtk
    #  org.freedesktop.impl.portal.Screenshot=wlr
    #  org.freedesktop.impl.portal.ScreenCast=wlr
    #'';

    # Theming
    gtk.iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
  };
}
