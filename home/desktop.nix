# My cozy home UwU
# Some config must be anbled manually, such as the gnome-config.
# This is done so that e.g. gnome and kde settings don't clash.
{ lib, config, ... }:
with lib;
let
  cfg = config.home-desktop;
in {
  imports = [
    ./xdg.nix
  ];

  options.home-desktop = {
    enable = mkEnableOption "Cozy home desktop (or laptop (or anything else)) config";
  };

  config = mkIf cfg.enable {
    home.username = "rakarake";
    home.homeDirectory = "/home/rakarake";
    home.stateVersion = "23.05";
    programs.home-manager.enable = true;

    # Enable default applications
    home-xdg.enable = true;

    # Programming environment
    dev-stuff.enable = true;

    # Logseq Wayland
    xdg.desktopEntries.logseqWayland = {
      name = "Logseq Wayland";
      genericName = "Logseq Wayland";
      exec = "logseq --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-webrtc-pipewire-capturer";
    };

    # Discord Wayland
    xdg.desktopEntries.discordWayland = {
      name = "Discord Wayland";
      genericName = "Discord Wayland";
      exec = "discord --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-webrtc-pipewire-capturer";
    };

    # Webcord Wayland
    xdg.desktopEntries.webcordWayland = {
      name = "Webcord Wayland";
      genericName = "Webcord Wayland";
      exec = "webcord --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-webrtc-pipewire-capturer";
    };
    
    # Steam Gamescope
    xdg.desktopEntries.steamGamescope = {
      name = "Steam Gamescope";
      genericName = "Steam";
      # -e enables steam integration, -f fullscreens the window by default
      exec = "gamescope -W 1920 -H 1080 --adaptive-sync -f -r 600 -e -- steam";
    };

    # VSCode Wayland
    xdg.desktopEntries.vscode = {
      name = "VSCode Wayland";
      genericName = "VSCode Wayland";
      exec = "code --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-webrtc-pipewire-capturer";
    };
  };
}
