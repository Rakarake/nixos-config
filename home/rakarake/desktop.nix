# My cozy home UwU
# Some config must be anbled manually, such as the gnome-config.
# This is done so that e.g. gnome and kde settings don't clash.
{
  lib,
  config,
  pkgs,
  outputs,
  ...
}:
let
  cfg = config.home-desktop;
in
{
  imports = [
    ./xdg.nix
    ./vscode
    ./mpv
  ];

  options.home-desktop = {
    enable = lib.mkEnableOption "Cozy home desktop (or laptop (or anything else)) config";
  };

  config = lib.mkIf cfg.enable {
    # Default applications
    home-xdg.enable = true;

    # Neovim config
    home-neovim.enable = true;

    # Browser
    programs.librewolf = {
      enable = true;
      settings = {
        # Vertical tabs
        "sidebar.verticalTabs" = true;
        # Restore previous session on startup
        "browser.startup.page" = 3;
        # Enable webgl
        "webgl.disabled" = false;
        # Don't clear cookies and history
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.cookies" = false;
        "privacy.sanitize.sanitizeOnShutdown" = false;
        # Force big scrollbars
        "widget.non-native-theme.scrollbar.size.override" = 25;
        # Middle mouse button scrolling
        "general.autoScroll" = true;
      };
      profiles = {
        default = {
          name = "default";
          isDefault = true;
          extensions.force = true;
        };
      };
    };

    # Kitty config
    programs.kitty = {
      enable = true;
      keybindings = {
        # Amazing new tab
        "ctrl+shift+t" = "new_tab_with_cwd !neighbor";
      };
      settings = {
        linux_display_server = "wayland";
        #hide_window_decorations = true;

        # Window Layoutot
        remember_window_size = true;
        initial_window_width = 740;
        initial_window_height = 460;
        #resize_draw_strategy = blank;

        # Scrolling
        touch_scroll_multiplier = "5.0";

        # Tab bar
        tab_bar_style = "powerline";

        # Audio bell
        enable_audio_bell = false;
        window_alert_on_bell = false;

        confirm_os_window_close = 0;

        wayland_titlebar_color = "background";
      };
    };

    ## Terminal
    programs.foot = {
      settings.main.term = "xterm-256color";
      enable = true;
      server.enable = true;
    };

    # Ghci prompt
    home.file.".ghci".source = ./.ghci;

    # SSH
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      #matchBlocks."ssh.rakarake.xyz".proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname ssh.rakarake.xyz";
    };

    # Pdf viewer
    programs.sioyek = {
      enable = true;
    };

    # Virt-manager error free
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
    };

    # Mangohud
    programs.mangohud = {
      enable = true;
      settings = {
        toggle_hud = "Shift_L+F12";
        toggle_preset = "Shift_L+F10";
        toggle_hud_position = "Shift_L+F11";
        toggle_fps_limit = "Shift_L+F1";
        toggle_logging = "Shift_L+F2";
        reload_cfg = "Shift_L+F4";
        upload_log = "Shift_L+F3";

        no_display = true;
      };
    };

    # User specific packages
    home.packages = with pkgs; [
      steam-run
      appimage-run
      steamtinkerlaunch
      obs-studio
      protonup-qt
      baobab
      helvum
      nicotine-plus
      #ardour
      r2modman
      #pkgs.osu-lazer
      superTuxKart
      gamescope
      audacity
      fragments
      #varia
      blender-hip # blender compiled to detect hip/rocm support
      #logseq
      inkscape
      parabolic
      emote
      moonlight-qt
      gcolor3
      ascii-draw
      newsflash
      monero-gui
      handbrake
      tor-browser
      supersonic
      video-trimmer
      pipeline
      easyeffects
      evince
      resources
      file-roller
      rclone
      gnome-calculator
      gnome-clocks
      gnupg1
      okteta
      krita
      gimp3
      obsidian
      hieroglyphic
      strawberry

      # Emulators
      fceux
      dolphin-emu
      #torzu
      ryubing
      (pkgs.retroarch.withCores (
        cores: with cores; [
          mesen
          bsnes
          citra
          parallel-n64
        ]
      ))

      # Minecraft time
      prismlauncher
      glfw3-minecraft
      jdk21

      # Hacking
      skim
      cargo-mommy
    ];

    programs.vesktop.enable = true;
    programs.element-desktop = {
      enable = true;
      settings = {
        default_server_config = {
          "m.homeserver" = {
              base_url = "https://chat.mdf.farm";
              server_name = "chat.mdf.farm";
          };
          "m.identity_server" = {
              base_url = "https://vector.im";
          };
        };
      };
    };


    ## Enable syncthing service in the background
    #services.syncthing.enable = true;

    # Moment
    nixpkgs.config.permittedInsecurePackages = [
      "olm-3.2.16" # For nheko matrix client
      "fluffychat-linux-1.26.1" # Fluffychat
      "electron-27.3.11"
      "dotnet-runtime-7.0.20" # Vintage story
      "mbedtls-2.28.10" # I have no idea
    ];

    xdg.desktopEntries =
      let
        # A desktop entry that launches an electron app with ozone turned on
        electronWaylandApp = name: {
          name = "${name} wayland";
          exec = "${name} --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-webrtc-pipewire-capturer";
          icon = name;
        };
        qtWaylandApp = name: {
          name = "${name} wayland";
          exec = ''${name} -platform "wayland;xcb"'';
          icon = name;
        };
        # Takes a list of executable names and makes wayland desktop entries for them
        makeElectronWaylandApps =
          appNames:
          (lib.listToAttrs (
            map (name: {
              name = "${name}Wayland";
              value = electronWaylandApp name;
            }) appNames
          ));
        makeQTWaylandApps =
          appNames:
          (lib.listToAttrs (
            map (name: {
              name = "${name}Wayland";
              value = qtWaylandApp name;
            }) appNames
          ));
      in
      {
        godotSingleWindow = {
          name = "Godot 4 Single Window";
          genericName = "Godot 4 Single Window";
          exec = "godot4 --single-window";
        };
        steamGamescope = {
          name = "Steam Gamescope";
          genericName = "Steam";
          # -e enables steam integration, -f fullscreens the window by default
          exec = "gamescope -W 1920 -H 1080 --adaptive-sync -f -r 600 -e -- steam";
        };
      }
      // (makeElectronWaylandApps [
        "code"
        "codium"
        "vesktop"
      ])
      // (makeQTWaylandApps [
        "monero-wallet-gui"
      ]);
  };
}
