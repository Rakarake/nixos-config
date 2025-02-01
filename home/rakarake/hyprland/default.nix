# Hyprland home-manager module
{ lib, config, pkgs, ... }:
with lib;                      
let
  cfg = config.home-hyprland;
  # pidof swaylock makes sure that we do not start multiple instances of swaylock
  swaylockCommand = "pidof swaylock || swaylock -k -C ~/.config/swaylock.conf -i ${config.stylix.image}";
  raiseVolumeCommand = "amixer set Master 5%+";
  lowerVolumeCommand = "amixer set Master 5%-";
  muteVolumeCommand = "amixer set Master toggle";
  muteMicCommand = "amixer set Capture toggle";
  fileManagerCommand = "nautilus";
in {

  imports = [
    ./waybar.nix
  ];

  options.home-hyprland = {
    # Option to enable Hyprland config
    enable = mkEnableOption "Custom Hyprland system configuration";
    # Monitor and their workspaces, if relevant
    additionalConfig = mkOption {
      type = types.str;
      default = "";
    };
    # Whether to use swayidle or not
    useSwayidle = mkOption {
      type = types.bool;
      default = true;
    };
    wallpaper = mkOption {
      type = types.str;
      default = "";
    };
  };
  config = mkIf cfg.enable {
    # Enable Hyprland
    wayland.windowManager.hyprland.enable = true;
    wayland.windowManager.hyprland.systemd.enable = true;
    home-waybar.enable = true;
    home-rofi.enable = true;

    # Packages needed by the Hyprland configuration
    home.packages = with pkgs; [
      pipewire                     # Screensharing
      polkit_gnome                 # Polkit / gparted popup prompt provider
      #nautilus                    # File manager
      swaylock                     # Screenlocker
      grim                         # Screenshot utility
      slurp                        # Screen "area" picker utility
      wl-screenrec                 # Screen reccording utility
      swaybg                       # Anime wallpapers
      swaynotificationcenter       # Notification daemon
      pamixer                      # Used for panel sound control
      alsa-utils                   # keyboard volume control
      playerctl                    # MPRIS global player controller
      swayidle                     # Idle inhibitor, knows when computer is ueseless
      brightnessctl                # Laptop brighness controls
      networkmanagerapplet         # Log in to your wifi with this cool utility
      papirus-icon-theme           # Used to make nm-applet and blueman-applet not look ass
      hyprpicker                   # Color picker
      emote
      #nautilus-open-any-terminal
      #nautilus-python
      hyprland-protocols
      nautilus
    ];

    # Swaylock config file
    xdg.configFile."swaylock.conf".source = ../swaylock.conf;

    # Swaync theme file
    xdg.configFile."swaync/style.css".source = ../swaync.css;
    
    ## KDE / Dolphin config file
    #home.file.".config/kdeglobals".source = ./kdeglobals;
    
    # Dconf settings
    dconf.settings = {
      # Locale
      "system/locale" = {
        region = "sv_SE.UTF-8";
      };
      # Nautilus terminal
      "com/github/stunkymonkey/nautilus-open-any-terminal" = {
        terminal = "${config.home-xdg.terminal.bin}";
        keybindings = "<Ctrl><Alt>t";
        new-tab = false;
      };
    };

    # Theming
    gtk.iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };

    # Hyprland config
    wayland.windowManager.hyprland.extraConfig = ''

      # Autostart
      exec-once = ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
      exec-once = ${pkgs.xdg-desktop-portal-hyprland}/libexec/xdg-desktop-portal-hyprland
      exec-once = sleep 3 ; waybar
      exec-once = sleep 6 ; nextcloud
      exec-once = sleep 6 ; nm-applet
      exec-once = swaybg -i ${config.stylix.image}
      exec-once = swaync
      exec-once = emote
      exec-once = gsettings set org.gnome.nm-applet disable-disconnected-notifications "true"
      exec-once = gsettings set org.gnome.nm-applet disable-connected-notifications "true"
      ${if cfg.useSwayidle then "exec-once= swayidle timeout 800 '${swaylockCommand}' timeout 900 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' timeout 1700 'systemctl suspend'A" else ""}

      # Default for non specified monitors
      monitor=,preferred,auto,1

      ${cfg.additionalConfig}

      input {
        kb_layout=us,se
        kb_options=grp:win_space_toggle,caps:escape
      
        follow_mouse=1
        touchpad {
          scroll_factor=0.6
          natural_scroll=true
          disable_while_typing=false
          clickfinger_behavior=true
        }
      }

      master {
        new_status = master
        new_on_top = true
      }
      
      gestures {
        workspace_swipe=yes
        workspace_swipe_fingers=3
      }
      
      general {
        layout = master
        gaps_in=0
        gaps_out=0
        border_size=2
        col.active_border=0xfff5c2e7
        col.inactive_border=0xff45475a
        resize_on_border = true  # Can use mouse without super to resize
      }
      
      misc {
        # VRR (Variable Refresh Rate)
        vrr = 0  # 2: only fullscreen, 1: always, 0: off
        disable_splash_rendering = true  # Disables splash screen
        disable_hyprland_logo = true
        force_default_wallpaper = true  # Disables anime girls bihind your wallpaper
      }
      
      animations {
        enabled=0
      }

      # Keybindings
      $mod = SUPER

      bind=SUPER,Return,exec,${config.home-xdg.terminal.bin}
      bind=SUPER,Q,killactive,
      bind=SUPERSHIFTALT,E,exit,
      bind=SUPER,F,exec,${fileManagerCommand}
      bind=SUPER,V,togglefloating,
      bind=SUPER,P,pseudo
      # NOTE: use '-theme gruvbox' to specify theme
      bind=SUPER,D,exec,rofi -show combi -modes combi -combi-modes "window,drun,run"
      bind=SUPERSHIFT,D,exec,rofi -show run
      # Run a program without installing it
      bind=SUPERSHIFT,N,exec,rofi -dmenu | xargs -I % nix-shell -p % --run %
      # Emoji picker
      bind=SUPER,e,exec,emote
      
      # Focus on window
      #bind=SUPER,h,movefocus,l
      #bind=SUPER,l,movefocus,r
      #bind=SUPER,k,movefocus,u
      #bind=SUPER,j,movefocus,d

      # Master layout related
      bind=SUPER,j,layoutmsg,cyclenext,noloop
	  bind=SUPER,k,layoutmsg,cycleprev,noloop
      bind=SUPERSHIFT,j,layoutmsg,swapnext,noloop
      bind=SUPERSHIFT,k,layoutmsg,swapprev,noloop
      bind=SUPER,h,resizeactive,-30 0
      bind=SUPER,l,resizeactive,30 0
      bind=SUPER,comma,focusmonitor,l
      bind=SUPER,period,focusmonitor,r
      bind=SUPERSHIFT,comma,movewindow,mon:l
      bind=SUPERSHIFT,period,movewindow,mon:r
      
      #TODO: dont follow windows!

      # Move window
      #bind=SUPERSHIFT,h,movewindow,l
      #bind=SUPERSHIFT,l,movewindow,r
      #bind=SUPERSHIFT,k,movewindow,u
      #bind=SUPERSHIFT,j,movewindow,d
      
      # Resize window
      #bind=SUPERCONTROLALT,h,resizeactive,-30 0
      #bind=SUPERCONTROLALT,l,resizeactive,30 0
      #bind=SUPERCONTROLALT,k,resizeactive,0 -30
      #bind=SUPERCONTROLALT,j,resizeactive,0 30
      
      # Fullscreen and maximization
      bind=SUPER,M,fullscreen,1
      bind=SUPER,B,fullscreen,0
      
      # Move to workspace left or right
      #bind=SUPERCONTROL,l,workspace,+1
      #bind=SUPERCONTROL,h,workspace,-1
      
      # Mouse window controls
      bindm=SUPER,mouse:272,movewindow
      bindm=SUPER,mouse:273,resizewindow

      # FN-buttons (such as volume up)
      bind=,XF86MonBrightnessUp,exec,brightnessctl set 5%+
      bind=,XF86MonBrightnessDown,exec,brightnessctl set 5%-
      bind=,XF86AudioRaiseVolume,exec,${raiseVolumeCommand}
      bind=,XF86AudioLowerVolume,exec,${lowerVolumeCommand}
      bind=,XF86AudioMute,exec,${muteVolumeCommand}
      bind=,XF86AudioMicMute,exec,${muteMicCommand}
      bind=,XF86AudioPlay,exec,playerctl play-pause
      bind=,XF86AudioPrev,exec,playerctl previous
      bind=,XF86AudioNext,exec,playerctl next

      # Screen locking
      bind=SUPER,Escape,exec,${swaylockCommand}
      bind=SUPERSHIFT,Escape,exec,sleep 1 && hyprctl dispatch dpms off && ${swaylockCommand}
      bind=SUPERCONTROL,Escape,exec,sleep 1 && hyprctl dispatch dpms on
      bindl=,switch:Lid Switch,exec,${swaylockCommand}

      # Notifictations
      bind=SUPER,n,exec,swaync-client -t -sw

      # Color picker
      bind=SUPER,Z,exec,hyprpicker --format=rgb | wl-copy
      bind=SUPER,X,exec,hyprpicker --format=hex | wl-copy

      # Custom media keys
      bind=SUPERALT,l,exec,playerctl next
      bind=SUPERALT,h,exec,playerctl previous
      bind=SUPERALT,p,exec,playerctl play-pause
      bind=SUPERALT,k,exec,${raiseVolumeCommand}
      bind=SUPERALT,j,exec,${lowerVolumeCommand}

      # Screenshots
      bind=SUPER,S,exec,grim -g "$(slurp -d)" - | wl-copy

      # MISC
      bind=SUPERALTSHIFT,S,exec,systemctl poweroff
      bind=SUPERALTSHIFT,R,exec,systemctl reboot
      bind=SUPERALTSHIFT,N,exec,systemctl suspend

      # Workspaces
      # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
      ${builtins.concatStringsSep "\n" (builtins.genList (
          x: let
            ws = let
              c = (x + 1) / 10;
            in
              builtins.toString (x + 1 - (c * 10));
          in ''
            bind = $mod, ${ws}, workspace, ${toString (x + 1)}
            bind = $mod SHIFT, ${ws}, movetoworkspacesilent, ${toString (x + 1)}
          ''
        )
        10)}

      # ...
    '';
  };
}
