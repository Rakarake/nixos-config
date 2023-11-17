{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.home-xdg;
  browser =     ["firefox.desktop"];
  audioPlayer = ["mpv.desktop"];
  videoPlayer = ["mpv.desktop"];
  imageViewer = ["imv.desktop"];

  # XDG MIME types
  associations = {
    # Browser
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/x-extension-xht" = browser;
    "application/x-extension-xhtml" = browser;
    "application/xhtml+xml" = browser;
    "text/html" = browser;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/chrome" = ["chromium-browser.desktop"];
    "x-scheme-handler/ftp" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/unknown" = browser;
    # Multimedia
    "audio/*"    = audioPlayer;
    "audio/flac" = audioPlayer;
    "audio/mp3"  = audioPlayer;
    "video/*"    = videoPlayer;
    "video/mp4"  = videoPlayer;
    "video/mkv"  = videoPlayer;
    "image/*"    = imageViewer;
    "image/png"  = imageViewer;
    "image/jpg"  = imageViewer;
    "application/json" = browser;
    "application/pdf" = ["org.gnome.Evince.desktop"];
    # File manager
    "inode/directory" = ["dolphin.desktop"];
  };
in {
  options.home-xdg = {
    enable = mkEnableOption "Cozy home desktop (or laptop (or anything else)) config";
  };
  config = mkIf cfg.enable {
    xdg = {
      enable = true;

      mimeApps = {
        enable = true;
        defaultApplications = associations;
      };

      userDirs = {
        enable = true;
        createDirectories = true;
      };
    };
  };
}
