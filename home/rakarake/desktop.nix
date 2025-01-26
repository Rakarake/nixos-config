# My cozy home UwU
# Some config must be anbled manually, such as the gnome-config.
# This is done so that e.g. gnome and kde settings don't clash.
{ lib, config, pkgs, outputs, ... }:
let
  cfg = config.home-desktop;
  # Custom packages defined in the toplevel flake
  cpkgs = outputs.packages.${pkgs.system};
in {
  imports = [
    ./xdg.nix
    ./vscode.nix
    ./common.nix
    ./mpv
  ];

  options.home-desktop = {
    enable = lib.mkEnableOption "Cozy home desktop (or laptop (or anything else)) config";
  };

  config = lib.mkIf cfg.enable {
    home-common.enable = true;
    # Default applications
    home-xdg = {
      enable = true;
      terminal = { package = pkgs.foot; bin = "foot"; desktop = "foot.desktop"; };
      file-manager = { package = pkgs.nautilus; bin = "nautilus"; desktop = "nautilus.desktop"; };
    };

    # Neovim config
    home-neovim.enable = true;

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
      matchBlocks."ssh.rakarake.xyz".proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname ssh.rakarake.xyz";
    };

    # Virt-manager error free
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };

    # Mangohud
    programs.mangohud = {
      enable = true;
      settings = {
        toggle_hud =          "Shift_L+F12";
        toggle_preset =       "Shift_L+F10";
        toggle_hud_position = "Shift_L+F11";
        toggle_fps_limit =    "Shift_L+F1";
        toggle_logging=       "Shift_L+F2";
        reload_cfg =          "Shift_L+F4";
        upload_log =          "Shift_L+F3";

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
      vesktop
      helvum
      nicotine-plus
      #ardour
      r2modman
      #pkgs.osu-lazer
      superTuxKart
      gamescope
      audacity
      mullvad-vpn
      fragments
      blender
      logseq
      inkscape
      cpkgs.simple-shell-utils
      parabolic
      emote
      moonlight-qt
      gcolor3
      ascii-draw
      newsflash
      monero-gui
      handbrake
      alpaca
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

      # Emulators
      fceux
      dolphin-emu
      torzu
      (pkgs.retroarch.withCores (cores: with cores; [
        mesen
        bsnes
        citra
        parallel-n64
      ]))

      # Minecraft time
      prismlauncher
      glfw-wayland-minecraft
      jdk21

      # Hacking
      skim
      cargo-mommy
    ];

    ## Enable syncthing service in the background
    #services.syncthing.enable = true;

    # Moment
    nixpkgs.config.permittedInsecurePackages = [
      "electron-27.3.11"
    ];

    xdg.desktopEntries =
    let
      # A desktop entry that launches an electron app with ozone turned on
      electronWaylandApp = name : {
        name = "${name} wayland";
        exec = "${name} --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-webrtc-pipewire-capturer";
        icon = name;
      };
      qtWaylandApp = name : {
        name = "${name} wayland";
        exec = ''${name} -platform "wayland;xcb"'';
        icon = name;
      };
      # Takes a list of executable names and makes wayland desktop entries for them
      makeElectronWaylandApps = appNames : (lib.listToAttrs (map (name : { name = "${name}Wayland"; value = electronWaylandApp name; }) appNames));
      makeQTWaylandApps = appNames : (lib.listToAttrs (map (name : { name = "${name}Wayland"; value = qtWaylandApp name; }) appNames));
    in {
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
    } // (makeElectronWaylandApps [
      "logseq"
      "code"
      "codium"
      "vesktop"
    ])
    // (makeQTWaylandApps [
      "monero-wallet-gui"
    ])
    ;
  };
}
