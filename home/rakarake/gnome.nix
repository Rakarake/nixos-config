# Gnome settings
# Use: `dconf watch /` to find the names of gnome settings
{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.home-gnome;
in {
  options.home-gnome = {
    enable = mkEnableOption "Custom gnome user configuration";
  };
  config = mkIf cfg.enable {
    # Gnome extensions
    home.packages = (with pkgs.gnomeExtensions; [
      appindicator        # System tray icons
      system76-scheduler  # Make foreground processes visable to the system76-scheduler
    ]);

    #gtk = {
    #  enable = true;
    #  theme = {
    #    name = "adw-gtk3";
    #    package = pkgs.adw-gtk3;
    #  };
    #};
    dconf.settings = {
      # Locale
      "system/locale" = {
        region = "sv_SE.UTF-8";
      };
      # Custom Shortcuts
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>Return";
        command = "kitty -e bash -c 'tmux attach || tmux'";
        name = "Terminal";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        binding = "<Super><Shift>N";
        command = "logseq --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-webrtc-pipewire-capturer";
        name = "Terminal";
      };
      # Keybinds
      "org/gnome/desktop/wm/keybindings" = {
        switch-to-workspace-left  = ["<Control><Super>h"];
        switch-to-workspace-right = ["<Control><Super>l"];
        close =                     ["<Super>q"];
        move-to-workspace-left =    ["<Shift><Control><Super>h"];
        move-to-workspace-right =   ["<Shift><Control><Super>l"];
        toggle-maximized =          ["<Super>m"];
        toggle-fullscreen =         ["<Super>F11"];
        minimize =                  ["<Super>u"];
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        home = ["<Super>f"];
      };
      # Number of workspaces
      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = 6;
      };
      # Only workspaces on primary monitor
      # and edge tiling
      "org/gnome/mutter" = {
        workspaces-only-on-primary = true;
        edge-tiling = true;
      };
      # Caps-Lock as Escape
      "org/gnome/desktop/input-sources" = {
        xkb-options = ["terminate:ctrl_alt_bksp" "caps:escape"];
      };
      # Touchpad Tap-to-Click
      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
      };
      # Don't suspend when plugged in
      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-type = "nothing";
      };
      # Extentions
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [
          "appindicatorsupport@rgcjonas.gmail.com"
          "s76-scheduler@mattjakeman.com"
        ];
      };
    };
  };
}
