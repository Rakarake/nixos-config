{ ... }@attrs: {
  # Enable KDE
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  programs.dconf.enable = true;
  # Plasma Wayland as default session
  services.xserver.displayManager.defaultSession = "plasmawayland";
}
