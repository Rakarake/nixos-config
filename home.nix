# Shared Home Manager config for rakarake
{ lib, config, pkgs, ... }: 
let
  mkTuple = lib.hm.gvariant.mkTuple;
in
{
  home.username = "rakarake";
  home.homeDirectory = "/home/rakarake";
  home.stateVersion = "23.05";
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    firefox
    thunderbird
    mullvad-vpn
  ];
  # Gnome settings
  # Use: `dconf watch /` to find the names of gnome settings
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
    # Keybinds
    "org/gnome/desktop/wm/keybindings" = {
      switch-to-workspace-left  = ["<Control><Super>h"];
      switch-to-workspace-right = ["<Control><Super>l"];
    };
    # Caps-Lock as Escape
    "org/gnome/desktop/input-sources" = {
      xkb-options = ["terminate:ctrl_alt_bksp" "caps:escape"];
    };
  };
}
