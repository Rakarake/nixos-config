{config, pkgs, ...}: {
  # We use gdm cuz lazy
  services.xserver.displayManager.gdm.enable = true;
  # Cuz we lazy
  services.xserver.desktopManager.gnome.enable = true;
  programs.hyprland.enable = true;  # Don't use this if using flake?
  # Wayland all the way 😉
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
  };
  environment.systemPackages = with pkgs; [
    grim         # Screenshot utility
    slurp        # Screen "area" picker utility
    eww-wayland  # Wacky widgets
    swaybg       # Anime wallpapers
    rofi-wayland # Application launcher + other stuff
    rofimoji     # Emoji picker for rofi
    pamixer      # Used by the eww script to control sound
  ];
}
