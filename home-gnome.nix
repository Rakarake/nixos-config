{ lib, config, pkgs, ... }: 
let
  mkTuple = lib.hm.gvariant.mkTuple;
in
{
  # Gnome settings
  # Use: `dconf watch /` to find the names of gnome settings
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3";
      package = pkgs.adw-gtk3;
    };
  };
  dconf.settings = {
    # Locale
    "system/locale" = {
      region = "sv_SE.UTF-8";
    };
    # Wallpaper
    "org/gnome/desktop/background" = {
      picture-uri      = "/run/current-system/sw/share/backgrounds/gnome/design-is-rounded-rectangles-l.webp";
      picture-uri-dark = "/run/current-system/sw/share/backgrounds/gnome/design-is-rounded-rectangles-d.webp";
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
      command = "kgx";
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
      ];
    };
  };
}
