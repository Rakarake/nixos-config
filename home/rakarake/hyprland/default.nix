# Hyprland home-manager module
{ lib, config, pkgs, ... }:
with lib;                      
let
  cfg = config.home-hyprland;
  # pidof swaylock makes sure that we do not start multiple instances of swaylock
  swaylockCommand = "pidof swaylock || swaylock -k -C ~/.config/hypr/swaylock.conf -i ${config.stylix.image}";
  raiseVolumeCommand = "amixer set Master 5%+";
  lowerVolumeCommand = "amixer set Master 5%-";
  muteVolumeCommand = "amixer set Master toggle";
  muteMicCommand = "amixer set Capture toggle";
  fileManagerCommand = "nautilus";
in {

  imports = [
    ./waybar.nix
    ./rofi
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
    home-waybar.enable = true;
    home-rofi.enable = true;

    # Swaylock config file
    xdg.configFile."hypr/swaylock.conf".source = ./swaylock.conf;

    # Swaync theme file
    xdg.configFile."swaync/style.css".source = ./swaync.css;
    
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
        terminal = "${config.home-xdg.terminal}";
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
      exec-once = uwsm app -- ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
      exec-once = uwsm app -- ${pkgs.xdg-desktop-portal-hyprland}/libexec/xdg-desktop-portal-hyprland
      exec-once = uwsm app -- sleep 3 ; waybar
      exec-once = uwsm app -- sleep 6 ; nextcloud
      exec-once = uwsm app -- sleep 6 ; blueman-applet
      exec-once = uwsm app -- sleep 6 ; nm-applet
      exec-once = uwsm app -- swaybg -i ${config.stylix.image}
      exec-once = uwsm app -- swaync
      exec-once = uwsm app -- gsettings set org.gnome.nm-applet disable-disconnected-notifications "true"
      exec-once = uwsm app -- gsettings set org.gnome.nm-applet disable-connected-notifications "true"
      ${if cfg.useSwayidle then "exec-once= swayidle timeout 800 '${swaylockCommand}' timeout 900 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' timeout 1700 'systemctl suspend'A" else ""}

      # Default for non specified monitors
      monitor=,preferred,auto,1

      ${cfg.additionalConfig}

      input {
        kb_layout=us,se
        kb_options=grp:win_space_toggle,caps:escape
      
        follow_mouse=1
        #sensitivity=0.3
        touchpad {
          scroll_factor=0.6
          natural_scroll=true
          disable_while_typing=false
          clickfinger_behavior=true
        }
      }
      
      gestures {
        workspace_swipe=yes
        workspace_swipe_fingers=3
      }
      
      general {
        gaps_in=3
        gaps_out=5
        border_size=2
        col.active_border=0xfff5c2e7
        col.inactive_border=0xff45475a
      }
      
      misc {
        # VRR (Variable Refresh Rate)
        vrr = 2  # 2: only fullscreen, 1: always, 0: off
        disable_splash_rendering = true  # Disables splash screen
        disable_hyprland_logo = true
        force_default_wallpaper = true  # Disables anime girls bihind your wallpaper
      }

      
      decoration {
        #blur_ignore_opacity = 1
        #blur_new_optimizations = true
        #drop_shadow = true
        #shadow_range=true
        #shadow_render_power=20
        #col.shadow= 0x33000000
        #col.shadow_inactive=0x22000000
        rounding=16
        #active_opacity= 0.90
        #inactive_opacity= 0.90
        #blur=true
        #blur_size=2 # minimum 1
        #blur_passes=4 # minimum 1, more passes = more resource intensive.
        # Your blur "amount" is blur_size * blur_passes, but high blur_size (over around 5-ish) will produce artifacts.
        # if you want heavy blur, you need to up the blur_passes.
        # the more passes, the more you can up the blur_size without noticing artifacts.
      }
      
      animations {
        enabled=1
        #bezier=overshot,0.05,0.9,0.1,1.1 # Version 1
        #bezier=overshot,0.13,0.99,0.29,1.09 # Version 2
        #bezier= overshot,0,0.61,0.22,1.12 #Current active
        bezier= overshot,0,0.61,0.22,1.0 #Current active
        animation=windows,1,3.8,default,slide 
        animation=border,1,4,default
        animation=fade,1,4,default
        animation=workspaces,1,3.8,overshot
      }

      # Keybindings
      $mod = SUPER

      bind=SUPER,Return,exec,uwsm app -- ${config.home-xdg.terminal}
      bind=SUPER,Q,killactive,
      bind=SUPERSHIFTALT,E,exit,
      bind=SUPER,F,exec,uwsm app -- ${fileManagerCommand}
      bind=SUPER,V,togglefloating,
      bind=SUPER,P,pseudo
      # NOTE: use '-theme gruvbox' to specify theme
      bind=SUPER,D,exec,uwsm app -- rofi -show combi -modes combi -combi-modes "window,drun,run" -icon-theme "Papirus" -show-icons
      bind=SUPERSHIFT,D,exec,uwsm app -- rofi -show run
      # Run a program without installing it
      bind=SUPERSHIFT,N,exec,uwsm app -- rofi -dmenu | xargs -I % nix-shell -p % --run %
      # Emoji picker
      bind=SUPER,e,exec,uwsm app -- emote
      
      # Focus on window
      bind=SUPER,h,movefocus,l
      bind=SUPER,l,movefocus,r
      bind=SUPER,k,movefocus,u
      bind=SUPER,j,movefocus,d
      
      # Move window
      bind=SUPERSHIFT,h,movewindow,l
      bind=SUPERSHIFT,l,movewindow,r
      bind=SUPERSHIFT,k,movewindow,u
      bind=SUPERSHIFT,j,movewindow,d
      
      # Resize window
      bind=SUPERCONTROLALT,h,resizeactive,-30 0
      bind=SUPERCONTROLALT,l,resizeactive,30 0
      bind=SUPERCONTROLALT,k,resizeactive,0 -30
      bind=SUPERCONTROLALT,j,resizeactive,0 30
      
      # Fullscreen and maximization
      bind=SUPER,M,fullscreen,1
      bind=SUPER,B,fullscreen,0
      
      # Move to workspace left or right
      bind=SUPERCONTROL,l,workspace,+1
      bind=SUPERCONTROL,h,workspace,-1
      
      # Move widow and view left or right
      bind=SUPERCONTROLSHIFT,l,movetoworkspace,+1
      bind=SUPERCONTROLSHIFT,h,movetoworkspace,-1
      
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
      bind=SUPER,Escape,exec,uwsm app -- ${swaylockCommand}
      bind=SUPERSHIFT,Escape,exec,uwsm app -- sleep 1 && hyprctl dispatch dpms off && ${swaylockCommand}
      bind=SUPERCONTROL,Escape,exec,uwsm app -- sleep 1 && hyprctl dispatch dpms on
      bindl=,switch:Lid Switch,exec,uwsm app -- ${swaylockCommand}

      # Notifictations
      bind=SUPER,n,exec,uwsm app -- swaync-client -t -sw

      # Color picker
      bind=SUPER,Z,exec,uwsm app -- hyprpicker --format=rgb | wl-copy
      bind=SUPER,X,exec,uwsm app -- hyprpicker --format=hex | wl-copy

      # Custom media keys
      bind=SUPERALT,l,exec,playerctl next
      bind=SUPERALT,h,exec,playerctl previous
      bind=SUPERALT,p,exec,playerctl play-pause
      bind=SUPERALT,k,exec,${raiseVolumeCommand}
      bind=SUPERALT,j,exec,${lowerVolumeCommand}

      # Screenshots
      bind=SUPER,S,exec,uwsm app -- grim -g "$(slurp -d)" - | wl-copy

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
            bind = $mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
          ''
        )
        10)}

      # ...
    '';
  };
}
