{ lib, config, pkgs, ... }:
with lib;                      
let
  cfg = config.home-dwl;
  # The autostart script
  dwl-autostart = pkgs.writeShellScriptBin "dwl-autostart" '' 
    # Needed for portal
    ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY XDG_SESSION_TYPE
    wlr-randr --output DP-1 --mode 1920x1080@144.001007 --pos 1920,0
    wlr-randr --output DP-2 --mode 1920x1080@143.854996 --pos 0,0
    swaybg -i ${config.stylix.image} &
    swaync &
    yambar
    nextcloud &
    sleep infinity
  '';
  # Starts dwl with the right options in the right context
  dwl-startup = pkgs.writeShellScriptBin "dwl-startup" '' 
    export XDG_CURRENT_DESKTOP=dwl
    ${dwl}/bin/dwl -s ${dwl-autostart}/bin/dwl-autostart
  '';
  dwl = pkgs.dwl.overrideAttrs (old: {
    src = ./.;
    prePatch = ''
      echo -e '${confighExtra}\n$(cat config.h)' > config.h
    '';
    #printf '${confighExtra}' >> config.h
    #echo -e '${confighExtra}' >> config.h
  });

  # Extra config.h content that uses some nix stuff
  # 'pidof swaylock' makes sure that we do not start multiple instances of swaylock
  confighExtra = ''
    /* logging */
    static int log_level = WLR_ERROR;
    /* keybind commands */
    static const char *lockscreen[] = { "/bin/sh", "-c", "pidof swaylock || swaylock -k -C ~/.config/swaylock.conf -i ${config.stylix.image}", NULL };
    static const char *filemanager[] = { "${config.home-xdg.file-manager.bin}", NULL };
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
      nautilus
      dwl-autostart
      dwl-startup
    ];

    # Swaylock config file
    xdg.configFile."swaylock.conf".source = ../swaylock.conf;

    # Yambar
    programs.yambar = {
      enable = true;
      settings = {
        bar = {
          location = "top";
          height = 26;
          background = "00000066";
          center = [
            {
              clock.content = [
                {
                  string.text = "{time}";
                }
              ];
            }
          ];
        };
      };
    };

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
