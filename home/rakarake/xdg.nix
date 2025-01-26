{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.home-xdg;
  browser =     ["firefox.desktop"];
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
    "inode/directory" = cfg.file-manager.desktop;
  };
in {
  options.home-xdg = {
    enable = mkEnableOption "Default apps";

    # For used within other modules, these options also makes sure that the
    # programs are installed
    terminal = mkOption {
      type = types.attrs;
      default = { package = pkgs.xterm; bin = "xterm"; desktop = "xterm.desktop"; };
    };
    file-manager = mkOption {
      type = types.attrs;
      default = { package = pkgs.pcmanfm; bin = "pcmanfm"; desktop = "pcmanfm.desktop"; };
    };
  };
  config = mkIf cfg.enable {
    # Make sure that the default applications are installed
    home.packages = [
      cfg.terminal.package
      cfg.file-manager.package
    ];
    xdg = {
      enable = true;
      configFile."mimeapps.list".force = true;
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
