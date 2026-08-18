{ inputs, dotfiles, ... }: {
  flake.nixosModules.hyprland = { lib, system, config, pkgs, ... }: {
    # Gnome keyring
    services.gnome.gnome-keyring.enable = true;  # Keyring, dbus service to remember passwords
    hardware.bluetooth.enable = true;
    services.power-profiles-daemon.enable = true;
    # Batter stats I think
    services.upower.enable = true;
    environment.systemPackages = with pkgs; [
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      swaylock
    ];
    security.pam.services.swaylock = {};
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };
  };
  flake.homeModules.hyprland = { config, pkgs, lib, ... }: {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    home.packages = with pkgs; [
      #kitty
      pcmanfm
      imv
      
      grim # Screenshot utility
      wl-screenrec # Screen recorder
      slurp # Screen "area" picker utility
      pamixer # Used for panel sound control
      alsa-utils # keyboard volume control
      pulseaudio # for pactl command
      playerctl # MPRIS global player controller
      swayidle # Idle inhibitor, knows when computer is ueseless
      brightnessctl # Laptop brighness controls
      emote # emoji picker
      hyprpicker # Color picker
      inputs.glonkers.defaultPackage.${system}
      lswt  # Gets app-id:s and titles of windows
      tesseract
      brightnessctl 
      swaybg
      swayidle
    ];

    # Terminal
    programs.foot = {
      settings = {
        main.term = "xterm-256color";
        colors-dark.alpha = lib.mkForce 0.82;
        colors-light.alpha = lib.mkForce 0.82;
      };
      enable = true;
      server.enable = true;
    };

    programs.swaylock.enable = true;

    programs.yazi = {
      enable = true;
      enableBashIntegration = true;
      shellWrapperName = "y";
      plugins = {
        clipboard ={
          package = pkgs.yaziPlugins.clipboard;
        };
      };
      keymap = {
        mgr.prepend_keymap = [
          {
            on   = "!";
            for  = "unix";
            run  = ''shell "$SHELL" --block'';
            desc = "Open $SHELL here";
          }
          {
            on   = "Q";
            run  = "quit --no-cwd-file";
            desc = "Guaranteed quit";
          }
          {
            # Drag and drop window popup
            on  = "<C-n>";
            run = "shell -- blobdrop %h";
          }
          {
            # Copy yanked files to the system clipboard
            on  = "y";
            run = [ "yank" ''plugin clipboard -- --action=copy'' ];
            desc = "Yank selected files (copy)";
          }
          {
            # Keep behaviour consistent with cut
            on  = "x";
            run = [ "yank --cut" ''plugin clipboard -- --action=copy'' ];
            desc = "Yank selected files (cut)";
          }
          {
            # Paste files from the system clipboard into the current directory
            on  = "<C-p>";
            run = [ ''plugin clipboard -- --action=paste'' ];
            desc = "Paste yanked system clipboard files";
          }
          {
            # Paste an image
            on  = "<C-S-p>";
            run = [ ''shell -- wl-paste -t image/png > ./pasted_image.png''];
            desc = "Paste image";
          }
        ];
      };
    };

    programs.noctalia = {
      enable = true;

      settings = { # This may also be a string or path to a .toml file.
        hooks = {
          battery_discharging = "noctalia msg power-set balanced";
          battery_charging = "noctalia msg power-set performance";
          battery_plugged = "noctalia msg power-set performance";
        };

        shell.polkit_agent = true;
        shell.avatar_path = "${dotfiles}/modules/rakarake/sitting-neco-arc.png";

        osd.kinds = {
          bluetooth = false;
          brightness = false;
          caffeine = false;
          dnd = false;
          keyboard_layout = false;
          lock_keys = false;
          media = false;
          nightlight = false;
          power_profile = false;
          privacy = false;
          volume = false;
          wifi = false;
        };

        widget = {
          workspaces = {
            label_source = "name";
            style = "minimal";
            change_color_on_hover = false;
            empty_color = "on_surface";
            focused_color = "secondary";
            max_label_chars = 4;
            occupied_color = "on_surface";
            urgent_color = "on_surface";
          };
          date = {
            format = "{:%F %A vecka %V}";
          };
          tray = {
            drawer = true;
          };
          active_window = {
            display = "text_only";
          };
        };

        wallpaper.enabled = false;

        bar.order = [ "main" ];
        bar.main = {
          margin_edge        = 0;
          padding = 0;
          center = [];
          end = [
            "media"
            "ram"
            "cpu"
            "temp"
            "tray"
            "notifications"
            "clipboard"
            "network"
            "bluetooth"
            "volume"
            "brightness"
            "battery"
            "session"
            "date"
            "clock"
          ];
          margin_ends = 0;
          radius = 0;
          shadow = false;
          start = [ "workspaces" "active_window" ];
          thickness = 22;
        };
      };
    };
    programs.rofi.enable = true;
    xdg.configFile."hypr/extra.lua" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/modules/hyprland/extra.lua";
      force = true;
      recursive = true;
    };
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;
      configType = "lua";
      extraConfig = let
        wallpaper = config.stylix.image;
      in ''
        local lock_command = "swaylock -f -i " .. "${wallpaper}"
        -- Load the extra.lua file here
        local mod require("extra") ({
          wallpaper = "${wallpaper}",
          lock_command = lock_command,
        })
      '';
    };
  };
}
