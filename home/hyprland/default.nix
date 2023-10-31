# Hyprland home-manager module
{ lib, config, pkgs, ... }:
with lib;                      
let
  cfg = config.home-hyprland;
in {

  imports = [
    ./waybar.nix
    ./rofi.nix
  ];

  options.home-hyprland = {
    enable = mkEnableOption "Custom Hyprland system configuration";
  };
  config = mkIf cfg.enable {
    # Enable Hyprland
    wayland.windowManager.hyprland.enable = true;
    home-waybar.enable = true;
    home-rofi.enable = true;

    # Packages needed by the Hyprland configuration
    home.packages = (with pkgs; [
      grim                         # Screenshot utility
      slurp                        # Screen "area" picker utility
      swaybg                       # Anime wallpapers
      pipewire                     # Screensharing
      xdg-desktop-portal-hyprland  # Screensharing
      polkit_gnome                 # Polkit / gparted popup prompt provider
      xfce.thunar
      pamixer    # Used for panel / 
      alsa-utils # keyboard volume control
      playerctl  # MPRIS global player controller
      swaylock
    ]);
    home.sessionVariables = {
      # NixOS specific option for enabling wayland in Electron apps
      NIXOS_OZONE_WL = "1";
      # Make QT use wayland
      QT_QPA_PLATFORM = "wayland";
    };

    # Nice popups when changing volume etc
    services.swayosd.enable = true;

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
      #size = 32;
    };

    wayland.windowManager.hyprland.extraConfig = ''

      # Autostart
      exec-once = ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
      exec-once = nextcloud
      exec = waybar
      exec = swaybg -i ~/Pictures/Wallpapers/wallpaper
      exec = dunst

      # Monitors
      # Default for non specified monitors
      monitor=,highrr,auto,1
      # Desktop
      monitor=HDMI-A-1,highrr,-1920x0,1
      monitor=DP-1,highrr,0x0,1

      workspace=HDMI-A-1,1
      workspace=DP-1,2
      workspace=DP-1,3
      workspace=DP-1,4
      workspace=DP-1,5
      workspace=DP-1,6
      workspace=DP-1,7
      workspace=DP-1,8
      workspace=DP-1,9

      input {
          kb_layout=us,se
          kb_options=grp:win_space_toggle,caps:escape
      
          follow_mouse=1
      	sensitivity=0.3
      	touchpad {
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
          border_size=0
          col.active_border=0xfff5c2e7
          col.inactive_border=0xff45475a
          # Whether to apply the sensitivity to raw input
          # (e.g. used by games where you aim using your mouse)
          apply_sens_to_raw=1 
      }
      
      misc {
      	# VRR (Variable Refresh Rate)
      	vrr = 2  # 2: only fullscreen, 1: always, 0: off
      }
      
      decoration {
          #blur_ignore_opacity = 1
          #blur_new_optimizations = true
          drop_shadow = true
          shadow_range=true
          shadow_render_power=20
          col.shadow= 0x33000000
          col.shadow_inactive=0x22000000
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

      bind=SUPER,Return,exec,kitty
      bind=SUPER,Escape,exec,swaylock -k -i ~/Pictures/Wallpapers/wallpaper
      bind=SUPER,Q,killactive,
      bind=SUPERSHIFT,E,exit,
      bind=SUPER,F,exec,thunar
      bind=SUPER,V,togglefloating,
      # NOTE: use '-theme gruvbox' to specify theme
      bind=SUPER,D,exec,rofi -show combi -modes combi -combi-modes "window,drun,run" -icon-theme "Papirus" -show-icons
      bind=SUPERSHIFT,D,exec,rofi -show run
      bind=SUPER,P,pseudo
      
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
      bind=SUPERALT,h,resizeactive,-30 0
      bind=SUPERALT,l,resizeactive,30 0
      bind=SUPERALT,k,resizeactive,0 -30
      bind=SUPERALT,j,resizeactive,0 30
      
      bind=SUPER,M,fullscreen
      
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
      bind=,XF86MonBrightnessUp,exec,brightnessctl set 30+
      bind=,XF86MonBrightnessDown,exec,brightnessctl set 30-
      bind=,XF86AudioRaiseVolume,exec,amixer set Master 5%+
      bind=,XF86AudioLowerVolume,exec,amixer set Master 5%-
      bind=,XF86AudioMute,exec,amixer set Master toggle
      bind=,XF86AudioMicMute, exec, amixer set Capture toggle
      bind=,XF86AudioPlay,exec,playerctl play-pause
      bind=,XF86AudioPrev,exec,playerctl previous
      bind=,XF86AudioNext,exec,playerctl next

      # Custom media keys
      bind=SUPERALT,l,exec,playerctl next
      bind=SUPERALT,h,exec,playerctl previous
      bind=SUPERALT,p,exec,playerctl play-pause
      bind=SUPERALT,k,exec,amixer set Master 5%+
      bind=SUPERALT,j,exec,amixer set Master 5%-
      
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
    # Notification daemon
    services.dunst = {
      enable = true;
      settings = {
        global = {
          frame_color = "#f4b8e495";
          separator_color = "#f4b8e4";
          width = 220;
          height = 280;
          offset = "0x15";
          font = "Lexend 12";
          corner_radius = 10;
          origin = "top-center";
          notification_limit = 3;
          idle_threshold = 120;
          ignore_newline = "no";
          mouse_left_click = "close_current";
          mouse_right_click = "close_all";
          sticky_history = "yes";
          history_length = 20;
          show_age_threshold = 60;
          ellipsize = "middle";
          padding = 10;
          always_run_script = true;
          frame_width = 2;
          transparency = 10;
          progress_bar = true;
          progress_bar_frame_width = 0;
          highlight = "#f4b8e4";
        };
        fullscreen_delay_everything.fullscreen = "delay";
        urgency_low = {
          background = "#1e1e2e83";
          foreground = "#c6d0f5";
          timeout = 5;
        };
        urgency_normal = {
          background = "#1e1e2e83";
          foreground = "#c6d0f5";
          timeout = 6;
        };
        urgency_critical = {
          background = "#1e1e2e83";
          foreground = "#c6d0f5";
          frame_color = "#ea999c80";
          timeout = 0;
        };
      };
    };
  };
}
