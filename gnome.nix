{ config, lib, pkgs, ... }@attrs: {
  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
  ];

  programs.gnupg.agent = {
    pinentryFlavor = "gnome3";
  };
}
