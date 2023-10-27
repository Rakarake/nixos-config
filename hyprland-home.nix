{config, pkgs, ...}: {
  imports = [ ./home-gnome.nix ];

  # Eww config
  home.file.".config/eww/eww.yuck".source = ./eww/eww.yuck;
  home.file.".config/eww/eww.scss".source = ./eww/eww.scss;

  wayland.windowManager.hyprland.extraConfig = ''
    # Monitors
    # Default for non specified monitors
    monitor=,highrr,auto,1
    # Desktop
    monitor=HDMI-A-1,highrr,0x0,1
    monitor=DP-1,highrr,1920x0,1
    workspace = 1, monitor:HDMI-A-1
    workspace = 2, monitor:DP-1
    workspace = 3, monitor:DP-1
    workspace = 4, monitor:DP-1
    workspace = 5, monitor:DP-1
    workspace = 6, monitor:DP-1
    workspace = 7, monitor:DP-1
    workspace = 8, monitor:DP-1
    workspace = 9, monitor:DP-1
    workspace = 0, monitor:DP-1

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
    bind=SUPER,Q,killactive,
    bind=SUPERSHIFT,E,exit,
    bind=SUPER,F,exec,thunar
    bind=SUPER,V,togglefloating,
    # NOTE: use '-theme gruvbox' to specify theme
    bind=SUPER,D,exec,rofi -show combi -modes combi -combi-modes "window,drun,run" -icon-theme "Papirus" -show-icons
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
}
