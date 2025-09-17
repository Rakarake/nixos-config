{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.home-xdg;
  # XDG MIME types
  associations = {
    # Browser
    "application/x-extension-htm"   = cfg.browser.desktop;
    "application/x-extension-html"  = cfg.browser.desktop;
    "application/x-extension-shtml" = cfg.browser.desktop;
    "application/x-extension-xht"   = cfg.browser.desktop;
    "application/x-extension-xhtml" = cfg.browser.desktop;
    "application/xhtml+xml"         = cfg.browser.desktop;
    "text/html"                     = cfg.browser.desktop;
    "x-scheme-handler/about"        = cfg.browser.desktop;
    "x-scheme-handler/chrome"       = cfg.browser.desktop;
    "x-scheme-handler/ftp"          = cfg.browser.desktop;
    "x-scheme-handler/http"         = cfg.browser.desktop;
    "x-scheme-handler/https"        = cfg.browser.desktop;
    "x-scheme-handler/unknown"      = cfg.browser.desktop;

    # Mail
    "handler/mailto" = cfg.mail-client.desktop;

    # Multimedia
    "audio/*"         = cfg.audio-player.desktop;
    "audio/flac"      = cfg.audio-player.desktop;
    "audio/mp3"       = cfg.audio-player.desktop;
    "video/*"         = cfg.video-player.desktop;
    "video/mp4"       = cfg.video-player.desktop;
    "video/mkv"       = cfg.video-player.desktop;
    "image/*"         = cfg.image-viewer.desktop;
    "image/png"       = cfg.image-viewer.desktop;
    "image/jpg"       = cfg.image-viewer.desktop;
    "application/pdf" = cfg.pdf-viewer.desktop;

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
      default = { package = pkgs.foot; bin = "foot"; desktop = "foot.desktop"; };
    };
    file-manager = mkOption {
      type = types.attrs;
      default = { package = pkgs.nautilus; bin = "nautilus"; desktop = "nautilus.desktop"; };
    };
    browser = mkOption {
      type = types.attrs;
      default = { package = pkgs.librewolf; bin = "librewolf"; desktop = "librewolf.desktop"; };
    };
    audio-player = mkOption {
      type = types.attrs;
      default = { package = pkgs.mpv; bin = "mpv"; desktop = "mpv.desktop"; };
    };
    video-player = mkOption {
      type = types.attrs;
      default = { package = pkgs.mpv; bin = "mpv"; desktop = "mpv.desktop"; };
    };
    image-viewer = mkOption {
      type = types.attrs;
      default = { package = pkgs.imv; bin = "imv"; desktop = "imv.desktop"; };
    };
    mail-client = mkOption {
      type = types.attrs;
      default = { package = pkgs.thunderbird; bin = "thunderbird"; desktop = "thunderbird.desktop"; };
    };
    pdf-viewer = mkOption {
      type = types.attrs;
      default = { package = pkgs.sioyek; bin = "sioyek"; desktop = "sioyek.desktop"; };
    };
    # TODO set up .desktop file for text editor
    text-editor = mkOption {
      type = types.attrs;
      default = { package = pkgs.neovim; bin = "nvim"; };
    };
    # uh, not xdg but ok
    wallpaper = mkOption {
      type = types.path;
      default = ./wallpaper.png;
    };
  };
  config = mkIf cfg.enable {
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
