{ inputs, dotfiles, ... }: {
  flake.nixosModules.hyprland = { lib, system, config, pkgs, ... }: {
    # Gnome keyring
    services.gnome.gnome-keyring.enable = true;  # Keyring, dbus service to remember passwords
    hardware.bluetooth.enable = true;
    services.power-profiles-daemon.enable = true;
    # Batter stats I think
    services.upower.enable = true;
    environment.systemPackages = with pkgs; [
      #inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      swaylock
    ];
    security.pam.services.swaylock = {};
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };
  };
  flake.homeModules.hyprland = { config, pkgs, ... }: {
    imports = [
      #inputs.noctalia.homeModules.default
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
      rofi-network-manager
    ];

    # Terminal
    programs.foot = {
      settings.main.term = "xterm-256color";
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

    services.fnott = {
      enable = true;
      settings = {
        main = {
          max-timeout = 6;
        };
      };
    };

    programs.waybar = {
      enable = true;
      style = ''
        #workspaces {
          background: transparent;
          margin: 0;
          padding: 0;
        }

        #workspaces button {
          padding: 0 8px;
          margin: 0;
          background: transparent;
          border: none;
          border-radius: 0;
          box-shadow: none;
        }

        #workspaces button.active {
          border-bottom: 2px solid #ffffff;
        }

        #workspaces button:hover {
          background: transparent;
          box-shadow: none;
        }

        #window, #clock {
          padding: 0 10px;
        }
      '';
      settings.mainBar = {
        layer = "bottom";
        position = "top";
        height = 10;
        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-right = [
          "mpd"
          "temperature"
          "tray"
          "clock"
        ];
        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = false;
          active-only = false;
          show-special = false;
        };
        "hyprland/window" = {
          format = "{}";
          separate-outputs = true;
        };
        "clock" = {
          format = "{:%Y-%m-%d %H:%M}";
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
