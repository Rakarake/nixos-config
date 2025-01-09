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
  dwl-autostart = pkgs.writeShellScriptBin "dwl-autostart" '' 
    wlr-randr --output DP-1 --mode 1920x1080@144.001007 --pos 1920,0
    wlr-randr --output DP-2 --mode 1920x1080@143.854996 --pos 0,0
    ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &
    ${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr &
    swaybg -i ${config.stylix.image} &
    #swaync &
    gsettings set org.gnome.nm-applet disable-disconnected-notifications "true"
    gsettings set org.gnome.nm-applet disable-connected-notifications "true"
    nextcloud &
    blueman-applet &
    nm-applet &
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
      dwl-autostart
    ];

    home.shellAliases = {
      # For starting a session from the tty (or a nested one)
      dwl-startup = "dwl -s ${dwl-autostart}/bin/dwl-autostart";
    };

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

    # Theming
    gtk.iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
  };
}
