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
  flake.homeModules.hyprland = { config, pkgs, ... }: {
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
      settings.main.term = "xterm-256color";
      enable = true;
      server.enable = true;
    };

    programs.swaylock.enable = true;

    programs.noctalia = {
      enable = true;

      settings = { # This may also be a string or path to a .toml file.
        hooks = {
          battery_discharging = "noctalia msg power-set balanced";
          battery_charging = "noctalia msg power-set performance";
          battery_plugged = "noctalia msg power-set performance";
        };
        shell.polkit_agent = true;
        avatar_path = "${dotfiles}/modules/rakarake/sitting-neco-arc.png";
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
            display = "name";
            style = "minimal";
          };
          date = {
            format = "{:%F %A vecka %V}";
          };
          tray = {
            drawer = true;
          };
        };

        wallpaper.enabled = false;

        bar.order = [ "main" ];
        bar.main = {
          margin_edge        = 0;
          padding = 0;
          center = [];
          end = [
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
          start = [ "workspaces" ];
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
