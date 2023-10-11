{ pkgs, ... }: {
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs.gnomeExtensions; [
    appindicator        # System tray icons
    system76-scheduler  # Make foreground processes visable to the system76-scheduler
  ];

  programs.gnupg.agent = {
    pinentryFlavor = "gnome3";
  };

  environment.variables = {
    QT_QPA_PLATFORM = "wayland";
  };
}
