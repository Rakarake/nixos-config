{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.home-river;
  swaylockCommand = "${pkgs.swaylock}/bin/swaylock -f";
  raiseVolumeCommand = "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+";
  lowerVolumeCommand = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
  muteVolumeCommand = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
  muteMicCommand = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
  playerNext = "playerctl next";
  playerPrev = "playerctl previous";
  playerPause = "playerctl play-pause";
  projectSelector = ''
  '';
  swayidleCommand = ''
    \
        ${pkgs.swayidle}/bin/swayidle -w \
        	timeout 800  '${swaylockCommand}' \
          timeout 1700 '${pkgs.systemd}/bin/systemctl suspend' \
        	before-sleep '${swaylockCommand}'
  '';
  # Adding pull request that adds bar status to all monitors wiht the -sao flag
  run-sandbar = pkgs.writeShellScriptBin "run-sandbar" ''
    # Status bar
    FIFO="$XDG_RUNTIME_DIR/sandbar"
    [ -e "$FIFO" ] && rm -f "$FIFO"
    mkfifo "$FIFO"

    while cat "$FIFO"; do :; done | sandbar ${
      if config.stylix.enable == true then
        (
          " -font \"${config.stylix.fonts.sansSerif.name} ${toString config.stylix.fonts.sizes.desktop}\""
          + " -inactive-bg-color \"#"
          + config.lib.stylix.colors.base01
          + "\""
          + " -inactive-fg-color \"#"
          + config.lib.stylix.colors.base05
          + "\""
          + " -active-bg-color   \"#"
          + config.lib.stylix.colors.base02
          + "\""
          + " -active-fg-color   \"#"
          + config.lib.stylix.colors.base05
          + "\""
          + " -urgent-fg-color   \"#"
          + config.lib.stylix.colors.base04
          + "\""
          + " -urgent-bg-color   \"#"
          + config.lib.stylix.colors.base09
          + "\""
          + " -title-fg-color    \"#"
          + config.lib.stylix.colors.base05
          + "\""
          + " -title-bg-color    \"#"
          + config.lib.stylix.colors.base01
          + "\""
        )
      else
        ""
    }
  '';
  monitor-setup = pkgs.writeShellScriptBin "monitor-setup" cfg.monitor-setup;
in
{
  imports = [
    ./waybar.nix
  ];
  options.home-river = {
    enable = mkEnableOption "river config";
    # Extra config at the end of the config file
    extraConfig = mkOption {
      type = types.str;
      default = "";
    };
    # Extra config in the beginning of the config file
    extraConfigTop = mkOption {
      type = types.str;
      default = "";
    };
    useSwayidle = mkOption {
      type = types.bool;
      default = true;
    };
    # wl-randr commands
    monitor-setup = mkOption {
      type = types.str;
      default = "";
    };
  };
  config = mkIf cfg.enable {
    home-rofi.enable = true;
    home.packages = with pkgs; [
      grim # Screenshot utility
      wl-screenrec # Screen recorder
      slurp # Screen "area" picker utility
      swaybg # Anime wallpapers
      pamixer # Used for panel sound control
      alsa-utils # keyboard volume control
      playerctl # MPRIS global player controller
      swayidle # Idle inhibitor, knows when computer is ueseless
      brightnessctl # Laptop brighness controls
      nautilus
      #networkmanagerapplet         # Log in to your wifi with this cool utility
      emote # emoji picker
      hyprpicker # Color picker
      # Clipboard stuff
      cliphist
      wl-clip-persist
      rofi-network-manager # Simple NetworkManager interface
      sandbar
      acpi
      # Custom sandbar command
      run-sandbar
      monitor-setup
    ];

    # Xremap
    services.xremap = {
      enable = true;
      config.modmap = [
        {
          name = "Global";
          remap = {
            "CapsLock" = "Esc";
          };
        }
      ];
    };

    # Screenlocker
    programs.swaylock.enable = true;

    # Swaync
    services.swaync.enable = true;

    ## Swayidle
    #services.swayidle = {
    #  enable = cfg.useSwayidle;
    #  events = [
    #    { event = "before-sleep"; command = "${swaylockCommand}"; }
    #  ];
    #  timeouts = [
    #    { timeout = 800; command = "${swaylockCommand}"; }
    #    { timeout = 1700; command = "${pkgs.systemd}/bin/systemctl suspend"; }
    #  ];
    #};

    # Dconf settings
    dconf.settings = {
      # Locale
      "system/locale" = {
        region = "sv_SE.UTF-8";
      };
    };

    # Polkit, allowing programs to achieve higher privilages
    services.polkit-gnome.enable = true;

    wayland.windowManager.river = {
      enable = true;
      systemd.enable = true;
      package = pkgs.river-classic;
      extraConfig = ''
        ${cfg.extraConfigTop}

        riverctl map normal Super Y spawn "$BROWSER"

        monitor-setup &
        (while true; do run-sandbar; sleep 2; done) &

        # Run the update script (located in flake-root/scripts)
        (while true; do update-sandbar; sleep 2; done) &

        # Required to get screensharing to work https://wiki.archlinux.org/title/River#Troubleshooting
        # Apperently the home manager module is just not maintained ☹️
        systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
        dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=river
        systemctl --user restart xdg-desktop-portal

        # Swayidle
        ${if cfg.useSwayidle then "(while true; do (${swayidleCommand}); sleep 1; done) &" else ""}

        # Emoji picker
        emote &  # Run in background
        riverctl map normal Super E spawn emote

        # Color picker
        riverctl map normal Super A spawn 'hyprpicker --format=rgb | wl-copy'
        riverctl map normal Super X spawn 'hyprpicker --format=hex | wl-copy'

        # NetworkManager applet
        #gsettings set org.gnome.nm-applet disable-disconnected-notifications "true"
        #gsettings set org.gnome.nm-applet disable-connected-notifications "true"
        #nm-applet &

        # Wallpaper
        swaybg -i ${config.home-xdg.wallpaper} &

        # Open notifications
        riverctl map normal Super N spawn "swaync-client -t -sw"

        # Lock screen
        riverctl map normal Super Escape spawn "${swaylockCommand}"

        # Internet please
        riverctl map normal Super M spawn 'rofi-network-manager'

        # Screenshot
        riverctl map normal Super S spawn 'grim -g "$(slurp -d)" - | wl-copy'

        # Screenshots of default monitor
        riverctl map normal Super R       spawn grim - | wl-copy
        riverctl map normal Super+Shift R spawn grim

        # Stop screen recording
        riverctl map normal Super+Alt B spawn "pkill --signal SIGINT wl-screenrec"

        # Persistent clipboard
        wl-clip-persist --clipboard regular &

        # Clipboard manager
        wl-paste --type text --watch cliphist store &

        # Access clipboard manager
        riverctl map normal Super C spawn "cliphist list | rofi -dmenu | cliphist decode | wl-copy"

        # Clear clipboard manager
        riverctl map normal Super+Shift C spawn "cliphist wipe"

        # Open file in clipboard
        riverctl map normal Super+Shift O spawn open-file-in-clipboard

        # Other stuff
        riverctl rule-add ssd                    # Serverside decorations only
        riverctl set-cursor-warp on-focus-change # Cursor follows focus
        riverctl focus-follows-cursor always     # Focus follows cursor
        riverctl hide-cursor timeout 10000

        # Keyboard options
        riverctl keyboard-layout -variant "us" -options "grp:win_space_toggle,caps:escape" "se"

        # Touchpad naturall scrolling
        # NOTE: the device using glob might look different on 
        # with other hardware. This is what I got from my thinkpad.
        riverctl input "*TouchPad*" natural-scroll enabled

        # Touchapd scroll factor
        riverctl input "*TouchPad*" scroll-factor 0.6

        # Clicking with the touchpad with n number of fingers
        riverctl input "*TouchPad*" click-method clickfinger
        # Touchpad tap
        riverctl input "*TouchPad*" tap enabled
        riverctl input "*TouchPad*" tap-button-map left-right-middle

        riverctl map normal Super Return spawn "${config.home-xdg.terminal.bin}"
        riverctl map normal Super F spawn "${config.home-xdg.file-manager.bin}"
        riverctl map normal Super Q close
        riverctl map normal Super+Shift+Alt E exit
        riverctl map normal Super D spawn 'rofi -show combi -modes combi -combi-modes "window,drun,run"'
        riverctl map normal Super+Shift D spawn "rofi -show run"
        riverctl map normal Super P spawn '
          dir=$(ls ~/Projects/ | rofi -dmenu) && foot sh -c "cd ~/Projects/$dir && tmux attach -t $dir || tmux new -s $dir"
        '
        # Super+J and Super+K to focus the next/previous view in the layout stack
        riverctl map normal Super J focus-view next
        riverctl map normal Super K focus-view previous

        # Super+Shift+J and Super+Shift+K to swap the focused view with the next/previous
        # view in the layout stack
        riverctl map normal Super+Shift J swap next
        riverctl map normal Super+Shift K swap previous

        # Super+Period and Super+Comma to focus the next/previous output
        riverctl map normal Super Period focus-output next
        riverctl map normal Super Comma focus-output previous

        # Super+Shift+{Period,Comma} to send the focused view to the next/previous output
        riverctl map normal Super+Shift Period send-to-output next
        riverctl map normal Super+Shift Comma send-to-output previous

        # Super+Return to bump the focused view to the top of the layout stack
        riverctl map normal Super Z zoom

        # Super+H and Super+L to decrease/increase the main ratio of rivertile(1)
        riverctl map normal Super H send-layout-cmd rivertile "main-ratio -0.05"
        riverctl map normal Super L send-layout-cmd rivertile "main-ratio +0.05"

        # Super+Shift+H and Super+Shift+L to increment/decrement the main count of rivertile(1)
        riverctl map normal Super+Shift H send-layout-cmd rivertile "main-count +1"
        riverctl map normal Super+Shift L send-layout-cmd rivertile "main-count -1"

        # Super+Alt+{H,J,K,L} to move views
        riverctl map normal Super+Alt H move left 100
        riverctl map normal Super+Alt J move down 100
        riverctl map normal Super+Alt K move up 100
        riverctl map normal Super+Alt L move right 100

        # Super+Alt+Control+{H,J,K,L} to snap views to screen edges
        riverctl map normal Super+Alt+Control H snap left
        riverctl map normal Super+Alt+Control J snap down
        riverctl map normal Super+Alt+Control K snap up
        riverctl map normal Super+Alt+Control L snap right

        # Super+Alt+Shift+{H,J,K,L} to resize views
        riverctl map normal Super+Alt+Shift H resize horizontal -100
        riverctl map normal Super+Alt+Shift J resize vertical 100
        riverctl map normal Super+Alt+Shift K resize vertical -100
        riverctl map normal Super+Alt+Shift L resize horizontal 100

        # Super + Left Mouse Button to move views
        riverctl map-pointer normal Super BTN_LEFT move-view

        # Super + Right Mouse Button to resize views
        riverctl map-pointer normal Super BTN_RIGHT resize-view

        # Super + Middle Mouse Button to toggle float
        riverctl map-pointer normal Super BTN_MIDDLE toggle-float

        for i in $(seq 1 9)
        do
            tags=$((1 << ($i - 1)))

            # Super+[1-9] to focus tag [0-8]
            riverctl map normal Super $i set-focused-tags $tags

            # Super+Shift+[1-9] to tag focused view with tag [0-8]
            riverctl map normal Super+Shift $i set-view-tags $tags

            # Super+Control+[1-9] to toggle focus of tag [0-8]
            riverctl map normal Super+Control $i toggle-focused-tags $tags

            # Super+Shift+Control+[1-9] to toggle tag [0-8] of focused view
            riverctl map normal Super+Shift+Control $i toggle-view-tags $tags
        done

        # Super+0 to focus all tags
        # Super+Shift+0 to tag focused view with all tags
        all_tags=$(((1 << 32) - 1))
        riverctl map normal Super 0 set-focused-tags $all_tags
        riverctl map normal Super+Shift 0 set-view-tags $all_tags

        # Super+Space to toggle float
        riverctl map normal Super V toggle-float

        # Super+F to toggle fullscreen
        riverctl map normal Super B toggle-fullscreen

        # Super+Shift+Alt+S to shut down computer
        riverctl map normal Super+Alt+Shift S spawn "systemctl poweroff"
        riverctl map normal Super+Alt+Shift R spawn "systemctl reboot"
        riverctl map normal Super+Alt+Shift N spawn "systemctl suspend"

        # Super+{Up,Right,Down,Left} to change layout orientation
        riverctl map normal Super Up    send-layout-cmd rivertile "main-location top"
        riverctl map normal Super Right send-layout-cmd rivertile "main-location right"
        riverctl map normal Super Down  send-layout-cmd rivertile "main-location bottom"
        riverctl map normal Super Left  send-layout-cmd rivertile "main-location left"

        # Declare a passthrough mode. This mode has only a single mapping to return to
        # normal mode. This makes it useful for testing a nested wayland compositor
        riverctl declare-mode passthrough

        # Super+F11 to enter passthrough mode
        riverctl map normal Super F11 enter-mode passthrough

        # Super+F11 to return to normal mode
        riverctl map passthrough Super F11 enter-mode normal

        # Various media key mapping examples for both normal and locked mode which do
        # not have a modifier
        for mode in normal locked
        do
            # Eject the optical drive (well if you still have one that is)
            riverctl map $mode None XF86Eject spawn 'eject -T'

            # Control pulse audio volume with pamixer (https://github.com/cdemoulins/pamixer)
            riverctl map $mode None XF86AudioRaiseVolume  spawn '${raiseVolumeCommand}'
            riverctl map $mode None XF86AudioLowerVolume  spawn '${lowerVolumeCommand}'
            riverctl map $mode None XF86AudioMute         spawn '${muteVolumeCommand}'

            # Control MPRIS aware media players with playerctl (https://github.com/altdesktop/playerctl)
            riverctl map $mode None XF86AudioMedia spawn '${playerPause}'
            riverctl map $mode None XF86AudioPlay  spawn '${playerPause}'
            riverctl map $mode None XF86AudioPrev  spawn '${playerPrev}'
            riverctl map $mode None XF86AudioNext  spawn '${playerNext}'
            riverctl map $mode Super+Alt L spawn '${playerNext}'
            riverctl map $mode Super+Alt H spawn '${playerPrev}'
            riverctl map $mode Super+Alt K spawn '${raiseVolumeCommand}'
            riverctl map $mode Super+Alt J spawn '${lowerVolumeCommand}'
            riverctl map $mode Super+Alt P spawn '${playerPause}'
            riverctl map $mode Super+Alt M spawn '${muteVolumeCommand}'
            riverctl map $mode Super+Alt N spawn '${muteMicCommand}'

            # Control screen backlight brightness with brightnessctl (https://github.com/Hummer12007/brightnessctl)
            riverctl map $mode None XF86MonBrightnessUp   spawn 'brightnessctl set +5%'
            riverctl map $mode None XF86MonBrightnessDown spawn 'brightnessctl set 5%-'
        done

        # Set background and border color
        #riverctl background-color 0x002b36
        ${
          if config.stylix.enable then
            "
          riverctl border-color-focused 0x${config.lib.stylix.colors.base0E}
          riverctl border-color-unfocused 0x${config.lib.stylix.colors.base03}
        "
          else
            ""
        }

        # Set keyboard repeat rate
        riverctl set-repeat 25 600

        # Make all views with an app-id that starts with "float" and title "foo" start floating.
        riverctl rule-add -app-id 'float*' -title 'foo' float

        # Make all views with app-id "bar" and any title use client-side decorations
        riverctl rule-add -app-id "bar" csd

        # Set the default layout generator to be rivertile and start it.
        # River will send the process group of the init executable SIGTERM on exit.
        riverctl default-layout rivertile
        rivertile -view-padding 0 -outer-padding 0 &

        # Disable Primary clipboard in wayland apps
        wl-paste -p --watch wl-copy -cp &

        # Application Autostart
        nextcloud &

        # Extra config
        ${cfg.extraConfig}
      '';
    };
  };
}
