{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
  ];

  programs.gnupg.agent = {
    pinentryFlavor = "gnome3";
  };

  environment.variables = {
    QT_QPA_PLATFORM = "wayland";
  };
}
