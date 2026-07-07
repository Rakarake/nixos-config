{ inputs, dotfiles, ... }: {
  flake.nixosModules.hyprland = { lib, system, config, pkgs, ... }: {
    hardware.bluetooth.enable = true;
    environment.systemPackages = [
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
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
      kitty
      pcmanfm-qt
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
    ];

    # Terminal
    programs.foot = {
      settings.main.term = "xterm-256color";
      enable = true;
      server.enable = true;
    };

    programs.noctalia = {
      enable = true;

      settings = { # This may also be a string or path to a .toml file.
        #theme = {
        #  mode = "dark";
        #  source = "builtin";
        #  builtin = "Catppuccin";
        #};

        #wallpaper = {
        #  enabled = true;
        #  default.path = ../rakarake/wallpaper.png;
        #};
        bar.order = [ "main" ];
        bar.main = {
          margin_edge        = 0;
          padding = 0;
          center = [];
          end = [
              "media"
              "tray"
              "notifications"
              "clipboard"
              "network"
              "bluetooth"
              "volume"
              "brightness"
              "battery"
              "control-center"
              "session"
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
      extraConfig = ''
        -- Load the extra.lua file here
        require("extra")
      '';
    };
  };
}
