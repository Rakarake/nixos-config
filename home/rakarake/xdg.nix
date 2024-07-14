{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.home-xdg;
  browser =     ["floorp.desktop"];
  audioPlayer = ["mpv.desktop"];
  videoPlayer = ["mpv.desktop"];
  imageViewer = ["imv.desktop"];
  mailClient  = ["thunderbird.desktop"];
  pdfViewer   = ["org.gnome.Evince.desktop"];
  fileManager = ["nautilus.desktop"];

  # XDG MIME types
  associations = {
    # Browser
    "application/x-extension-htm"   = browser;
    "application/x-extension-html"  = browser;
    "application/x-extension-shtml" = browser;
    "application/x-extension-xht"   = browser;
    "application/x-extension-xhtml" = browser;
    "application/xhtml+xml"         = browser;
    "text/html"                     = browser;
    "x-scheme-handler/about"        = browser;
    "x-scheme-handler/chrome"       = browser;
    "x-scheme-handler/ftp"          = browser;
    "x-scheme-handler/http"         = browser;
    "x-scheme-handler/https"        = browser;
    "x-scheme-handler/unknown"      = browser;

    # Mail
    "handler/mailto" = mailClient;

    # Multimedia
    "audio/*"         = audioPlayer;
    "audio/flac"      = audioPlayer;
    "audio/mp3"       = audioPlayer;
    "video/*"         = videoPlayer;
    "video/mp4"       = videoPlayer;
    "video/mkv"       = videoPlayer;
    "image/*"         = imageViewer;
    "image/png"       = imageViewer;
    "image/jpg"       = imageViewer;
    "application/pdf" = pdfViewer;

    # File manager
    "inode/directory" = fileManager;
  };
in {
  options.home-xdg = {
    enable = mkEnableOption "Default apps";
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
